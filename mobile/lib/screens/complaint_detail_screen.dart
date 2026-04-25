import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_client.dart';

class ComplaintDetailScreen extends StatefulWidget {
  const ComplaintDetailScreen({super.key, required this.complaintId});

  final int complaintId;

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/complaints/${widget.complaintId}');
      setState(() => _data = res['data'] as Map<String, dynamic>?);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openMap(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    final u = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Not found'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('Status', style: Theme.of(context).textTheme.titleSmall),
                    Text(_data!['status']?.toString() ?? '', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(height: 32),
                    Text('Station', style: Theme.of(context).textTheme.titleSmall),
                    Text(_data!['station_name']?.toString() ?? ''),
                    if (_data!['station_phone'] != null) Text(_data!['station_phone'].toString()),
                    const Divider(height: 32),
                    Text('Description', style: Theme.of(context).textTheme.titleSmall),
                    Text(_data!['description']?.toString() ?? ''),
                    const Divider(height: 32),
                    Text('Your location when filed', style: Theme.of(context).textTheme.titleSmall),
                    if (_data!['user_lat'] != null && _data!['user_lng'] != null)
                      TextButton.icon(
                        onPressed: () => _openMap(
                          double.tryParse(_data!['user_lat'].toString()),
                          double.tryParse(_data!['user_lng'].toString()),
                        ),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Open in Maps'),
                      )
                    else
                      const Text('Not recorded'),
                    if (_data!['police_notes'] != null && _data!['police_notes'].toString().isNotEmpty) ...[
                      const Divider(height: 32),
                      Text('Police notes', style: Theme.of(context).textTheme.titleSmall),
                      Text(_data!['police_notes'].toString()),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Updated: ${_data!['updated_at'] ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
    );
  }
}
