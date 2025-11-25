import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/note_provider.dart';
import '../screens/add_note_screen.dart';
import '../../../shared/widgets/enhanced_screen_header.dart';
import '../../home/widgets/modern_note_card.dart';

class EnhancedNotesScreen extends ConsumerStatefulWidget {
  const EnhancedNotesScreen({super.key});

  @override
  ConsumerState<EnhancedNotesScreen> createState() => _EnhancedNotesScreenState();
}

class _EnhancedNotesScreenState extends ConsumerState<EnhancedNotesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notes = ref.watch(filteredNoteListProvider);
    final allNotes = ref.watch(noteProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            EnhancedScreenHeader(
              title: 'My Notes',
              subtitle: '${allNotes.length} notes • ${allNotes.where((n) => n.isPinned).length} pinned',
              icon: Icons.note_rounded,
              onActionTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddNoteScreen(),
                  ),
                );
                if (result == true) {
                  await ref.read(noteProvider.notifier).refresh();
                }
              },
              actionText: 'Add Note',
              actionIcon: Icons.add_rounded,
            ),

            const SizedBox(height: 20),

            // Search for notes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  ref.read(noteSearchQueryProvider.notifier).updateQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search your notes...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightMainText.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkCard
                      : const Color(0xFFF2F2F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkAccent.withValues(alpha: 0.2)
                          : const Color(0xFFFFE5D6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.primaryAccent,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.primaryAccent,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Notes List
            Expanded(
              child: notes.isEmpty
                  ? _buildEmptyState(theme, isDark)
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(noteProvider.notifier).refresh();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ModernNoteCard(
                              note: note,
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddNoteScreen(noteToEdit: note),
                                  ),
                                );
                                if (result == true) {
                                  await ref.read(noteProvider.notifier).refresh();
                                }
                              },
                              onEdit: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddNoteScreen(noteToEdit: note),
                                  ),
                                );
                                if (result == true) {
                                  await ref.read(noteProvider.notifier).refresh();
                                }
                              },
                              onDelete: () {
                                ref.read(noteProvider.notifier).deleteNote(note.id);
                              },
                              onTogglePin: () {
                                ref.read(noteProvider.notifier).togglePin(note.id);
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
                  await ref.read(noteProvider.notifier).refresh();
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
