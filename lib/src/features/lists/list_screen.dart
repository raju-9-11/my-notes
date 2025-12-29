
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../services/storage_service.dart';

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todo'),
            Tab(text: 'Wishlist'),
            Tab(text: 'Bucket List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GenericListTab(listName: 'todo'),
          GenericListTab(listName: 'wishlist'),
          GenericListTab(listName: 'bucketlist'),
        ],
      ),
    );
  }
}

class GenericListTab extends ConsumerStatefulWidget {
  final String listName;
  const GenericListTab({super.key, required this.listName});

  @override
  ConsumerState<GenericListTab> createState() => _GenericListTabState();
}

class _GenericListTabState extends ConsumerState<GenericListTab> {
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final storage = ref.read(storageServiceProvider);
    final items = await storage.getListItems(widget.listName);
    if (mounted) {
      setState(() {
        _items = items;
      });
    }
  }

  Future<void> _addItem() async {
    if (_controller.text.isEmpty) return;

    final storage = ref.read(storageServiceProvider);
    final item = {
      'id': const Uuid().v4(),
      'text': _controller.text,
      'completed': false,
    };

    await storage.saveListItem(widget.listName, item);
    _controller.clear();
    _loadItems();
  }

  Future<void> _toggleItem(Map<String, dynamic> item) async {
    final storage = ref.read(storageServiceProvider);
    item['completed'] = !item['completed'];
    await storage.saveListItem(widget.listName, item);
    _loadItems();
  }

  Future<void> _deleteItem(String id) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteListItem(widget.listName, id);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add to ${widget.listName}...',
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _addItem),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                leading: Checkbox(
                  value: item['completed'],
                  onChanged: (_) => _toggleItem(item),
                ),
                title: Text(
                  item['text'],
                  style: TextStyle(
                    decoration: item['completed'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(item['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
