import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_client.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() {
          _loading = false;
          _error = 'Location permission denied';
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final uri = '/police-stations/nearby?lat=${pos.latitude}&lng=${pos.longitude}&limit=20';
      final res = await ApiClient.instance.get(uri, auth: false);
      setState(() {
        _items = (res['data'] as List<dynamic>?) ?? [];
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby stations'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) {
                    final s = _items[i] as Map<String, dynamic>;
                    final km = s['distance_km'];
                    return ListTile(
                      leading: const Icon(Icons.local_police),
                      title: Text(s['name']?.toString() ?? ''),
                      subtitle: Text('${s['address'] ?? ''}\n${km != null ? '$km km' : ''}'),
                      isThreeLine: true,
                    );
                  },
                ),
    );
  }
}
