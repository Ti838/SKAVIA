import 'dart:async';
import 'dart:io';

enum NetworkQualityState { online, poorNetwork, offline, syncing, syncFailed }

/// Production Network Connectivity & Quality Monitoring Service.
/// Implements multi-host failover probing and latency calculation.
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

  void startMonitoring({Duration interval = const Duration(seconds: 15)}) {
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

  /// Probes DNS and ping latency across multiple resilient endpoints
  /// to prevent false offline flags on restrictive mobile ISPs.
  Future<NetworkQualityState> checkConnectivity() async {
    final stopwatch = Stopwatch()..start();
    const candidateHosts = ['google.com', 'cloudflare.com', 'dns.google'];
    bool isConnected = false;
    int latencyMs = 0;

    for (final host in candidateHosts) {
      try {
        final addresses = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 3));
        if (addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty) {
          isConnected = true;
          latencyMs = stopwatch.elapsedMilliseconds;
          break;
        }
      } catch (_) {
        // Try next candidate host
      }
    }
    stopwatch.stop();

    if (isConnected) {
      // Latency > 2500ms indicates poor mobile connectivity
      final state = latencyMs > 2500
          ? NetworkQualityState.poorNetwork
          : NetworkQualityState.online;
      _updateState(state);
      return state;
    } else {
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
