import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  Future<void> _launchSettings() async {
    final Uri settingsUrl = Uri.parse('package:com.example.plan_pilot');
    if (await canLaunchUrl(settingsUrl)) {
      await launchUrl(settingsUrl);
    } else {
      // Fallback to general settings if package-specific URL doesn't work
      final Uri generalSettingsUrl = Uri.parse('app-settings://');
      if (await canLaunchUrl(generalSettingsUrl)) {
        await launchUrl(generalSettingsUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Required'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Exact Alarms Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'To receive exact reminders for your tasks, this app needs permission to schedule exact alarms. This is a security feature introduced in Android 12 to prevent apps from scheduling too many alarms.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'How to grant permission:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Go to your device settings',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '2. Find "Apps" or "Application Manager"',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '3. Locate this app (Plan Pilot)',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '4. Scroll down and find "Exact Alarms" permission',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '5. Enable the permission',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _launchSettings,
              child: const Text('Open Settings'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
