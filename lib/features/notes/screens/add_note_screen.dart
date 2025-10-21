import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/note.dart';
import '../../../services/database_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/providers/category_provider.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  final Note? noteToEdit;

  const AddNoteScreen({super.key, this.noteToEdit});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPinned = false;
  bool _isLocked = false;
  bool _isLoading = false;
  String _selectedCategory = 'Personal';

  @override
  void initState() {
    super.initState();
    if (widget.noteToEdit != null) {
      _titleController.text = widget.noteToEdit!.title;
      _contentController.text = widget.noteToEdit!.content;
      _isPinned = widget.noteToEdit!.isPinned;
      _isLocked = widget.noteToEdit!.isLocked;
      _selectedCategory = widget.noteToEdit!.category ?? 'Personal';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final note = widget.noteToEdit?.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isPinned: _isPinned,
        isLocked: _isLocked,
        category: _selectedCategory.isEmpty ? 'Personal' : _selectedCategory,
        updatedAt: DateTime.now(),
      ) ?? Note(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isPinned: _isPinned,
        isLocked: _isLocked,
        category: _selectedCategory.isEmpty ? 'Personal' : _selectedCategory,
      );

      await DatabaseService.saveNote(note);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.noteToEdit != null 
                ? 'Note updated successfully' 
                : 'Note created successfully'),
            backgroundColor: AppColors.grassGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: AppColors.lightOverdue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNote() async {
    if (widget.noteToEdit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${widget.noteToEdit!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteNote(widget.noteToEdit!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note deleted successfully'),
              backgroundColor: AppColors.grassGreen,
            ),
          );
          Navigator.of(context).pop();
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
      appBar: AppBar(
        title: Text(widget.noteToEdit != null ? 'Edit Note' : 'New Note'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.darkMainText : AppColors.lightMainText,
        actions: [
          if (widget.noteToEdit != null)
            IconButton(
              onPressed: _deleteNote,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              CustomTextField(
                label: 'Title',
                hint: 'Enter note title',
                controller: _titleController,
                textInputAction: TextInputAction.next,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Category Selection
              _buildCategorySelection(theme, isDark),

              const SizedBox(height: 20),

              // Content Field
              CustomTextField(
                label: 'Content',
                hint: 'Write your note here...',
                controller: _contentController,
                maxLines: 10,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 20),

              // Options
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                            color: isDark 
                                ? AppColors.darkSecondaryText.withValues(alpha: 0.2)
                                : AppColors.lightMainText.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Options',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Pin Note
                    SwitchListTile(
                      title: const Text('Pin Note'),
                      subtitle: const Text('Keep this note at the top'),
                      value: _isPinned,
                      onChanged: (value) {
                        setState(() {
                          _isPinned = value;
                        });
                      },
                      activeColor: AppColors.primaryAccent,
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    // Lock Note
                    SwitchListTile(
                      title: const Text('Lock Note'),
                      subtitle: const Text('Require authentication to view'),
                      value: _isLocked,
                      onChanged: (value) {
                        setState(() {
                          _isLocked = value;
                        });
                      },
                      activeColor: AppColors.primaryAccent,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: widget.noteToEdit != null ? 'Update Note' : 'Save Note',
                onPressed: _isLoading ? null : _saveNote,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection(ThemeData theme, bool isDark) {
    final categories = ref.watch(categoryProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? AppColors.darkSecondaryText.withValues(alpha: 0.2)
              : AppColors.lightMainText.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = _selectedCategory == category.name;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category.name;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondaryAccent.withValues(alpha: 0.2)
                        : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondaryAccent
                          : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? AppColors.secondaryAccent
                              : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

