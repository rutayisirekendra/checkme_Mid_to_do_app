import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_icon_button.dart';
import '../../../shared/providers/todo_provider.dart';

class SearchFilterWidget extends ConsumerStatefulWidget {
  const SearchFilterWidget({super.key});

  @override
  ConsumerState<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends ConsumerState<SearchFilterWidget> {
  final _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark; // used later
    final currentFilter = ref.watch(todoFilterProvider);
    final currentSort = ref.watch(sortByProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search Bar
          SearchTextField(
            controller: _searchController,
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            onClear: () {
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
          ),

          const SizedBox(height: 12),

          // Filter and Sort Row
          Row(
            children: [
              // Filter Button
              Expanded(
                child: CustomButton(
                  text: _getFilterText(currentFilter),
                  onPressed: () => _showFilterBottomSheet(context, currentFilter),
                  isOutlined: true,
                  icon: const Icon(Icons.filter_list, size: 16),
                ),
              ),

              const SizedBox(width: 12),

              // Sort Button
              Expanded(
                child: CustomButton(
                  text: _getSortText(currentSort),
                  onPressed: () => _showSortBottomSheet(context, currentSort),
                  isOutlined: true,
                  icon: const Icon(Icons.sort, size: 16),
                ),
              ),

              const SizedBox(width: 12),

              // Expand Button
              CustomIconButton(
                icon: _isExpanded ? Icons.expand_less : Icons.expand_more,
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.1),
                iconColor: AppColors.primaryAccent,
              ),
            ],
          ),

          // Expanded Filters
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            _buildQuickFilters(context, currentFilter),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context, TodoFilter currentFilter) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TodoFilter.values.map((filter) {
        final isSelected = currentFilter == filter;
        return GestureDetector(
          onTap: () {
            ref.read(todoFilterProvider.notifier).state = filter;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primaryAccent
                  : AppColors.lightMainText.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primaryAccent
                    : AppColors.lightMainText.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getFilterIcon(filter),
                  size: 16,
                  color: isSelected 
                      ? AppColors.white
                      : AppColors.lightMainText,
                ),
                const SizedBox(width: 4),
                Text(
                  _getFilterText(filter),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? AppColors.white
                        : AppColors.lightMainText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showFilterBottomSheet(BuildContext context, TodoFilter currentFilter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Todos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.lightMainText,
              ),
            ),
            const SizedBox(height: 20),
            ...TodoFilter.values.map((filter) {
              return RadioListTile<TodoFilter>(
                title: Text(_getFilterText(filter)),
                subtitle: Text(_getFilterDescription(filter)),
                value: filter,
                groupValue: currentFilter,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(todoFilterProvider.notifier).state = value;
                    Navigator.of(context).pop();
                  }
                },
                activeColor: AppColors.primaryAccent,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context, TodoSortBy currentSort) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Todos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.lightMainText,
              ),
            ),
            const SizedBox(height: 20),
            ...TodoSortBy.values.map((sort) {
              return RadioListTile<TodoSortBy>(
                title: Text(_getSortText(sort)),
                subtitle: Text(_getSortDescription(sort)),
                value: sort,
                groupValue: currentSort,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(sortByProvider.notifier).state = value;
                    Navigator.of(context).pop();
                  }
                },
                activeColor: AppColors.primaryAccent,
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getFilterText(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.pending:
        return 'Pending';
      case TodoFilter.completed:
        return 'Completed';
      case TodoFilter.overdue:
        return 'Overdue';
      case TodoFilter.today:
        return 'Today';
    }
  }

  String _getFilterDescription(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'Show all todos';
      case TodoFilter.pending:
        return 'Show only incomplete todos';
      case TodoFilter.completed:
        return 'Show only completed todos';
      case TodoFilter.overdue:
        return 'Show only overdue todos';
      case TodoFilter.today:
        return 'Show todos due today';
    }
  }

  IconData _getFilterIcon(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return Icons.list;
      case TodoFilter.pending:
        return Icons.schedule;
      case TodoFilter.completed:
        return Icons.check_circle;
      case TodoFilter.overdue:
        return Icons.warning;
      case TodoFilter.today:
        return Icons.today;
    }
  }

  String _getSortText(TodoSortBy sort) {
    switch (sort) {
      case TodoSortBy.dueDate:
        return 'Due Date';
      case TodoSortBy.priority:
        return 'Priority';
      case TodoSortBy.createdDate:
        return 'Created';
      case TodoSortBy.title:
        return 'Title';
    }
  }

  String _getSortDescription(TodoSortBy sort) {
    switch (sort) {
      case TodoSortBy.dueDate:
        return 'Sort by due date';
      case TodoSortBy.priority:
        return 'Sort by priority level';
      case TodoSortBy.createdDate:
        return 'Sort by creation date';
      case TodoSortBy.title:
        return 'Sort alphabetically';
    }
  }
}
