import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _avatarPath; // temporary local selection
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _emailController.text = currentUser.email;
      _avatarPath = currentUser.avatarPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(profileProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        avatarPath: _avatarPath,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.grassGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
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

  Future<void> _pickImage() async {
    try {
      // Primary: image_picker (system gallery/camera providers)
      final xfile = await _imagePicker.pickImage(source: ImageSource.gallery);
      String? path = xfile?.path;

      // Fallback: file_picker if image_picker returns null (empty gallery providers)
      if (path == null) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: false,
        );
        if (result != null && result.files.isNotEmpty) {
          path = result.files.single.path;
        }
      }

      if (path != null) {
        if (!mounted) return;
        setState(() {
          _avatarPath = path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick image: $e'),
          backgroundColor: AppColors.lightOverdue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        elevation: 0,
        foregroundColor: isDark ? AppColors.darkMainText : AppColors.lightMainText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                          radius: 60,
                          backgroundColor: isDark ? AppColors.darkAccent : AppColors.primaryAccent,
                          backgroundImage: _avatarPath != null
                              ? (_avatarPath!.startsWith('http')
                                  ? NetworkImage(_avatarPath!) as ImageProvider
                                  : FileImage(File(_avatarPath!)))
                              : null,
                          child: _avatarPath == null
                              ? Text(
                                  (currentUser?.name.substring(0, 1).toUpperCase() ?? 'U'),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                )
                              : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkAccent : AppColors.primaryAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.darkCard : AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(Icons.camera_alt, color: AppColors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to change photo',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.white : AppColors.lightMainText.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form Fields
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
                backgroundColor: isDark ? AppColors.darkAccent : AppColors.primaryAccent,
              ),

              const SizedBox(height: 16),

              // Cancel Button
              CustomButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
                isOutlined: true,
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
