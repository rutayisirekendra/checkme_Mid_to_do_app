import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/note.dart';
import '../../../services/database_service.dart';
// unused imports removed
import '../../../features/home/widgets/enhanced_note_card.dart';
import 'add_note_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final notes = DatabaseService.getAllNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
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

  Future<void> _deleteNote(Note note) async {
    try {
      await DatabaseService.deleteNote(note.id);
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted successfully'),
          backgroundColor: AppColors.grassGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting note: $e'),
          backgroundColor: AppColors.lightOverdue,
        ),
      );
    }
  }

  void _showDeleteConfirmation(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteNote(note);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(noteToEdit: note),
      ),
    ).then((_) => _loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        elevation: 0,
        foregroundColor: isDark ? AppColors.darkMainText : AppColors.lightMainText,
        actions: [
          IconButton(
            onPressed: _loadNotes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState(theme, isDark)
              : _buildNotesList(theme, isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          ).then((_) => _loadNotes());
        },
        backgroundColor: AppColors.secondaryAccent,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 80,
            color: isDark 
                ? AppColors.darkMainText.withValues(alpha: 0.3)
                : AppColors.lightMainText.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark 
                  ? AppColors.darkMainText.withValues(alpha: 0.6)
                  : AppColors.lightMainText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first note',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark 
                  ? AppColors.darkMainText.withValues(alpha: 0.4)
                  : AppColors.lightMainText.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(ThemeData theme, bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return EnhancedNoteCard(
            note: note,
            onTap: () => _editNote(note),
            onEdit: () => _editNote(note),
            onDelete: () => _showDeleteConfirmation(note),
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(Note note, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          note.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark 
                      ? AppColors.darkSecondaryText 
                      : AppColors.lightMainText.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isDark 
                      ? AppColors.darkSecondaryText 
                      : AppColors.lightMainText.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(note.updatedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? AppColors.darkSecondaryText 
                        : AppColors.lightMainText.withValues(alpha: 0.5),
                  ),
                ),
                if (note.isPinned) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.push_pin,
                    size: 14,
                    color: AppColors.secondaryAccent,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editNote(note);
                break;
              case 'delete':
                _showDeleteConfirmation(note);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.lightOverdue),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.lightOverdue)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _editNote(note),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

