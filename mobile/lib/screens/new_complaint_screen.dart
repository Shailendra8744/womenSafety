import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_client.dart';

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final _desc = TextEditingController();
  List<dynamic> _stations = [];
  int? _stationId;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() => _loading = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location needed to find nearest station')),
          );
        }
        setState(() => _loading = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final uri = '/police-stations/nearby?lat=${pos.latitude}&lng=${pos.longitude}&limit=15';
      final res = await ApiClient.instance.get(uri, auth: false);
      final list = (res['data'] as List<dynamic>?) ?? [];
      setState(() {
        _stations = list;
        if (list.isNotEmpty) {
          _stationId = (list.first as Map<String, dynamic>)['id'] as int?;
        }
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      setState(() => _loading = false);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_stationId == null || _desc.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select station and enter description')));
      return;
    }
    setState(() => _submitting = true);
    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition();
      } catch (_) {}
      await ApiClient.instance.post('/complaints', {
        'police_station_id': _stationId,
        'description': _desc.text.trim(),
        if (pos != null) 'user_lat': pos.latitude,
        if (pos != null) 'user_lng': pos.longitude,
      });
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New complaint')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Police station', border: OutlineInputBorder()),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _stationId,
                        hint: const Text('Select station'),
                        items: _stations.map((s) {
                          final m = s as Map<String, dynamic>;
                          final id = m['id'] as int;
                          final name = m['name']?.toString() ?? '';
                          final km = m['distance_km'];
                          return DropdownMenuItem(
                            value: id,
                            child: Text(km != null ? '$name ($km km)' : name),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _stationId = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _desc,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Describe the incident',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Submit complaint'),
                  ),
                ],
              ),
            ),
    );
  }
}
