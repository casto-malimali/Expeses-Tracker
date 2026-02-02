import 'package:flutter/material.dart';

import '../services/security_service.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _ctrl = TextEditingController();
  final _security = SecurityService();

  String _error = '';

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  // Future<void> _tryBiometric() async {
  //   final ok = await _security.authenticateBiometric();

  //   if (ok && mounted) {
  //     _goHome();
  //   }
  // }
  Future<void> _tryBiometric() async {
    final enabled = await _security.useBiometric();
    final supported = await _security.canUseBiometric();

    if (!enabled || !supported) return;

    final ok = await _security.authenticateBiometric();

    if (ok && mounted) {
      _goHome();
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _unlock() async {
    final valid = await _security.verifyPin(_ctrl.text);

    if (valid) {
      _goHome();
    } else {
      setState(() => _error = 'Wrong PIN');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 60),

            const SizedBox(height: 16),

            const Text(
              'Enter PIN',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _ctrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),

            const SizedBox(height: 8),

            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),

            ElevatedButton(onPressed: _unlock, child: const Text('Unlock')),
          ],
        ),
      ),
    );
  }
}
