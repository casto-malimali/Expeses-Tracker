import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Login
  Future<User> signIn() async {
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  String? get uid => _auth.currentUser?.uid;

  // Backup Transactions
  Future<void> backupTransactions(List<Map<String, dynamic>> items) async {
    if (uid == null) await signIn();

    final batch = _db.batch();

    final col = _db.collection('users').doc(uid).collection('transactions');

    for (var e in items) {
      final ref = col.doc(e['id']);
      batch.set(ref, e);
    }

    await batch.commit();
  }

  // Restore Transactions
  Future<List<Map<String, dynamic>>> restoreTransactions() async {
    if (uid == null) await signIn();

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .get();

    return snap.docs.map((e) => e.data()).toList();
  }

  // Backup Budgets
  Future<void> backupBudgets(List<Map<String, dynamic>> items) async {
    if (uid == null) await signIn();

    final col = _db.collection('users').doc(uid).collection('budgets');

    for (var e in items) {
      await col.doc(e['category']).set(e);
    }
  }

  // Restore Budgets
  Future<List<Map<String, dynamic>>> restoreBudgets() async {
    if (uid == null) await signIn();

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .get();

    return snap.docs.map((e) => e.data()).toList();
  }
}
