import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../logger/app_logger.dart';

enum InternetState { loading, connected, disconnected, error }

class InternetReconnectingState {
  final int secondsRemaining;

  InternetReconnectingState({required this.secondsRemaining});

  factory InternetReconnectingState.initial() {
    return InternetReconnectingState(secondsRemaining: 15);
  }

  InternetReconnectingState copyWith({int? secondsRemaining}) {
    return InternetReconnectingState(
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}

class ConnectivityState {
  final InternetState internetState;
  final InternetReconnectingState reconnectingState;

  ConnectivityState({
    required this.internetState,
    required this.reconnectingState,
  });

  ConnectivityState copyWith({
    InternetState? internetState,
    InternetReconnectingState? reconnectingState,
  }) {
    return ConnectivityState(
      internetState: internetState ?? this.internetState,
      reconnectingState: reconnectingState ?? this.reconnectingState,
    );
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier()
      : super(ConnectivityState(
          internetState: InternetState.loading,
          reconnectingState: InternetReconnectingState.initial(),
        )) {
    _initializeConnectivity();
  }

  final _connectivity = Connectivity();
  late final InternetConnectionChecker _internetChecker;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _reconnectionTimer;

  @override
  void dispose() {
    _subscription?.cancel();
    _reconnectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    try {
      // Create custom internet checker instance
      _internetChecker = InternetConnectionChecker.createInstance(
        addresses: [
          AddressCheckOption(uri: Uri.parse('https://www.google.com')),
          AddressCheckOption(uri: Uri.parse('https://www.bing.com')),
          AddressCheckOption(uri: Uri.parse('https://www.amazon.com')),
        ],
      );

      final results = await _connectivity.checkConnectivity();
      await _updateConnectionState(results);

      _subscription =
          _connectivity.onConnectivityChanged.listen((results) async {
        await _updateConnectionState(results);
      });
    } catch (e) {
      Log.error('Error initializing connectivity: $e');
      _updateInternetState(InternetState.error);
    }
  }

  void _updateInternetState(InternetState newState) {
    if (state.internetState != newState) {
      state = state.copyWith(internetState: newState);

      if (newState == InternetState.disconnected) {
        _startReconnectionTimer();
      } else {
        _cancelReconnectionTimer();
      }
    }
  }

  Future<void> _updateConnectionState(List<ConnectivityResult> results) async {
    if (results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none)) {
      _updateInternetState(InternetState.disconnected);
      return;
    }

    try {
      final hasInternet = await _internetChecker.hasConnection;
      _updateInternetState(
          hasInternet ? InternetState.connected : InternetState.disconnected);
      Log.info(
          'Internet is ${hasInternet ? 'connected ✅' : 'not connected ❌'}');
    } catch (e) {
      Log.error('Error checking internet connection: $e');
      _updateInternetState(InternetState.error);
    }
  }

  void _startReconnectionTimer() {
    _cancelReconnectionTimer();

    const oneSec = Duration(seconds: 1);
    _reconnectionTimer = Timer.periodic(oneSec, (Timer timer) {
      if (!mounted) {
        _cancelReconnectionTimer();
        return;
      }

      try {
        final currentSeconds = state.reconnectingState.secondsRemaining;

        if (currentSeconds == 0) {
          connect();
          state = state.copyWith(
            reconnectingState:
                state.reconnectingState.copyWith(secondsRemaining: 15),
          );
        } else {
          debugPrint('Decrementing Seconds: $currentSeconds');
          state = state.copyWith(
            reconnectingState: state.reconnectingState
                .copyWith(secondsRemaining: currentSeconds - 1),
          );
        }
      } catch (e) {
        debugPrint('Timer error: $e');
        _updateInternetState(InternetState.error);
        _cancelReconnectionTimer();
      }
    });
  }

  void _cancelReconnectionTimer() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
  }

  Future<bool> connect() async {
    try {
      Log.info('Attempting to reconnect...');
      _updateInternetState(InternetState.loading);

      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty ||
          (results.length == 1 && results.first == ConnectivityResult.none)) {
        _updateInternetState(InternetState.disconnected);
        return false;
      }

      final hasInternet = await _internetChecker.hasConnection;
      _updateInternetState(
          hasInternet ? InternetState.connected : InternetState.disconnected);
      Log.info('Reconnection ${hasInternet ? 'successful ✅' : 'failed ❌'}');
      return hasInternet;
    } catch (e) {
      Log.error('Error during reconnection attempt: $e');
      _updateInternetState(InternetState.error);
      return false;
    }
  }
}
