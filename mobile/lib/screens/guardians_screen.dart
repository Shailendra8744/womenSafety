import 'package:flutter/material.dart';

import '../services/api_client.dart';

class GuardiansScreen extends StatefulWidget {
  const GuardiansScreen({super.key});

  @override
  State<GuardiansScreen> createState() => _GuardiansScreenState();
}

class _GuardiansScreenState extends State<GuardiansScreen> {
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
      final res = await ApiClient.instance.get('/user/guardians');
      setState(() => _items = (res['data'] as List<dynamic>?) ?? []);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm({Map<String, dynamic>? g}) async {
    final name = TextEditingController(text: g?['name']?.toString() ?? '');
    final email = TextEditingController(text: g?['email']?.toString() ?? '');
    final phone = TextEditingController(text: g?['phone']?.toString() ?? '');
    final id = g?['id'] as int?;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(id == null ? 'Add guardian' : 'Edit guardian'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty || email.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      if (id == null) {
        await ApiClient.instance.post('/user/guardians', {
          'name': name.text.trim(),
          'email': email.text.trim(),
          'phone': phone.text.trim(),
        });
      } else {
        await ApiClient.instance.put('/user/guardians/$id', {
          'name': name.text.trim(),
          'email': email.text.trim(),
          'phone': phone.text.trim(),
        });
      }
      await _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(int id) async {
    final c = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove guardian?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (c != true) return;
    try {
      await ApiClient.instance.delete('/user/guardians/$id');
      await _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardians')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final g = _items[i] as Map<String, dynamic>;
                final id = g['id'] as int;
                return ListTile(
                  title: Text(g['name']?.toString() ?? ''),
                  subtitle: Text('${g['email'] ?? ''}\n${g['phone'] ?? ''}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(g: g)),
                      IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(id)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
