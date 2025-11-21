import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../services/database_service.dart';
import 'auth_provider.dart';

// Note list provider
final noteListProvider = StateNotifierProvider<NoteListNotifier, List<Note>>((ref) {
  return NoteListNotifier(ref);
});

class NoteListNotifier extends StateNotifier<List<Note>> {
  final Ref _ref;
  
  NoteListNotifier(this._ref) : super([]) {
    _loadNotes();
    // Listen to auth changes and reload notes when user changes
    _ref.listen(currentUserProvider, (previous, next) {
      _loadNotes();
    });
  }

  String? get _currentUserId {
    final userAsync = _ref.read(currentUserProvider);
    return userAsync.value?.id;
  }

  void _loadNotes() {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      state = [];
      return;
    }
    state = DatabaseService.getAllNotes(userId: userId);
  }

  Future<void> addNote(Note note) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    
    // Ensure note has userId set
    final noteWithUser = note.userId.isEmpty 
        ? note.copyWith(userId: userId) 
        : note;
    
    await DatabaseService.saveNote(noteWithUser);
    _loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await DatabaseService.saveNote(note);
    _loadNotes();
  }

  Future<void> deleteNote(String noteId) async {
    await DatabaseService.deleteNote(noteId);
    _loadNotes();
  }

  Future<void> togglePin(String noteId) async {
    final noteIndex = state.indexWhere((note) => note.id == noteId);
    if (noteIndex != -1) {
      final note = state[noteIndex];
      final updatedNote = note.copyWith(isPinned: !note.isPinned);
      await DatabaseService.saveNote(updatedNote);
      _loadNotes();
    }
  }

  Future<void> refresh() async {
    _loadNotes();
  }
}

// Alias for backwards compatibility
final noteProvider = noteListProvider;
