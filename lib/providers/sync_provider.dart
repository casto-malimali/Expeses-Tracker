import 'package:flutter/material.dart';
import '../utils/sync_status.dart';

class SyncProvider extends ChangeNotifier {
  SyncStatus _status = SyncStatus.idle;
  bool _hasPendingChanges = false;

  SyncStatus get status => _status;
  bool get hasPendingChanges => _hasPendingChanges;

  void setSyncing() {
    _status = SyncStatus.syncing;
    notifyListeners();
  }

  void setIdle() {
    _status = SyncStatus.idle;
    _hasPendingChanges = false;
    notifyListeners();
  }

  void setOffline() {
    _status = SyncStatus.offline;
    _hasPendingChanges = true;
    notifyListeners();
  }

  void setError() {
    _status = SyncStatus.error;
    _hasPendingChanges = true;
    notifyListeners();
  }

  void markPending() {
    _hasPendingChanges = true;
    notifyListeners();
  }
}
