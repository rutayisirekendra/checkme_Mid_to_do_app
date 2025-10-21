import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Header with Icon and Title
              _buildHeader(context, isDark),
              
              const SizedBox(height: 60),
              
              // Tab Selector
              _buildTabSelector(context, isDark),
              
              const SizedBox(height: 40),
              
              // Forms
              SizedBox(
                height: 600,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildLoginForm(context, isDark),
                    _buildRegisterForm(context, isDark),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // App Icon - Clean and Simple
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.groups_3,
            size: 40,
            color: AppColors.white,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App Title
        Text(
          'CheckMe',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Your personal productivity companion',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark 
                ? AppColors.darkMainText.withValues(alpha: 0.7)
                : AppColors.lightMainText.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkMainText.withValues(alpha: 0.1)
            : AppColors.lightMainText.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _currentPage == 0 
                      ? AppColors.primaryAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _currentPage == 0 
                        ? AppColors.white
                        : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _currentPage == 1 
                      ? AppColors.primaryAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _currentPage == 1 
                        ? AppColors.white
                        : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isDark) {
    return _LoginFormContent(isDark: isDark);
  }

  Widget _buildRegisterForm(BuildContext context, bool isDark) {
    return _RegisterFormContent(isDark: isDark);
  }
}

class _LoginFormContent extends ConsumerStatefulWidget {
  final bool isDark;
  
  const _LoginFormContent({required this.isDark});

  @override
  ConsumerState<_LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends ConsumerState<_LoginFormContent> {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          _buildInputField(
            context: context,
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
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

          const SizedBox(height: 20),

          // Password Field
          _buildInputField(
            context: context,
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: widget.isDark 
                    ? AppColors.darkMainText.withValues(alpha: 0.6)
                    : AppColors.lightMainText.withValues(alpha: 0.6),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Forgot password feature coming soon!'),
                  ),
                );
              },
              child: Text(
                'Forgot Password?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Sign In Button
          _buildPrimaryButton(
            context: context,
            text: 'Login',
            onPressed: loginState.isLoading ? null : _handleLogin,
            isLoading: loginState.isLoading,
          ),

        ],
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

}

class _RegisterFormContent extends ConsumerStatefulWidget {
  final bool isDark;
  
  const _RegisterFormContent({required this.isDark});

  @override
  ConsumerState<_RegisterFormContent> createState() => _RegisterFormContentState();
}

class _RegisterFormContentState extends ConsumerState<_RegisterFormContent> {
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
            _buildInputField(
            context: context,
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person_outline,
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
          _buildInputField(
            context: context,
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
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

          const SizedBox(height: 20),

          // Password Field
          _buildInputField(
            context: context,
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: widget.isDark 
                    ? AppColors.darkMainText.withValues(alpha: 0.6)
                    : AppColors.lightMainText.withValues(alpha: 0.6),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
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
          _buildInputField(
            context: context,
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: widget.isDark 
                    ? AppColors.darkMainText.withValues(alpha: 0.6)
                    : AppColors.lightMainText.withValues(alpha: 0.6),
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
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
                activeColor: AppColors.primaryAccent,
                checkColor: AppColors.white,
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
                        color: widget.isDark 
                            ? AppColors.darkMainText.withValues(alpha: 0.8)
                            : AppColors.lightMainText.withValues(alpha: 0.8),
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.isDark 
                                ? AppColors.darkMainText.withValues(alpha: 0.8)
                                : AppColors.lightMainText.withValues(alpha: 0.8),
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryAccent,
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

          const SizedBox(height: 32),

          // Sign Up Button
          _buildPrimaryButton(
            context: context,
            text: 'Sign Up',
            onPressed: registerState.isLoading ? null : _handleRegister,
            isLoading: registerState.isLoading,
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

}

// Helper methods for building UI components
Widget _buildInputField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData prefixIcon,
  TextInputType? keyboardType,
  bool obscureText = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: isDark 
                ? AppColors.darkMainText.withValues(alpha: 0.5)
                : AppColors.lightMainText.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: isDark 
                ? AppColors.darkMainText.withValues(alpha: 0.6)
                : AppColors.lightMainText.withValues(alpha: 0.6),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: isDark 
              ? AppColors.darkMainText.withValues(alpha: 0.05)
              : AppColors.lightMainText.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark 
                  ? AppColors.darkMainText.withValues(alpha: 0.2)
                  : AppColors.lightMainText.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark 
                  ? AppColors.darkMainText.withValues(alpha: 0.2)
                  : AppColors.lightMainText.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryAccent,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.lightOverdue,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
        ),
        cursorColor: AppColors.primaryAccent,
      ),
    ],
  );
}

Widget _buildPrimaryButton({
  required BuildContext context,
  required String text,
  required VoidCallback? onPressed,
  bool isLoading = false,
}) {
  final theme = Theme.of(context);

  return SizedBox(
    height: 56,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  );
}

Widget _buildSecondaryButton({
  required BuildContext context,
  required String text,
  required IconData icon,
  required VoidCallback? onPressed,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return SizedBox(
    height: 56,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.darkMainText : AppColors.lightMainText,
        side: BorderSide(
        color: isDark 
            ? AppColors.darkMainText.withValues(alpha: 0.3)
            : AppColors.lightMainText.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDivider(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Row(
    children: [
      Expanded(
        child: Container(
          height: 1,
          color: isDark 
              ? AppColors.darkMainText.withValues(alpha: 0.2)
              : AppColors.lightMainText.withValues(alpha: 0.2),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'or',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark 
                ? AppColors.darkMainText.withValues(alpha: 0.6)
                : AppColors.lightMainText.withValues(alpha: 0.6),
          ),
        ),
      ),
      Expanded(
        child: Container(
          height: 1,
          color: isDark 
              ? AppColors.darkMainText.withValues(alpha: 0.2)
              : AppColors.lightMainText.withValues(alpha: 0.2),
        ),
      ),
    ],
  );
}
