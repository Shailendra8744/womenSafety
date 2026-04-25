import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_client.dart';
import '../services/session_store.dart';
import 'complaints_screen.dart';
import 'guardians_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'stations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _sos(BuildContext context) async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      final r = await Geolocator.requestPermission();
      if (r == LocationPermission.denied ||
          r == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required for SOS'),
            ),
          );
        }
        return;
      }
    }
    final pos = await Geolocator.getCurrentPosition();
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Sending SOS…'),
          ],
        ),
      ),
    );
    try {
      // 1. Existing API call - THIS ALREADY SENDS THE EMAILS!
      await ApiClient.instance.post('/sos', {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });

      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SOS sent and emails dispatched!')),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      // ... error handling
    }
  }

  Future<void> _logout(BuildContext context) async {
    await SessionStore.setToken(null);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Women Security'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Semantics(
              button: true,
              label: 'SOS emergency',
              child: Material(
                color: Colors.red.shade700,
                shape: const CircleBorder(),
                elevation: 6,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _sos(context),
                  child: const SizedBox(
                    width: 160,
                    height: 160,
                    child: Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Tap to send location to guardians & police',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _tile(context, Icons.person_outline, 'Profile', () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }),
          _tile(context, Icons.family_restroom, 'Guardians', () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const GuardiansScreen()));
          }),
          _tile(
            context,
            Icons.local_police_outlined,
            'Nearby police stations',
            () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const StationsScreen()));
            },
          ),
          _tile(context, Icons.report_problem_outlined, 'Complaints', () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ComplaintsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
