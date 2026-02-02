import 'package:flutter/material.dart';

import '../services/security_service.dart';
import 'home_screen.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();

  final _security = SecurityService();

  String _error = '';

  Future<void> _save() async {
    if (_ctrl1.text.length != 4) {
      setState(() => _error = 'Enter 4 digits');
      return;
    }

    if (_ctrl1.text != _ctrl2.text) {
      setState(() => _error = 'PIN does not match');
      return;
    }

    await _security.savePin(_ctrl1.text);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            TextField(
              controller: _ctrl1,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
            ),

            TextField(
              controller: _ctrl2,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
            ),

            const SizedBox(height: 12),

            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: _save, child: const Text('Save PIN')),
          ],
        ),
      ),
    );
  }
}
