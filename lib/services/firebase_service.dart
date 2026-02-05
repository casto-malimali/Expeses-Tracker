import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> signInIfNeeded() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  String get uid => _auth.currentUser!.uid;

  // ============ TRANSACTIONS ============

  Future<void> syncTransactions(List<Map<String, dynamic>> items) async {
    await signInIfNeeded();

    final col = _db.collection('users').doc(uid).collection('transactions');

    final batch = _db.batch();

    for (var e in items) {
      final ref = col.doc(e['id']);
      batch.set(ref, e);
    }

    await batch.commit();
  }

  Future<List<Map>> fetchTransactions() async {
    await signInIfNeeded();

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .get();

    return snap.docs.map((e) => e.data()).toList();
  }

  // ============ BUDGETS ============

  Future<void> syncBudgets(List<Map<String, dynamic>> items) async {
    await signInIfNeeded();

    final col = _db.collection('users').doc(uid).collection('budgets');

    for (var e in items) {
      await col
          .doc('${e['month']}_${e['category']}')
          .set(e as Map<String, dynamic>);
    }
  }

  Future<List<Map>> fetchBudgets() async {
    await signInIfNeeded();

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .get();

    return snap.docs.map((e) => e.data()).toList();
  }
  // ...existing code...

  Future<void> backupTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    // Replace with your actual Firebase backup logic
    // For example, using Firestore:
    final collection = FirebaseFirestore.instance.collection('transactions');
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Clear existing transactions (optional, depending on your use case)
    final snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // Add new transactions
    for (var tx in transactions) {
      final docRef = collection.doc();
      batch.set(docRef, tx);
    }

    await batch.commit();
  }

  // ...existing code...
}
