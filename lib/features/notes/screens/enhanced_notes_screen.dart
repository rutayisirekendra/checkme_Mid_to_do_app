import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/note.dart';
import '../../../services/database_service.dart';
import '../screens/add_note_screen.dart';
import '../../../shared/widgets/enhanced_screen_header.dart';
import '../../home/widgets/enhanced_note_card.dart';

class EnhancedNotesScreen extends ConsumerStatefulWidget {
  const EnhancedNotesScreen({super.key});

  @override
  ConsumerState<EnhancedNotesScreen> createState() => _EnhancedNotesScreenState();
}

class _EnhancedNotesScreenState extends ConsumerState<EnhancedNotesScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = DatabaseService.getAllNotes();
      if (mounted) {
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notes: $e'),
            backgroundColor: AppColors.lightOverdue,
          ),
        );
      }
    }
  }

  Future<void> _editNote(Note note) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(noteToEdit: note),
      ),
    );
    if (result == true) {
      _loadNotes();
    }
  }

  Future<void> _showDeleteConfirmation(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.lightOverdue,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteNote(note.id);
        _loadNotes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note deleted successfully'),
              backgroundColor: AppColors.grassGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting note: $e'),
              backgroundColor: AppColors.lightOverdue,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
        children: [
          // Enhanced Header
          EnhancedScreenHeader(
            title: 'My Notes',
            subtitle: '${_notes.length} notes • ${_notes.where((n) => n.isPinned).length} pinned',
            icon: Icons.note_rounded,
            onActionTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddNoteScreen(),
                ),
              );
              if (result == true) {
                _loadNotes();
              }
            },
            actionText: 'Add Note',
            actionIcon: Icons.add_rounded,
          ),

          // Notes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? _buildEmptyState(theme, isDark)
                    : RefreshIndicator(
                        onRefresh: _loadNotes,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EnhancedNoteCard(
                                note: note,
                                onTap: () => _editNote(note),
                                onEdit: () => _editNote(note),
                                onDelete: () => _showDeleteConfirmation(note),
                                onToggleDone: (updated) {
                                  setState(() {
                                    _notes[index] = updated;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryAccent.withValues(alpha: 0.1),
                    AppColors.secondaryAccent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.note_rounded,
                size: 64,
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No notes yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first note',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddNoteScreen(),
                  ),
                );
                if (result == true) {
                  _loadNotes();
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
