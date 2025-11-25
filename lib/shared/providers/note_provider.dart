import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../services/database_service.dart';
import 'auth_provider.dart';

// Note list provider
final noteListProvider = StateNotifierProvider<NoteListNotifier, List<Note>>((ref) {
  return NoteListNotifier(ref);
});

// Note search query provider
final noteSearchQueryProvider = StateNotifierProvider<NoteSearchQueryNotifier, String>((ref) {
  return NoteSearchQueryNotifier();
});

// Filtered note list provider
final filteredNoteListProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(noteListProvider);
  final searchQuery = ref.watch(noteSearchQueryProvider);

  List<Note> filteredNotes = notes;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filteredNotes = filteredNotes.where((note) =>
        note.title.toLowerCase().contains(query) ||
        note.content.toLowerCase().contains(query) ||
        (note.category?.toLowerCase().contains(query) ?? false)).toList();
  }

  // Sort by pinned status and then by creation date
  filteredNotes.sort((a, b) {
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;
    return b.createdAt.compareTo(a.createdAt);
  });

  return filteredNotes;
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
    
    try {
      final notes = DatabaseService.getAllNotes(userId: userId);
      state = notes;
    } catch (e) {
      // Handle database errors gracefully
      print('Error loading notes: $e');
      state = [];
    }
  }

  Future<void> addNote(Note note) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    
    // Ensure note has userId set
    final noteWithUser = note.userId.isEmpty 
        ? note.copyWith(userId: userId) 
        : note;
    
    try {
      await DatabaseService.saveNote(noteWithUser);
      _loadNotes(); // Reload from database
    } catch (e) {
      throw Exception('Failed to save note: $e');
    }
  }

  Future<void> updateNote(Note note) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    
    try {
      await DatabaseService.saveNote(note);
      _loadNotes(); // Reload from database
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await DatabaseService.deleteNote(noteId);
      _loadNotes(); // Reload from database
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<void> togglePin(String noteId) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    
    try {
      final noteIndex = state.indexWhere((note) => note.id == noteId);
      if (noteIndex != -1) {
        final note = state[noteIndex];
        final updatedNote = note.copyWith(isPinned: !note.isPinned);
        await DatabaseService.saveNote(updatedNote);
        _loadNotes(); // Reload from database
      }
    } catch (e) {
      throw Exception('Failed to toggle note pin: $e');
    }
  }

  Future<void> refresh() async {
    _loadNotes();
  }
}

// Note search query notifier
class NoteSearchQueryNotifier extends StateNotifier<String> {
  NoteSearchQueryNotifier() : super('');

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// Alias for backwards compatibility
final noteProvider = noteListProvider;
