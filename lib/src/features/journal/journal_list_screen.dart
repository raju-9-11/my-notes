
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';
import 'package:intl/intl.dart';

class JournalListScreen extends ConsumerStatefulWidget {
  const JournalListScreen({super.key});

  @override
  ConsumerState<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends ConsumerState<JournalListScreen> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    final storage = ref.read(storageServiceProvider);
    final journals = await storage.getJournals();
    // Sort by date desc
    journals.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    if (mounted) {
      setState(() {
        _journals = journals;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _journals.isEmpty
              ? const Center(child: Text('No journal entries yet. Start writing!'))
              : ListView.builder(
                  itemCount: _journals.length,
                  itemBuilder: (context, index) {
                    final journal = _journals[index];
                    final date = DateTime.parse(journal['date']);
                    return ListTile(
                      title: Text(journal['title'] ?? 'Untitled'),
                      subtitle: Text(DateFormat.yMMMd().add_jm().format(date)),
                      onTap: () async {
                        await context.push('/journal/${journal['id']}');
                        _loadJournals();
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                           await ref.read(storageServiceProvider).deleteJournal(journal['id']);
                           _loadJournals();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/journal/new');
          _loadJournals();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
