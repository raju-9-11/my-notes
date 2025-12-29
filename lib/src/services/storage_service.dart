
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class StorageService {
  Future<void> init();
  Future<void> saveJournal(Map<String, dynamic> journal);
  Future<List<Map<String, dynamic>>> getJournals();
  Future<void> deleteJournal(String id);

  // Lists
  Future<void> saveListItem(String listName, Map<String, dynamic> item);
  Future<List<Map<String, dynamic>>> getListItems(String listName);
  Future<void> deleteListItem(String listName, String id);
}

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Initialize this in main');
});

class LocalStorageService implements StorageService {
  late Box _journalBox;
  late Box _listsBox;

  @override
  Future<void> init() async {
    _journalBox = await Hive.openBox('journals');
    _listsBox = await Hive.openBox('lists');
  }

  @override
  Future<void> saveJournal(Map<String, dynamic> journal) async {
    await _journalBox.put(journal['id'], journal);
  }

  @override
  Future<List<Map<String, dynamic>>> getJournals() async {
    return _journalBox.values.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> deleteJournal(String id) async {
    await _journalBox.delete(id);
  }

  @override
  Future<void> saveListItem(String listName, Map<String, dynamic> item) async {
    // We store lists as a map of listName -> List<Items> or simply prefix keys
    // simpler: key = listName_itemId
    await _listsBox.put('${listName}_${item['id']}', item);
  }

  @override
  Future<List<Map<String, dynamic>>> getListItems(String listName) async {
    final allKeys = _listsBox.keys.where((k) => k.toString().startsWith(listName)).toList();
    List<Map<String, dynamic>> items = [];
    for (var k in allKeys) {
      final data = _listsBox.get(k);
      if (data != null) {
        items.add(Map<String, dynamic>.from(data));
      }
    }
    return items;
  }

  @override
  Future<void> deleteListItem(String listName, String id) async {
    await _listsBox.delete('${listName}_$id');
  }
}
