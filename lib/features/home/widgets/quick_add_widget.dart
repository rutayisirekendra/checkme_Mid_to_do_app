import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
// import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_icon_button.dart';
import '../../../shared/providers/todo_provider.dart';
import '../../../models/todo.dart';

class QuickAddWidget extends ConsumerStatefulWidget {
  const QuickAddWidget({super.key});

  @override
  ConsumerState<QuickAddWidget> createState() => _QuickAddWidgetState();
}

class _QuickAddWidgetState extends ConsumerState<QuickAddWidget> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? 120 : 60,
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkMainText.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Quick Add Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    onTap: () {
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _addQuickTodo(value.trim());
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Quick add a todo...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightMainText.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightMainText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CustomIconButton(
                  icon: Icons.add,
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      _addQuickTodo(_textController.text.trim());
                    }
                  },
                  backgroundColor: AppColors.primaryAccent,
                  iconColor: AppColors.white,
                  size: 40,
                ),
              ],
            ),

            // Expanded Options
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Add with Details',
                      onPressed: () {
                        // TODO: Navigate to full add todo screen
                        Navigator.of(context).pushNamed('/add-todo');
                      },
                      isOutlined: true,
                      isFullWidth: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    text: 'Cancel',
                    onPressed: () {
                      setState(() {
                        _isExpanded = false;
                        _textController.clear();
                        _focusNode.unfocus();
                      });
                    },
                    isOutlined: true,
                    isFullWidth: false,
                    backgroundColor: Colors.transparent,
                    textColor: AppColors.lightMainText.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addQuickTodo(String title) {
    if (title.isEmpty) return;

    final todo = Todo(
      title: title,
      description: '',
      category: 'Quick Add',
      priority: Priority.medium,
    );

    ref.read(todoListProvider.notifier).addTodo(todo);

    // Clear and collapse
    _textController.clear();
    setState(() {
      _isExpanded = false;
    });
    _focusNode.unfocus();

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added: $title'),
        backgroundColor: AppColors.grassGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
