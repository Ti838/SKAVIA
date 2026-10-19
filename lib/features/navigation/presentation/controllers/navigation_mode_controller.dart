import 'package:flutter/foundation.dart';

enum NavigationRoleMode { customer, worker, enterprise, admin }

/// Reactive controller managing active application navigation role mode.
class NavigationModeController extends ChangeNotifier {
  NavigationRoleMode _currentMode = NavigationRoleMode.customer;
  NavigationRoleMode get currentMode => _currentMode;

  bool get isCustomer => _currentMode == NavigationRoleMode.customer;
  bool get isWorker => _currentMode == NavigationRoleMode.worker;
  bool get isAdmin => _currentMode == NavigationRoleMode.admin;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setNavIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void switchMode(NavigationRoleMode mode) {
    _currentMode = mode;
    _currentIndex = 0;
    notifyListeners();
  }

  void toggleCustomerWorker() {
    _currentMode = _currentMode == NavigationRoleMode.customer
        ? NavigationRoleMode.worker
        : NavigationRoleMode.customer;
    _currentIndex = 0;
    notifyListeners();
  }
}
