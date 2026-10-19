import 'dart:async';
import 'dart:io';

enum NetworkQualityState {
  online,
  poorNetwork,
  offline,
  syncing,
  syncFailed,
}

/// Production Network Connectivity & Quality Monitoring Service.
/// Implements heartbeat ping latency calculation and state streaming.
class NetworkConnectivityService {
  NetworkConnectivityService._internal();
  static final NetworkConnectivityService instance =
      NetworkConnectivityService._internal();

  NetworkQualityState _currentState = NetworkQualityState.online;
  NetworkQualityState get currentState => _currentState;

  final StreamController<NetworkQualityState> _stateController =
      StreamController<NetworkQualityState>.broadcast();

  Stream<NetworkQualityState> get stateStream => _stateController.stream;

  Timer? _pollingTimer;
  bool _isMonitoring = false;

  void startMonitoring({Duration interval = const Duration(seconds: 10)}) {
    if (_isMonitoring) return;
    _isMonitoring = true;
    checkConnectivity();
    _pollingTimer = Timer.periodic(interval, (_) => checkConnectivity());
  }

  void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isMonitoring = false;
  }

  /// Sets state manually (e.g. during active sync or unit tests)
  void setManualState(NetworkQualityState state) {
    if (_currentState != state) {
      _currentState = state;
      _stateController.add(state);
    }
  }

  /// Probes DNS and ping latency to identify online vs poor network vs offline.
  Future<NetworkQualityState> checkConnectivity() async {
    final stopwatch = Stopwatch()..start();
    try {
      final addresses = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 4));
      stopwatch.stop();

      if (addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty) {
        final latencyMs = stopwatch.elapsedMilliseconds;
        // If latency exceeds 1500ms, classify as poor network
        final state = latencyMs > 1500
            ? NetworkQualityState.poorNetwork
            : NetworkQualityState.online;
        _updateState(state);
        return state;
      } else {
        _updateState(NetworkQualityState.offline);
        return NetworkQualityState.offline;
      }
    } catch (_) {
      _updateState(NetworkQualityState.offline);
      return NetworkQualityState.offline;
    }
  }

  void _updateState(NetworkQualityState newState) {
    // Only update if not in explicit syncing state
    if (_currentState == NetworkQualityState.syncing &&
        (newState == NetworkQualityState.online ||
            newState == NetworkQualityState.poorNetwork)) {
      return;
    }

    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }

  void dispose() {
    stopMonitoring();
    _stateController.close();
  }
}

