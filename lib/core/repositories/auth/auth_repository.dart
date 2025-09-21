import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../config/wp_config.dart';
import '../../controllers/dio/dio_provider.dart';
import '../../logger/app_logger.dart';
import '../../models/member.dart';
import '../../utils/extensions.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRepository(dio);
});

abstract class AuthRepoAbstract {
  Future<AuthResult?> login({required String email, required String password});
  Future<void> logout();
  Future<bool> signUp({
    required String userName,
    required String email,
    required String password,
  });
  Future<bool> sendPasswordResetLink(String email);
  Future<bool> isLoggedIn();
  Future<bool> saveToken({required String token});
  Future<bool> deleteToken();
  Future<String?> getToken();
  Future<bool> vallidateToken({required String token});
  Future<Member?> getUser();
  Future<void> deleteUserData();
  Future<void> saveUserData(Member data);
  Future<Member?> googleSignIn();
  Future<Member?> appleSignIn();
}

class AuthRepository extends AuthRepoAbstract {
  final Dio dio;
  AuthRepository(this.dio);

  final String _tokenKey = '_thePro322';
  static const _iOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );
  static const _aOptions = AndroidOptions(encryptedSharedPreferences: true);

  @override
  Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    try {
      String? value = await storage.read(
        key: _tokenKey,
        iOptions: _iOptions,
        aOptions: _aOptions,
      );
      Log.info('Token retrieval - Success: ${value != null}');
      return value;
    } catch (e, stack) {
      Log.fatal(error: 'Token retrieval failed: $e', stackTrace: stack);
      return null;
    }
  }

  @override
  Future<bool> saveToken({required String token}) async {
    const storage = FlutterSecureStorage();
    try {
      await storage.write(
        key: _tokenKey,
        value: token,
        iOptions: _iOptions,
        aOptions: _aOptions,
      );
      Log.info('Token saved successfully');
      return true;
    } catch (e, stack) {
      Log.fatal(error: 'Failed to save token: $e', stackTrace: stack);
      return false;
    }
  }

  @override
  Future<bool> deleteToken() async {
    const storage = FlutterSecureStorage();
    try {
      await storage.delete(
        key: _tokenKey,
        iOptions: _iOptions,
        aOptions: _aOptions,
      );
      Log.info('Token deleted successfully');
      return true;
    } catch (e, stack) {
      Log.fatal(error: 'Failed to delete token: $e', stackTrace: stack);
      return false;
    }
  }

  @override
  Future<bool> vallidateToken({required String token}) async {
    String url = 'https://${WPConfig.url}/wp-json/jwt-auth/v1/token/validate';
    Log.info('Validating token at: $url');

    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      Log.info('Token validation response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      Log.error('Token validation failed: $e');
      return false;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    Log.info('Checking login status');
    String? token = await getToken();
    bool loggedIn = false;

    if (token != null) {
      Log.info('Token found, validating...');
      bool isValid = await vallidateToken(token: token);
      if (isValid) {
        Log.info('Token is valid, user is logged in');
        loggedIn = true;
      } else {
        Log.info('Token is invalid');
      }
    } else {
      Log.info('No token found');
    }
    return loggedIn;
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    String url = 'https://${WPConfig.url}/wp-json/jwt-auth/v1/token';
    Log.info('Login attempt for: ${email.split('@')[0]}***');

    try {
      final response = await dio.post(
        url,
        data: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        Log.info('Login successful');
        final decodeResponse = response.data;
        await saveToken(token: decodeResponse['token']);
        final user = Member.fromServer(decodeResponse);
        await saveUserData(user);
        return AuthResult.success(user);
      } else {
        Log.warning('Login failed with status: ${response.statusCode}');
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Invalid request. Please check your input.';
            break;
          case 401:
            errorMessage =
                'Invalid credentials. Please check your email and password.';
            break;
          case 403:
            if (response.data != null && response.data['code'] != null) {
              // Let the error code handling below deal with specific 403 errors
              throw DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
              );
            } else {
              errorMessage = 'Access denied. Please try again later.';
            }
            break;
          case 404:
            errorMessage = 'Service not available. Please try again later.';
            break;
          case 429:
            errorMessage = 'Too many requests. Please try again later.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          case 502:
            errorMessage =
                'Server is temporarily unavailable. Please try again later.';
            break;
          case 503:
            errorMessage = 'Service unavailable. Please try again later.';
            break;
          case 504:
            errorMessage = 'Server timeout. Please try again later.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again later.';
        }
        return AuthResult.error(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final errorData = e.response?.data;
        final errorCode = errorData['code'];
        final errorMessage = errorData['message']
                ?.toString()
                .replaceAll(RegExp(r'<[^>]*>'), '') ??
            'Login failed';

        Log.warning('Login error: $errorCode - $errorMessage');

        String userMessage = errorMessage;
        switch (errorCode) {
          case '[jwt_auth] too_many_retries':
            userMessage =
                'Too many failed attempts. Please try again in 8 minutes.';
            break;
          case '[jwt_auth] invalid_email':
            userMessage = 'The email address is not valid.';
            break;
          case '[jwt_auth] invalid_username':
            userMessage = 'Username does not exist.';
            break;
          case '[jwt_auth] incorrect_password':
            userMessage = 'The password you entered is incorrect.';
            break;
          case '[jwt_auth] empty_username':
            userMessage = 'The username field is empty.';
            break;
          case '[jwt_auth] empty_password':
            userMessage = 'The password field is empty.';
            break;
          case '[jwt_auth] invalid_credentials':
            userMessage = 'Invalid login credentials.';
            break;
          case '[jwt_auth] already_authenticated':
            userMessage = 'User is already authenticated.';
            break;
          case '[jwt_auth] account_suspended':
            userMessage = 'This account has been suspended.';
            break;
          case '[jwt_auth] account_inactive':
            userMessage =
                'This account is not active. Please check your email for activation link.';
            break;
        }

        return AuthResult.error(userMessage,
            statusCode: e.response?.statusCode);
      }

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            return AuthResult.error(
                'Connection timeout. Please check your internet connection.');
          case DioExceptionType.sendTimeout:
            return AuthResult.error(
                'Unable to send request. Please check your internet connection.');
          case DioExceptionType.receiveTimeout:
            return AuthResult.error(
                'Server is not responding. Please try again later.');
          case DioExceptionType.badCertificate:
            return AuthResult.error(
                'Security certificate error. Please try again later.');
          case DioExceptionType.connectionError:
            return AuthResult.error(
                'Connection error. Please check your internet connection.');
          case DioExceptionType.cancel:
            return AuthResult.error('Request was cancelled. Please try again.');
          default:
            return AuthResult.error(
                'Network error. Please check your connection and try again.');
        }
      }

      Log.fatal(
          error: 'Unexpected login error: $e', stackTrace: StackTrace.current);
      return AuthResult.error('An unexpected error occurred');
    }
  }

  @override
  Future<void> logout() async {
    Log.info('Initiating logout');
    try {
      await deleteToken();
      await deleteUserData();
      Log.info('Logout completed successfully');
    } catch (e, stack) {
      Log.fatal(error: 'Logout error: $e', stackTrace: stack);
    }
  }

  @override
  Future<bool> signUp({
    required String userName,
    required String email,
    required String password,
  }) async {
    String url = 'https://${WPConfig.url}/wp-json/newspro/v2/users/register/';
    Log.info('Signup attempt for: $userName');

    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode(
          {'username': userName, 'email': email, 'password': password},
        ),
      );

      if (response.statusCode == 200) {
        Log.info('Signup successful');
        return true;
      } else {
        Log.warning('Signup failed with status: ${response.statusCode}');
        if (response.statusCode == 400) {
          Fluttertoast.showToast(msg: 'Email/Username already exists');
        }
        return false;
      }
    } catch (e, stack) {
      Log.fatal(error: 'Signup error: $e', stackTrace: stack);
      Fluttertoast.showToast(msg: 'Oops! Something gone wrong');
      return false;
    }
  }

  @override
  Future<bool> sendPasswordResetLink(String email) async {
    String url =
        'https://${WPConfig.url}/wp-json/newspro/v2/users/forgot-password';
    Log.info('Password reset request for: ${email.split('@')[0]}***');

    try {
      final response = await dio.post(url, data: {'email': email});

      if (response.statusCode == 200) {
        Log.info('Password reset link sent successfully');
        return true;
      } else {
        Log.warning(
            'Password reset failed with status: ${response.statusCode}');
        if (response.statusCode == 401) {
          Fluttertoast.showToast(msg: 'No Users Exist with this email');
        } else if (response.statusCode == 400) {
          Fluttertoast.showToast(msg: 'You must provide an email address');
        } else if (response.statusCode == 404) {
          Fluttertoast.showToast(
              msg: 'You must provide an valid email address');
        } else if (response.statusCode == 500) {
          Fluttertoast.showToast(msg: 'Something gone wrong');
        }
        return false;
      }
    } catch (e, stack) {
      Log.fatal(error: 'Password reset error: $e', stackTrace: stack);
      return false;
    }
  }

  final String _userBoxKey = 'user';
  final String _userKey = '_jiie';

  @override
  Future<Member?> getUser() async {
    Log.info('Retrieving stored user data');
    try {
      final bool isOpen = Hive.isBoxOpen(_userBoxKey);
      var box =
          isOpen ? Hive.box(_userBoxKey) : await Hive.openBox(_userBoxKey);
      final Map? data = box.get(_userKey);
      if (data != null) {
        final theUser = Member.fromLocal(Map.from(data));
        Log.info('User data retrieved successfully');
        return theUser;
      } else {
        Log.info('No stored user data found');
        return null;
      }
    } catch (e, stack) {
      Log.fatal(error: 'Error retrieving user data: $e', stackTrace: stack);
      return null;
    }
  }

  @override
  Future<void> saveUserData(Member data) async {
    Log.info('Saving user data');
    try {
      var box = Hive.box(_userBoxKey);
      await box.put(_userKey, data.toMap());
      Log.info('User data saved successfully');
    } catch (e, stack) {
      Log.fatal(error: 'Failed to save user data: $e', stackTrace: stack);
    }
  }

  @override
  Future<void> deleteUserData() async {
    Log.info('Deleting user data');
    try {
      var box = Hive.box(_userBoxKey);
      await box.delete(_userKey);
      Log.info('User data deleted successfully');
    } catch (e, stack) {
      Log.fatal(error: 'Failed to delete user data: $e', stackTrace: stack);
    }
  }

  Future<void> init() async {
    Log.info('Initializing user database');
    try {
      await Hive.openBox(_userBoxKey);
      Log.info('User database initialized successfully');
    } catch (e, stack) {
      Log.fatal(error: 'Database initialization error: $e', stackTrace: stack);
    }
  }

  @override
  Future<Member?> googleSignIn() async {
    Log.info('Initiating Google Sign In');
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        Log.info(
            'Google account selected: ${googleSignInAccount.email.split('@')[0]}***');
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
            await auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null && !user.isAnonymous) {
          Log.info('Firebase auth successful');
          String firstName = '';
          String lastName = '';

          if (user.displayName.validate().split(' ').isNotEmpty) {
            firstName = user.displayName.splitBefore(' ');
          }
          if (user.displayName.validate().split(' ').length >= 2) {
            lastName = user.displayName.splitAfter(' ');
          }

          Map req = {
            'email': user.email,
            'firstName': firstName,
            'lastName': lastName,
            'photoURL': user.photoURL,
            'accessToken': googleSignInAuthentication.accessToken,
            'loginType': 'google',
          };
          await googleSignIn.signOut();

          const url = 'https://${WPConfig.url}/wp-json/newspro/v2/users/social';

          try {
            final response = await dio.post(url, data: req);
            if (response.statusCode == 200) {
              Log.info('Social login successful');
              final decodeResponse = response.data;
              await saveToken(token: decodeResponse['token']);
              final user = Member.fromServer(decodeResponse);
              await saveUserData(user);
              return user;
            } else {
              Log.warning(
                  'Social login failed with status: ${response.statusCode}');
              return null;
            }
          } catch (e, stack) {
            Log.fatal(error: 'Social login error: $e', stackTrace: stack);
            return null;
          }
        } else {
          Log.warning('Firebase auth failed: User is null or anonymous');
          return null;
        }
      } else {
        Log.warning('Google sign in cancelled by user');
        return null;
      }
    } catch (e, stack) {
      Log.fatal(error: 'Google sign in error: $e', stackTrace: stack);
      return null;
    }
  }

  static String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<Member?> appleSignIn() async {
    Log.info('Initiating Apple Sign In');
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      Log.info('Apple credentials obtained');
      var req = {
        'email': credential.email,
        'firstName': credential.givenName,
        'lastName': credential.familyName,
        'photoURL': '',
        'accessToken': credential.identityToken,
        'loginType': 'apple',
      };

      const url = 'https://${WPConfig.url}/wp-json/newspro/v2/users/social';

      try {
        final response = await dio.post(url, data: req);
        if (response.statusCode == 200) {
          Log.info('Apple sign in successful');
          final decodeResponse = response.data;
          await saveToken(token: decodeResponse['token']);
          final user = Member.fromServer(decodeResponse);
          await saveUserData(user);
          return user;
        } else {
          Log.warning(
              'Apple sign in failed with status: ${response.statusCode}');
          return null;
        }
      } catch (e, stack) {
        Log.fatal(error: 'Apple sign in error: $e', stackTrace: stack);
        return null;
      }
    } catch (e, stack) {
      Log.fatal(error: 'Apple credential error: $e', stackTrace: stack);
      return null;
    }
  }
}

class AuthResult {
  final Member? member;
  final String? error;
  final bool success;
  final int? statusCode;

  AuthResult({
    this.member,
    this.error,
    this.statusCode,
    this.success = false,
  });

  factory AuthResult.success(Member member) {
    return AuthResult(
      member: member,
      success: true,
      statusCode: 200,
    );
  }

  factory AuthResult.error(String message, {int? statusCode}) {
    return AuthResult(
      error: message,
      success: false,
      statusCode: statusCode,
    );
  }

  factory AuthResult.fromException(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final errorData = e.response?.data;
      final errorMessage =
          errorData['message']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ??
              'Login failed';
      return AuthResult.error(errorMessage, statusCode: e.response?.statusCode);
    }
    return AuthResult.error('An unexpected error occurred');
  }
}
