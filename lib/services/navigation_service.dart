import 'package:flutter/foundation.dart';

/// Simple global navigation helper for switching admin shell tab from
/// anywhere in the app without tightly coupling widgets.
class NavigationService {
  NavigationService._private();

  static final NavigationService instance = NavigationService._private();

  /// Notifier for admin shell current tab index.
  final ValueNotifier<int> adminTabNotifier = ValueNotifier<int>(0);

  /// Whether an `AdminShellPage` is currently mounted and listening.
  bool hasAdminShell = false;

  void setHasAdminShell(bool value) => hasAdminShell = value;

  void setAdminTab(int index) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print('NavigationService: setAdminTab -> $index');
    }

    // Jika indexnya sama dengan index saat ini, paksa notifyListeners 
    // agar Shell tetap merespon (misal: scroll to top atau refresh tab)
    if (adminTabNotifier.value == index) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      adminTabNotifier.notifyListeners();
    } else {
      adminTabNotifier.value = index;
    }
  }
}