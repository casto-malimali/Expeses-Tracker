import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  static const _pinKey = 'app_pin';
  static const _bioKey = 'use_biometric';

  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  // Save PIN
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  // Get PIN
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  // Delete PIN
  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  // Check if PIN exists
  Future<bool> hasPin() async {
    return await getPin() != null;
  }

  // Verify PIN
  Future<bool> verifyPin(String input) async {
    final saved = await getPin();
    return saved == input;
  }

  // Check biometric availability
  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  // Save biometric preference
  Future<void> setBiometric(bool value) async {
    await _storage.write(key: _bioKey, value: value.toString());
  }

  // Get biometric preference
  Future<bool> useBiometric() async {
    final v = await _storage.read(key: _bioKey);
    return v == 'true';
  }

  // Biometric Auth
  Future<bool> authenticateBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;

      if (!canCheck) return false;

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access app',
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }
}
