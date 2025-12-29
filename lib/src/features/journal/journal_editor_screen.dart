
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:uuid/uuid.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;
import '../../services/storage_service.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  final String? journalId;
  const JournalEditorScreen({super.key, this.journalId});

  @override
  ConsumerState<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _quillController = quill.QuillController.basic();
  final _drawingController = DrawingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  bool _isDrawingMode = false;

  // OCR related
  final mlkit.DigitalInkRecognizer _digitalInkRecognizer = mlkit.DigitalInkRecognizer(languageCode: 'en');

  @override
  void initState() {
    super.initState();
    _loadJournal();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _drawingController.dispose();
    _digitalInkRecognizer.close();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadJournal() async {
    if (widget.journalId == null) return;

    final storage = ref.read(storageServiceProvider);
    final journals = await storage.getJournals();
    final journal = journals.firstWhere((element) => element['id'] == widget.journalId, orElse: () => {});

    if (journal.isNotEmpty) {
      _titleController.text = journal['title'] ?? '';

      if (journal['content'] != null) {
        final json = jsonDecode(journal['content']);
        _quillController.document = quill.Document.fromJson(json);
      }
    }
  }

  Future<void> _save() async {
    final storage = ref.read(storageServiceProvider);
    final id = widget.journalId ?? const Uuid().v4();

    final content = jsonEncode(_quillController.document.toDelta().toJson());

    await storage.saveJournal({
      'id': id,
      'title': _titleController.text,
      'content': content,
      'date': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  Future<void> _performOCR() async {
    // This is a placeholder for the actual OCR logic.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OCR: Processing handwriting... (Mock)')));

    // Simulate result
    await Future.delayed(const Duration(seconds: 1));
    const recognizedText = "Recognized Text from Drawing";

    // Append to Quill
    _quillController.document.insert(_quillController.document.length - 1, '\n$recognizedText');
    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OCR: Text added to document')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
          IconButton(
            icon: Icon(_isDrawingMode ? Icons.text_fields : Icons.brush),
            onPressed: () {
              setState(() {
                _isDrawingMode = !_isDrawingMode;
              });
            },
          ),
          if (_isDrawingMode)
             IconButton(
              icon: const Icon(Icons.abc),
              tooltip: 'Convert to Text',
              onPressed: _performOCR,
            ),
        ],
      ),
      body: _isDrawingMode
          ? DrawingBoard(
              controller: _drawingController,
              background: Container(color: Colors.white),
            )
          : Column(
              children: [
                quill.QuillSimpleToolbar(
                  controller: _quillController,
                ),
                Expanded(
                  child: quill.QuillEditor.basic(
                    controller: _quillController,
                  ),
                ),
              ],
            ),
    );
  }
}
