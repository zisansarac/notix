import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(noteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notix Notlarım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteModal(context, ref, null),
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        onRefresh: () => ref.read(noteProvider.notifier).fetchNotes(),

        child: notesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Hata: $error\nYenilemek için aşağı çekin.')),
          data: (notes) {
            if (notes.isEmpty) {
              return const Center(
                child: Text('Henüz notunuz yok. Yeni bir not ekleyin.'),
              );
            }
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(note: note);
              },
            );
          },
        ),
      ),
    );
  }

  void _showNoteModal(BuildContext context, WidgetRef ref, NoteModel? note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: NoteForm(note: note),
      ),
    );
  }
}

class NoteCard extends ConsumerWidget {
  final NoteModel note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 2,
      child: ListTile(
        title: Text(
          note.title,
          style: TextStyle(
            decoration: note.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          note.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        leading: Checkbox(
          value: note.isCompleted,
          onChanged: (bool? newValue) async {
            if (newValue != null) {
              await ref
                  .read(noteProvider.notifier)
                  .updateNote(note.copyWith(isCompleted: newValue));
            }
          },
        ),

        onTap: () => (context as Element)
            .findAncestorWidgetOfExactType<NotesScreen>()
            ?._showNoteModal(context, ref, note),

        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Silme Onayı'),
                content: const Text(
                  'Bu notu silmek istediğinizden emin misiniz?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Sil'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              ref.read(noteProvider.notifier).deleteNote(note.id);
            }
          },
        ),
      ),
    );
  }
}

class NoteForm extends ConsumerStatefulWidget {
  final NoteModel? note;
  const NoteForm({super.key, this.note});

  @override
  ConsumerState<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _title = widget.note?.title ?? '';
    _content = widget.note?.content ?? '';
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      if (widget.note == null) {
        await ref.read(noteProvider.notifier).createNote(_title, _content);
      } else {
        final updatedNote = widget.note!.copyWith(
          title: _title,
          content: _content,
        );
        await ref.read(noteProvider.notifier).updateNote(updatedNote);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.note == null ? 'Yeni Not Oluştur' : 'Notu Düzenle',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 15),

          TextFormField(
            initialValue: _title,
            decoration: const InputDecoration(labelText: 'Başlık'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Başlık zorunludur.' : null,
            onSaved: (val) => _title = val!,
          ),

          TextFormField(
            initialValue: _content,
            decoration: const InputDecoration(labelText: 'İçerik'),
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            validator: (val) =>
                val == null || val.isEmpty ? 'İçerik zorunludur.' : null,
            onSaved: (val) => _content = val!,
          ),

          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.note == null ? 'Kaydet' : 'Güncelle'),
            ),
        ],
      ),
    );
  }
}
