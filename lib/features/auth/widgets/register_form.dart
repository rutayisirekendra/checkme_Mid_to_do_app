import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/glassmorphism_button.dart';
import '../../../shared/providers/auth_provider.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);
    final theme = Theme.of(context);

    ref.listen(registerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.lightOverdue,
          ),
        );
      }
    });

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          CustomTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.person_outline),
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Email Field
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
            isRequired: true,
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

          const SizedBox(height: 20),

          // Password Field
          CustomTextField(
            label: 'Password',
            hint: 'Create a password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Password must contain uppercase, lowercase, and number';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Confirm Password Field
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Terms and Conditions
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: AppColors.white,
                checkColor: AppColors.primaryAccent,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreeToTerms = !_agreeToTerms;
                    });
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sign Up Button
          CustomButton(
            text: 'Sign Up',
            onPressed: registerState.isLoading ? null : _handleRegister,
            isLoading: registerState.isLoading,
            backgroundColor: AppColors.white,
            textColor: AppColors.primaryAccent,
          ),

          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.white.withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Google Sign Up Button
          GlassmorphismButton(
            onPressed: registerState.isLoading ? null : _handleGoogleRegister,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.g_mobiledata, color: AppColors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Sign up with Google',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _handleRegister() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: AppColors.lightOverdue,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      ref.read(registerProvider.notifier).register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _handleGoogleRegister() {
    // TODO: Implement Google Sign Up
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign Up coming soon!'),
      ),
    );
  }
}
