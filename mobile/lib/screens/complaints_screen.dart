import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'complaint_detail_screen.dart';
import 'new_complaint_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/complaints/my');
      setState(() => _items = (res['data'] as List<dynamic>?) ?? []);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My complaints'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NewComplaintScreen()),
          );
          await _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No complaints yet'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) {
                    final c = _items[i] as Map<String, dynamic>;
                    final id = c['complaint_id'] as int;
                    return ListTile(
                      title: Text(c['station_name']?.toString() ?? 'Station'),
                      subtitle: Text('${c['status'] ?? ''}\n${c['description']?.toString() ?? ''}'),
                      isThreeLine: true,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ComplaintDetailScreen(complaintId: id)),
                        );
                        await _load();
                      },
                    );
                  },
                ),
    );
  }
}
