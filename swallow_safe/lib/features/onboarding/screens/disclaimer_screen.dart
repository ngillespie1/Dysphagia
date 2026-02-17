import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../bloc/onboarding_bloc.dart';

/// Medical disclaimer and Terms of Service acceptance screen.
/// Users must accept both the medical disclaimer and ToS/Privacy Policy
/// before proceeding with the onboarding flow.
class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _disclaimerAccepted = false;
  bool _tosAccepted = false;

  bool get _canContinue => _disclaimerAccepted && _tosAccepted;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
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
                    Semantics(
                      button: true,
                      label: 'Go back',
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 48,
                          height: 48,
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
                    ),

                    const SizedBox(height: 32),

                    // Progress indicator (step 5 of 6)
                    _buildProgressIndicator(5, 6),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'Important\ninformation',
                      style: PremiumTheme.displayMedium,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Please read and accept before continuing',
                      style: PremiumTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),

                    // Scrollable disclaimer content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // Medical Disclaimer Card
                            _buildDisclaimerCard(),

                            const SizedBox(height: 16),

                            // Medical Disclaimer Checkbox
                            _buildCheckboxTile(
                              value: _disclaimerAccepted,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(
                                    () => _disclaimerAccepted = val ?? false);
                              },
                              label:
                                  'I understand that SwallowSafe is not a substitute for professional medical advice, diagnosis, or treatment.',
                              semanticsLabel:
                                  'Accept medical disclaimer checkbox',
                            ),

                            const SizedBox(height: 20),

                            // ToS & Privacy Policy Checkbox
                            _buildCheckboxTile(
                              value: _tosAccepted,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _tosAccepted = val ?? false);
                              },
                              label:
                                  'I agree to the Terms of Service and Privacy Policy.',
                              semanticsLabel:
                                  'Accept terms of service and privacy policy checkbox',
                              hasLinks: true,
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canContinue ? _continue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canContinue
                              ? PremiumTheme.primary
                              : PremiumTheme.surfaceVariant,
                          foregroundColor: _canContinue
                              ? Colors.white
                              : PremiumTheme.textTertiary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue',
                          style: PremiumTheme.button,
                        ),
                      ),
                    ),

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

  Widget _buildDisclaimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: PremiumTheme.softShadow,
        border: Border.all(
          color: PremiumTheme.warningLight,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PremiumTheme.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_information_outlined,
                  color: PremiumTheme.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Medical Disclaimer',
                  style: PremiumTheme.headlineMedium.copyWith(
                    color: PremiumTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'SwallowSafe is designed as a supportive tool for dysphagia rehabilitation and is intended to complement — not replace — professional medical care.',
            style: PremiumTheme.bodyMedium.copyWith(
              color: PremiumTheme.textPrimary,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 12),

          _buildDisclaimerBullet(
            'Always follow your healthcare provider\'s specific instructions for your swallowing therapy program.',
          ),
          _buildDisclaimerBullet(
            'Do not begin any exercise program without consulting your speech-language pathologist or physician.',
          ),
          _buildDisclaimerBullet(
            'If you experience pain, choking, or any adverse symptoms during exercises, stop immediately and contact your healthcare provider.',
          ),
          _buildDisclaimerBullet(
            'This app does not provide medical diagnoses or emergency medical services.',
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PremiumTheme.errorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.emergency_outlined,
                  color: PremiumTheme.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'In case of a medical emergency, call your local emergency number (e.g. 911) immediately.',
                    style: PremiumTheme.bodySmall.copyWith(
                      color: PremiumTheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: PremiumTheme.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: PremiumTheme.bodySmall.copyWith(
                color: PremiumTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    required String semanticsLabel,
    bool hasLinks = false,
  }) {
    return Semantics(
      label: semanticsLabel,
      toggled: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: value
                ? PremiumTheme.primarySoft
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value
                  ? PremiumTheme.primary.withOpacity(0.3)
                  : PremiumTheme.surfaceVariant,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? PremiumTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value
                        ? PremiumTheme.primary
                        : PremiumTheme.textMuted,
                    width: 2,
                  ),
                ),
                child: value
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: hasLinks
                    ? _buildTosLabelWithLinks()
                    : Text(
                        label,
                        style: PremiumTheme.bodySmall.copyWith(
                          color: PremiumTheme.textPrimary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTosLabelWithLinks() {
    return Text.rich(
      TextSpan(
        style: PremiumTheme.bodySmall.copyWith(
          color: PremiumTheme.textPrimary,
          fontSize: 13,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'I agree to the '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: _showTermsOfService,
              child: Text(
                'Terms of Service',
                style: PremiumTheme.bodySmall.copyWith(
                  color: PremiumTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: PremiumTheme.primary,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: _showPrivacyPolicy,
              child: Text(
                'Privacy Policy',
                style: PremiumTheme.bodySmall.copyWith(
                  color: PremiumTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: PremiumTheme.primary,
                ),
              ),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    _showLegalDialog(
      title: 'Terms of Service',
      content: _termsOfServiceContent,
    );
  }

  void _showPrivacyPolicy() {
    _showLegalDialog(
      title: 'Privacy Policy',
      content: _privacyPolicyContent,
    );
  }

  void _showLegalDialog({required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: PremiumTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: PremiumTheme.headlineLarge),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          color: PremiumTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        content,
                        style: PremiumTheme.bodyMedium.copyWith(
                          color: PremiumTheme.textPrimary,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    context.read<OnboardingBloc>().add(const AcceptDisclaimer());
    context.go(AppRoutes.onboardingProgram);
  }

  // ============ Legal Content ============

  static const String _termsOfServiceContent = '''
SwallowSafe Terms of Service
Last updated: February 2026

1. ACCEPTANCE OF TERMS
By downloading, accessing, or using SwallowSafe ("the App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree, do not use the App.

2. DESCRIPTION OF SERVICE
SwallowSafe is a mobile application designed to support individuals undergoing dysphagia (swallowing disorder) rehabilitation. The App provides guided exercises, progress tracking, and educational resources.

3. MEDICAL DISCLAIMER
The App is NOT a medical device and does NOT provide medical advice, diagnosis, or treatment. The content provided through the App is for informational and supportive purposes only. Always seek the advice of your physician, speech-language pathologist, or other qualified healthcare provider with any questions regarding a medical condition.

4. USER RESPONSIBILITIES
• You must be at least 18 years of age or have parental/guardian consent.
• You are responsible for maintaining the confidentiality of your account.
• You agree to provide accurate information when creating your account.
• You must consult with a healthcare provider before beginning any exercise program.
• You agree not to use the App as a substitute for professional medical care.

5. SUBSCRIPTION AND PAYMENTS
• Some features require a paid subscription ("SwallowSafe Pro").
• Subscription prices are displayed in the App before purchase.
• Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.
• Refunds are handled according to Apple App Store and Google Play Store policies.

6. INTELLECTUAL PROPERTY
All content, including exercises, videos, text, graphics, and software, is owned by SwallowSafe and protected by intellectual property laws. You may not copy, modify, or distribute any content without written permission.

7. PRIVACY
Your use of the App is also governed by our Privacy Policy. By using the App, you consent to the collection and use of information as described in the Privacy Policy.

8. LIMITATION OF LIABILITY
To the fullest extent permitted by law, SwallowSafe shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of data, personal injury, or health outcomes resulting from your use of the App.

9. TERMINATION
We may terminate or suspend your access to the App at any time, without notice, for any reason, including violation of these Terms.

10. CHANGES TO TERMS
We reserve the right to modify these Terms at any time. We will notify users of material changes through the App. Continued use after changes constitutes acceptance of the modified Terms.

11. CONTACT
For questions about these Terms, contact us at support@swallowsafe.com.
''';

  static const String _privacyPolicyContent = '''
SwallowSafe Privacy Policy
Last updated: February 2026

1. INFORMATION WE COLLECT
We collect the following types of information:

Personal Information:
• Name and email address provided during registration.
• Health-related data you voluntarily enter (symptom scores, exercise completion).

Usage Data:
• App usage patterns, session duration, and feature interactions.
• Device information (model, OS version, app version).

2. HOW WE USE YOUR INFORMATION
• To provide and personalize the App experience.
• To track your rehabilitation progress.
• To generate reports for you to share with your healthcare team.
• To send exercise reminders (with your consent).
• To improve our App and services.
• To communicate with you about your account or the App.

3. DATA STORAGE AND SECURITY
• Your health data is stored locally on your device and, if you opt in, securely in our cloud infrastructure.
• We use industry-standard encryption (AES-256) to protect your data in transit and at rest.
• We do not sell your personal or health data to third parties.

4. DATA SHARING
We only share your data:
• With your explicit consent (e.g., when you share a progress report with your doctor).
• With service providers who assist in operating the App (subject to confidentiality agreements).
• When required by law or to protect our rights.

5. YOUR RIGHTS
You have the right to:
• Access and download your personal data.
• Correct inaccurate information.
• Delete your account and all associated data.
• Opt out of non-essential data collection.
• Withdraw consent for data processing at any time.

6. HEALTH DATA COMPLIANCE
• We comply with applicable health data privacy regulations.
• Health data is treated with the highest level of confidentiality.
• We follow data minimization principles — we only collect what is necessary.

7. CHILDREN'S PRIVACY
The App is not intended for use by children under 13. We do not knowingly collect information from children under 13.

8. COOKIES AND ANALYTICS
We use minimal analytics to improve the App experience. You can opt out of analytics in the App settings.

9. DATA RETENTION
• We retain your data for as long as your account is active.
• Upon account deletion, we remove your personal data within 30 days.
• Anonymized, aggregated data may be retained for research purposes.

10. CHANGES TO THIS POLICY
We will notify you of significant changes to this Privacy Policy through the App. Your continued use after changes constitutes acceptance.

11. CONTACT
For privacy-related inquiries, contact our Data Protection Officer at privacy@swallowsafe.com.
''';
}
