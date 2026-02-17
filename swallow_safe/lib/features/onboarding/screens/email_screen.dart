import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../bloc/onboarding_bloc.dart';

/// Premium email capture screen with magic link flow
class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _fadeController;
  bool _isValid = false;
  bool _isSending = false;
  bool _linkSent = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text.trim();
      _isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: PremiumTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: PremiumTheme.softShadow,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: PremiumTheme.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Progress indicator
                    _buildProgressIndicator(2, 4),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      _linkSent ? 'Check your email' : 'Enter your email',
                      style: PremiumTheme.displayMedium,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _linkSent
                          ? 'We sent a sign-in link to ${_emailController.text}'
                          : 'We\'ll send a sign-in link - no password needed!',
                      style: PremiumTheme.bodyMedium,
                    ),

                    const SizedBox(height: 40),

                    if (_linkSent)
                      _buildSuccessState()
                    else
                      _buildEmailInput(),

                    const Spacer(),

                    _buildActionButton(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? PremiumTheme.primary
                  : PremiumTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmailInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? PremiumTheme.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: _isFocused
            ? PremiumTheme.accentGlow
            : PremiumTheme.softShadow,
      ),
      child: TextField(
        controller: _emailController,
        focusNode: _focusNode,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        style: PremiumTheme.bodyLarge.copyWith(
          color: PremiumTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'you@email.com',
          hintStyle: PremiumTheme.bodyLarge.copyWith(
            color: PremiumTheme.textTertiary,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.email_outlined,
              color: _isFocused
                  ? PremiumTheme.primary
                  : PremiumTheme.textTertiary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: PremiumTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: PremiumTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.email_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Link sent!',
            style: PremiumTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Click the link in your email to continue',
            style: PremiumTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              setState(() => _linkSent = false);
            },
            child: Text(
              'Didn\'t receive it? Send again',
              style: PremiumTheme.labelMedium.copyWith(
                color: PremiumTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_linkSent) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.read<OnboardingBloc>().add(
                  SetEmail(_emailController.text.trim()),
                );
            context.go(AppRoutes.onboardingDisclaimer);
          },
          style: PremiumTheme.primaryButton,
          child: Text('Continue', style: PremiumTheme.button),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isValid && !_isSending ? _sendLink : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isValid ? PremiumTheme.primary : PremiumTheme.surfaceVariant,
          foregroundColor:
              _isValid ? Colors.white : PremiumTheme.textTertiary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isSending
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    _isValid ? Colors.white : PremiumTheme.textTertiary,
                  ),
                ),
              )
            : Text('Send Link', style: PremiumTheme.button),
      ),
    );
  }

  Future<void> _sendLink() async {
    HapticFeedback.mediumImpact();

    setState(() => _isSending = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSending = false;
        _linkSent = true;
      });
    }
  }
}
