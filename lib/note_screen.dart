import 'dart:convert';
import 'package:flutter/material.dart';
import 'storage_service.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<Map<String, String>> notes = [];
  final storage = StorageService();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    notes = await storage.loadNotes();
    setState(() {});
  }

  void addOrEditNote({Map<String, String>? existingNote, int? index}) {
    final titleController = TextEditingController(
      text: existingNote?['title'] ?? '',
    );
    final contentController = TextEditingController(
      text: existingNote?['content'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(index == null ? "Nova Nota" : "Editar Nota"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: "Conteúdo"),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();

                  if (title.isEmpty && content.isEmpty) return;

                  final newNote = {"title": title, "content": content};

                  setState(() {
                    if (index == null) {
                      notes.add(newNote);
                    } else {
                      notes[index] = newNote;
                    }
                  });

                  await storage.saveNotes(notes);
                  Navigator.pop(context);
                },
                child: const Text("Salvar"),
              ),
            ],
          ),
    );
  }

  void deleteNote(int index) async {
    setState(() => notes.removeAt(index));
    await storage.saveNotes(notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Notas")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditNote(),
        child: const Icon(Icons.add),
      ),
      body:
          notes.isEmpty
              ? const Center(child: Text("Nenhuma nota."))
              : Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  itemCount: notes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 colunas
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return GestureDetector(
                      onTap:
                          () => addOrEditNote(existingNote: note, index: index),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                note['content'] ?? '',
                                overflow: TextOverflow.fade,
                                softWrap: true,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                onPressed: () => deleteNote(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
