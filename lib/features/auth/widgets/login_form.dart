import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/glassmorphism_button.dart';
import '../../../shared/providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final theme = Theme.of(context);

    ref.listen(loginProvider, (previous, next) {
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
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
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
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Forgot password feature coming soon!'),
                  ),
                );
              },
              child: Text(
                'Forgot Password?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sign In Button
          CustomButton(
            text: 'Sign In',
            onPressed: loginState.isLoading ? null : _handleLogin,
            isLoading: loginState.isLoading,
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

          // Biometric Login Button
          if (ref.watch(currentUserProvider)?.biometricEnabled == true)
            GlassmorphismButton(
              onPressed: loginState.isLoading ? null : _handleBiometricLogin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fingerprint, color: AppColors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Sign in with Biometrics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Google Sign In Button
          GlassmorphismButton(
            onPressed: loginState.isLoading ? null : _handleGoogleLogin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.g_mobiledata, color: AppColors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Sign in with Google',
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

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(loginProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _handleBiometricLogin() {
    ref.read(loginProvider.notifier).loginWithBiometrics();
  }

  void _handleGoogleLogin() {
    // TODO: Implement Google Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign In coming soon!'),
      ),
    );
  }
}
