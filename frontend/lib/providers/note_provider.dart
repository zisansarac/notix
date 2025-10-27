import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_model.dart';
import '../models/note_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final noteProvider =
    StateNotifierProvider<NoteNotifier, AsyncValue<List<NoteModel>>>((ref) {
      final apiService = ref.watch(apiServiceProvide);
      final authState = ref.watch(authProvider);
      return NoteNotifier(apiService, authState);
    });

class NoteNotifier extends StateNotifier<AsyncValue<List<NoteModel>>> {
  final ApiService _apiService;
  final UserModel? _currentUser;

  NoteNotifier(this._apiService, this._currentUser)
    : super(const AsyncValue.loading()) {
    if (_currentUser != null) {
      fetchNotes();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> fetchNotes() async {
    if (state.isLoading || _currentUser == null) return;

    state = const AsyncValue.loading();

    try {
      final response = await _apiService.dio.get('/notes');

      final notes = (response.data as List)
          .map((json) => NoteModel.fromJson(json))
          .toList();

      state = AsyncValue.data(notes);
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? 'Notları yükleyemedik.';
      state = AsyncValue.error(errorMsg, StackTrace.current);
    }
  }

  Future<void> createNote(String title, String content) async {
    try {
      final response = await _apiService.dio.post(
        '/notes',
        data: {'title': title, 'content': content},
      );

      final newNote = NoteModel.fromJson(response.data);

      final currentNotes = state.value ?? [];
      state = AsyncValue.data([newNote, ...currentNotes]);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Not oluşturma başarısız.';
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      final response = await _apiService.dio.put(
        '/notes/${note.id}',
        data: {
          'title': note.title,
          'content': note.content,
          'isCompleted': note.isCompleted,
        },
      );

      final updatedNote = NoteModel.fromJson(response.data);

      final currentNotes = state.value ?? [];
      final updatedList = currentNotes.map((n) {
        return n.id == updatedNote.id ? updatedNote : n;
      }).toList();

      state = AsyncValue.data(updatedList);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Not güncelleme başarısız.';
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _apiService.dio.delete('/notes/$id');

      final currentNotes = state.value ?? [];
      final updatedList = currentNotes.where((n) => n.id != id).toList();

      state = AsyncValue.data(updatedList);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Not silme başarısız.';
    }
  }
}
