import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final available = await context.read<AuthProvider>().isBiometricAvailable();
      if (mounted) setState(() => _biometricAvailable = available);
    });
  }

  void _toggleBiometric(bool enabled) async {
    final ok = await Provider.of<AuthProvider>(context, listen: false).setBiometricEnabled(enabled);
    if (!mounted) return;
    final message = !ok
        ? 'Could not verify biometrics. Try again.'
        : (enabled ? 'Biometric unlock enabled' : 'Biometric unlock disabled');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final success = await Provider.of<AuthProvider>(context, listen: false).changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password changed successfully. Please login again.')));
      Provider.of<AuthProvider>(context, listen: false).logout();
      // App should navigate back to login automatically because of auth state listener in main
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricEnabled = context.watch<AuthProvider>().biometricEnabled;

    return Scaffold(
      appBar: AppBar(title: Text('Profile Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_biometricAvailable)
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Unlock'),
                  subtitle: const Text('Use fingerprint/Face ID to unlock the app'),
                  value: biometricEnabled,
                  onChanged: _toggleBiometric,
                ),
              ),
            SizedBox(height: 20),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
            ),
            // Avatar update logic could be added here
          ],
        ),
      ),
    );
  }
}
