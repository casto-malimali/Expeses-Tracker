import 'dart:async';
import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';

class NetworkProvider extends ChangeNotifier {
  final ConnectivityService _service = ConnectivityService();

  bool _isOnline = true;
  StreamSubscription? _subscription;

  VoidCallback? onReconnect;

  bool get isOnline => _isOnline;

  NetworkProvider() {
    _init();
  }

  void _init() async {
    _isOnline = await _service.isOnline();
    notifyListeners();

    // _subscription = _service.onStatusChange.listen((status) {
    //   _isOnline = status;
    //   notifyListeners();
    // });
    _subscription = _service.onStatusChange.listen((status) {
      _isOnline = status;
      notifyListeners();

      if (status && onReconnect != null) {
        onReconnect!();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
