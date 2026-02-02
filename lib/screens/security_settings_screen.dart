import 'package:flutter/material.dart';

import '../services/security_service.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _security = SecurityService();

  bool _useBio = false;
  bool _supported = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _supported = await _security.canUseBiometric();
    _useBio = await _security.useBiometric();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Use Fingerprint / Face ID'),
              subtitle: Text(
                _supported
                    ? 'Enable biometric unlock'
                    : 'Not supported on this device',
              ),
              value: _useBio && _supported,
              onChanged: _supported
                  ? (v) async {
                      await _security.setBiometric(v);
                      setState(() => _useBio = v);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
