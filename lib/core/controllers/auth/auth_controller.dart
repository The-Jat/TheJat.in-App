import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../logger/app_logger.dart';
import '../../models/member.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../analytics/analytics_controller.dart';
import 'auth_state.dart';

final authController = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepo);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.repository) : super(AuthLoading()) {
    Log.info('Initializing AuthNotifier');
  }

  final AuthRepository repository;

  Future<void> init() async {
    try {
      Log.info('Starting auth initialization');
      Member? theUser = await repository.getUser();

      if (theUser != null) {
        Log.info('Found stored user: ${theUser.email.split('@')[0]}***');
        final token = await repository.getToken();

        if (token != null) {
          Log.info('Found stored token, validating...');
          bool isValid = await repository.vallidateToken(token: token);

          if (isValid) {
            Log.info('Token validated successfully');
            state = AuthLoggedIn(theUser);
            Log.info('Auth state set to LoggedIn');
          } else {
            Log.warning('Stored token is invalid');
            state = AuthGuestLoggedIn();
          }
        } else {
          Log.warning('No stored token found');
          state = AuthGuestLoggedIn();
        }
      } else {
        Log.info('No stored user found, setting guest state');
        state = AuthGuestLoggedIn();
      }
    } catch (e, stack) {
      Log.fatal(error: 'Auth initialization error: $e', stackTrace: stack);
      state = AuthGuestLoggedIn();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    Log.info('Login attempt for: ${email.split('@')[0]}***');

    try {
      final AuthResult result =
          await repository.login(email: email, password: password);

      if (result.success && result.member != null) {
        Log.info('Login successful');
        state = AuthLoggedIn(result.member!);
        if (mounted) {
          Log.info('Navigating to login animation');
          Navigator.pushNamed(context, AppRoutes.loginAnimation);
        }
        AnalyticsController.logUserLogin();
        return null;
      } else {
        Log.warning('Login failed: ${result.error ?? "Unknown error"}');
        return result.error ??
            'Login failed: ${result.error ?? "Unknown error"}';
      }
    } catch (e, stack) {
      Log.fatal(error: 'Login error: $e', stackTrace: stack);
      return 'An unexpected error occurred';
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    Log.info('Starting Google sign-in flow');
    try {
      final member = await repository.googleSignIn();
      if (member != null) {
        Log.info('Google sign-in successful');
        state = AuthLoggedIn(member);
        if (mounted) {
          Log.info('Navigating to login animation');
          Navigator.pushNamed(context, AppRoutes.loginAnimation);
        }
        AnalyticsController.logUserLogin();
        return true;
      } else {
        Log.warning('Google sign-in failed');
        Fluttertoast.showToast(msg: 'There\'s some issue with this account');
        return false;
      }
    } catch (e, stack) {
      Log.fatal(error: 'Google sign-in error: $e', stackTrace: stack);
      return false;
    }
  }

  Future<bool> signInWithApple(BuildContext context) async {
    Log.info('Starting Apple sign-in flow');
    try {
      final member = await repository.appleSignIn();
      if (member != null) {
        Log.info('Apple sign-in successful');
        state = AuthLoggedIn(member);
        if (mounted) {
          Log.info('Navigating to login animation');
          Navigator.pushNamed(context, AppRoutes.loginAnimation);
        }
        AnalyticsController.logUserLogin();
        return true;
      } else {
        Log.warning('Apple sign-in failed');
        Fluttertoast.showToast(msg: 'There\'s some issue with this account');
        return false;
      }
    } catch (e, stack) {
      Log.fatal(error: 'Apple sign-in error: $e', stackTrace: stack);
      return false;
    }
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    Log.info('Signup attempt for: $username');
    try {
      final isCreated = await repository.signUp(
        userName: username,
        email: email,
        password: password,
      );
      if (isCreated) {
        Log.info('Signup successful, attempting login');
        await login(email: email, password: password, context: context);
        AnalyticsController.logSignUp('Email');
        return true;
      } else {
        Log.warning('Signup failed');
        Fluttertoast.showToast(msg: 'Invalid Credentials');
        return false;
      }
    } catch (e, stack) {
      Log.fatal(error: 'Signup error: $e', stackTrace: stack);
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    Log.info('Starting logout process');
    try {
      state = AuthState();
      await repository.logout();
      await GoogleSignIn().signOut();
      Log.info('Logout successful, navigating to login intro');
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.loginIntro, (v) => false);
    } catch (e, stack) {
      Log.fatal(error: 'Logout error: $e', stackTrace: stack);
    }
  }

  Future<String?> sendResetLinkToEmail(String email) async {
    Log.info('Sending password reset link to: ${email.split('@')[0]}***');
    try {
      bool isValid = await repository.sendPasswordResetLink(email);
      if (isValid) {
        Log.info('Password reset link sent successfully');
        return null;
      } else {
        Log.warning('Failed to send password reset link');
        return 'The email is not registered';
      }
    } catch (e, stack) {
      Log.fatal(error: 'Password reset error: $e', stackTrace: stack);
      return 'An unexpected error occurred';
    }
  }
}
