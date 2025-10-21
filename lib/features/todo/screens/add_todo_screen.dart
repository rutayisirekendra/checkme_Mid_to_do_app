import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_icon_button.dart';
import '../../../shared/providers/todo_provider.dart';
import '../../../models/todo.dart';
import '../widgets/category_selector.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  final Todo? todoToEdit;

  const AddTodoScreen({
    super.key,
    this.todoToEdit,
  });

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Priority _selectedPriority = Priority.medium;
  String? _selectedCategoryId;
  DateTime? _selectedDueDate;
  bool _isLoading = false;
  final List<Todo> _subtasks = [];
  final List<TextEditingController> _subtaskControllers = [];


  @override
  void initState() {
    super.initState();
    if (widget.todoToEdit != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final todo = widget.todoToEdit!;
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;
    _selectedPriority = todo.priority;
    _selectedCategoryId = todo.category;
    _selectedDueDate = todo.dueDate;
    _subtasks.addAll(todo.subtasks);
    _subtaskControllers.addAll(
      todo.subtasks.map((subtask) => TextEditingController(text: subtask.title))
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(widget.todoToEdit != null ? 'Edit Todo' : 'Add Todo'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        elevation: 0,
        leading: CustomIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: Colors.transparent,
          iconColor: isDark ? AppColors.darkMainText : AppColors.lightMainText,
        ),
        actions: [
          if (widget.todoToEdit != null)
            CustomIconButton(
              icon: Icons.delete,
              onPressed: _showDeleteConfirmation,
              backgroundColor: Colors.transparent,
              iconColor: AppColors.lightOverdue,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              CustomTextField(
                label: 'Title',
                hint: 'Enter todo title',
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

              // Description Field
              CustomTextField(
                label: 'Description',
                hint: 'Enter description (optional)',
                controller: _descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 20),

              // Priority Selection
              _buildPrioritySelection(theme, isDark),

              const SizedBox(height: 20),

              // Category Selection
              CategorySelector(
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (categoryId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Due Date Selection
              _buildDueDateSelection(theme, isDark),

              const SizedBox(height: 20),

              // Subtasks Section
              _buildSubtasksSection(theme),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: widget.todoToEdit != null ? 'Update' : 'Create',
                      onPressed: _isLoading ? null : _handleSave,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.lightMainText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: Priority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? _getPriorityColor(priority).withValues(alpha: 0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected 
                          ? _getPriorityColor(priority)
                          : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        color: isSelected 
                            ? _getPriorityColor(priority)
                            : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.5),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPriorityText(priority),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected 
                              ? _getPriorityColor(priority)
                              : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildDueDateSelection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.lightMainText,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDueDate != null
                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      : 'Select due date (optional)',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _selectedDueDate != null 
                        ? AppColors.lightMainText
                        : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                if (_selectedDueDate != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtasksSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryAccent.withValues(alpha: 0.08),
            AppColors.secondaryAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.list_alt_rounded,
                  color: AppColors.primaryAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subtasks',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Break down your todo into smaller tasks',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? AppColors.darkSecondaryText 
                            : AppColors.lightMainText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryAccent,
                      AppColors.secondaryAccent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Subtasks list
          if (_subtasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.03),
                    (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.01),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.08),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.add_task_rounded,
                        color: AppColors.primaryAccent,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No subtasks yet',
              style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark 
                            ? AppColors.darkMainText 
                            : AppColors.lightMainText,
                fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Break down your todo into manageable steps',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark 
                            ? AppColors.darkSecondaryText 
                            : AppColors.lightMainText.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Tap "Add" to get started',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._subtasks.asMap().entries.map((entry) {
              final index = entry.key;
              final subtask = entry.value;
              return _buildSubtaskItem(index, subtask, theme);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(int index, Todo subtask, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = subtask.isCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [
                  AppColors.grassGreen.withValues(alpha: 0.15),
                  AppColors.grassGreen.withValues(alpha: 0.08),
                ]
              : [
                  (isDark ? AppColors.darkCard : AppColors.white).withValues(alpha: 0.95),
                  (isDark ? AppColors.darkCard : AppColors.white).withValues(alpha: 0.85),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? AppColors.grassGreen.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? AppColors.grassGreen.withValues(alpha: 0.2)
                : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: isCompleted
                ? AppColors.grassGreen.withValues(alpha: 0.1)
                : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox with enhanced styling
          Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.grassGreen
                  : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted
                    ? AppColors.grassGreen
                    : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Checkbox(
              value: isCompleted,
              onChanged: (value) {
                setState(() {
                  _subtasks[index] = subtask.copyWith(isCompleted: value ?? false);
                });
              },
              activeColor: AppColors.grassGreen,
              checkColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Enhanced text field with beautiful styling
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCompleted
                      ? [
                          AppColors.grassGreen.withValues(alpha: 0.08),
                          AppColors.grassGreen.withValues(alpha: 0.04),
                        ]
                      : [
                          (isDark ? AppColors.darkCard : AppColors.white).withValues(alpha: 0.9),
                          (isDark ? AppColors.darkCard : AppColors.white).withValues(alpha: 0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.grassGreen.withValues(alpha: 0.3)
                      : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCompleted
                        ? AppColors.grassGreen.withValues(alpha: 0.1)
                        : (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _subtaskControllers[index],
                decoration: InputDecoration(
                  hintText: 'Enter subtask title...',
                  hintStyle: TextStyle(
                    color: isDark 
                        ? AppColors.darkSecondaryText 
                        : AppColors.lightMainText.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: isCompleted
                          ? AppColors.grassGreen
                          : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText).withValues(alpha: 0.6),
                    ),
                  ),
                ),
                style: TextStyle(
                  color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.grassGreen,
                  decorationThickness: 2,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {
                    _subtasks[index] = subtask.copyWith(title: value);
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Delete button with enhanced styling
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightOverdue.withValues(alpha: 0.1),
                  AppColors.lightOverdue.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.lightOverdue.withValues(alpha: 0.2),
              ),
            ),
            child: IconButton(
              onPressed: () => _removeSubtask(index),
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: AppColors.lightOverdue,
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSubtask() {
    setState(() {
      final newSubtask = Todo(
        title: '',
        parentId: widget.todoToEdit?.id,
      );
      _subtasks.add(newSubtask);
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final todo = Todo(
        id: widget.todoToEdit?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        category: _selectedCategoryId ?? 'general',
        dueDate: _selectedDueDate,
        subtasks: _subtasks.where((subtask) => subtask.title.isNotEmpty).toList(),
      );

      if (widget.todoToEdit != null) {
        await ref.read(todoListProvider.notifier).updateTodo(todo);
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Todo updated successfully!'),
            backgroundColor: AppColors.grassGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
          ),
        );
        }
      } else {
        await ref.read(todoListProvider.notifier).addTodo(todo);
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Todo created successfully!'),
            backgroundColor: AppColors.grassGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
          ),
        );
        }
      }

      if (mounted) {
      Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.lightOverdue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(todoListProvider.notifier).deleteTodo(widget.todoToEdit!.id);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppColors.grassGreen;
      case Priority.medium:
        return AppColors.primaryAccent;
      case Priority.high:
        return AppColors.secondaryAccent;
      case Priority.urgent:
        return AppColors.lightOverdue;
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.keyboard_arrow_down;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.keyboard_arrow_up;
      case Priority.urgent:
        return Icons.priority_high;
    }
  }
}
