import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_icon_button.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../models/user.dart';
import 'edit_profile_screen.dart';
import 'category_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);
    final isDark = theme.brightness == Brightness.dark;

    final canPop = Navigator.of(context).canPop();
    
    return currentUserAsync.when(
      data: (currentUser) => Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: canPop
            ? CustomIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).maybePop(),
                backgroundColor: Colors.transparent,
                iconColor: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(context, theme, currentUser, isDark),

            const SizedBox(height: 24),

            // Appearance Section
            _buildAppearanceSection(context, theme, ref, currentUser),

            const SizedBox(height: 24),

            // Notifications Section
            _buildNotificationsSection(context, theme, ref, currentUser),

            const SizedBox(height: 24),

            // Security Section
            _buildSecuritySection(context, theme, ref, currentUser),

            const SizedBox(height: 24),

            // Data Section
            _buildDataSection(context, theme, ref),

            const SizedBox(height: 24),

            // Categories Section
            _buildCategoriesSection(context, theme, ref),

            const SizedBox(height: 24),

            // About Section
            _buildAboutSection(context, theme),

            const SizedBox(height: 40),

            // Logout Button
            CustomButton(
              text: 'Logout',
              onPressed: () => _showLogoutConfirmation(context, ref),
              backgroundColor: AppColors.lightOverdue,
              textColor: AppColors.white,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    loading: () => Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        elevation: 0,
      ),
      body: const Center(child: CircularProgressIndicator()),
    ),
    error: (error, stack) => Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text('Error: $error'),
      ),
    ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ThemeData theme, User? currentUser, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkCard
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryAccent,
                backgroundImage: currentUser?.avatarPath != null
                    ? NetworkImage(currentUser!.avatarPath!)
                    : null,
                child: currentUser?.avatarPath == null
                    ? Text(
                        currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.name ?? 'User',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.email ?? 'user@example.com',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconButton(
                icon: Icons.edit,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
                backgroundColor: (isDark ? AppColors.darkAccent : AppColors.primaryAccent).withValues(alpha: 0.1),
                iconColor: isDark ? AppColors.darkAccent : AppColors.primaryAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ThemeData theme, WidgetRef ref, User? currentUser) {
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    
    return _buildSection(
      context,
      theme,
      'Appearance',
      [
        _buildSwitchTile(
          context,
          theme,
          'Dark Mode',
          'Use dark theme',
          Icons.dark_mode,
          themeMode == ThemeMode.dark,
          (value) {
            ref.read(themeProvider.notifier).toggleTheme();
          },
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildNotificationsSection(BuildContext context, ThemeData theme, WidgetRef ref, User? currentUser) {
    final isDark = theme.brightness == Brightness.dark;
    return _buildSection(
      context,
      theme,
      'Notifications',
      [
        _buildSwitchTile(
          context,
          theme,
          'Push Notifications',
          'Receive notifications for todos',
          Icons.notifications,
          currentUser?.notificationsEnabled ?? true,
          (value) {
            ref.read(profileProvider.notifier).updateNotificationSettings(enabled: value);
          },
        ),
        _buildListTile(
          context,
          theme,
          'Notification Time',
          '${currentUser?.notificationTime ?? 15} minutes before due',
          Icons.schedule,
          () {
            _showNotificationTimeDialog(context, ref, currentUser?.notificationTime ?? 15);
          },
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildSecuritySection(BuildContext context, ThemeData theme, WidgetRef ref, User? currentUser) {
    final isDark = theme.brightness == Brightness.dark;
    return _buildSection(
      context,
      theme,
      'Security',
      [
        _buildSwitchTile(
          context,
          theme,
          'Biometric Authentication',
          'Use fingerprint or face ID',
          Icons.fingerprint,
          currentUser?.biometricEnabled ?? false,
          (value) {
            if (value) {
              ref.read(profileProvider.notifier).enableBiometricAuth();
            } else {
              ref.read(profileProvider.notifier).disableBiometricAuth();
            }
          },
        ),
        _buildListTile(
          context,
          theme,
          'Change Password',
          'Update your password',
          Icons.lock,
          () {
            _showChangePasswordDialog(context, ref);
          },
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildDataSection(BuildContext context, ThemeData theme, WidgetRef ref) {
    final isDark = theme.brightness == Brightness.dark;
    return _buildSection(
      context,
      theme,
      'Data',
      [
        _buildListTile(
          context,
          theme,
          'Export Data',
          'Download your todos and notes',
          Icons.download,
          () {
            // TODO: Implement data export
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export feature coming soon!')),
            );
          },
        ),
        _buildListTile(
          context,
          theme,
          'Import Data',
          'Import todos from another app',
          Icons.upload,
          () {
            // TODO: Implement data import
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import feature coming soon!')),
            );
          },
        ),
        _buildListTile(
          context,
          theme,
          'Clear All Data',
          'Delete all your data permanently',
          Icons.delete_forever,
          () => _showClearDataConfirmation(context, ref),
          textColor: AppColors.lightOverdue,
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return _buildSection(
      context,
      theme,
      'About',
      [
        _buildListTile(
          context,
          theme,
          'Version',
          '1.0.0',
          Icons.info,
          null,
        ),
        _buildListTile(
          context,
          theme,
          'Privacy Policy',
          'Read our privacy policy',
          Icons.privacy_tip,
          () {
            // TODO: Open privacy policy
          },
        ),
        _buildListTile(
          context,
          theme,
          'Terms of Service',
          'Read our terms of service',
          Icons.description,
          () {
            // TODO: Open terms of service
          },
        ),
        _buildListTile(
          context,
          theme,
          'Contact Support',
          'Get help and support',
          Icons.support,
          () {
            // TODO: Open support
          },
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildCategoriesSection(BuildContext context, ThemeData theme, WidgetRef ref) {
    final isDark = theme.brightness == Brightness.dark;
    return _buildSection(
      context,
      theme,
      'Categories',
      [
        _buildListTile(
          context,
          theme,
          'Manage Categories',
          'Create and organize your categories',
          Icons.category_outlined,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CategoryManagementScreen(),
              ),
            );
          },
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildSection(BuildContext context, ThemeData theme, String title, List<Widget> children, {bool? isDark}) {
    final isDarkMode = isDark ?? (theme.brightness == Brightness.dark);
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkCard
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.darkMainText : AppColors.lightMainText,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: AppColors.secondaryAccent),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white : AppColors.lightMainText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.white.withValues(alpha: 0.75) : AppColors.lightMainText.withValues(alpha: 0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.secondaryAccent,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    Color? textColor,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: AppColors.secondaryAccent),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor ?? (isDark ? AppColors.white : AppColors.lightMainText),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.white.withValues(alpha: 0.75) : AppColors.lightMainText.withValues(alpha: 0.7),
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: (isDark ? AppColors.white : AppColors.lightMainText).withValues(alpha: 0.5),
            )
          : null,
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(logoutProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: AppColors.primaryAccent,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: AppColors.lightOverdue,
                    ),
                  );
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text) {
                ref.read(profileProvider.notifier).changePassword(
                  oldPasswordController.text,
                  newPasswordController.text,
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: AppColors.lightOverdue,
                  ),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showNotificationTimeDialog(BuildContext context, WidgetRef ref, int currentTime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(6, (index) {
            final time = (index + 1) * 5; // 5, 10, 15, 20, 25, 30 minutes
            return RadioListTile<int>(
              title: Text('$time minutes before due'),
              value: time,
              groupValue: currentTime,
              onChanged: (value) {
                if (value != null) {
                  ref.read(profileProvider.notifier).updateNotificationSettings(
                    timeBeforeDue: value,
                  );
                  Navigator.of(context).pop();
                }
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your todos, notes, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(profileProvider.notifier).deleteAccount();
              Navigator.of(context).pop();
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
