import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMsg;
  late AnimationController _animCtrl;
  late Animation<double> _heroFadeAnim;
  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    // Staggered entrance: the hero mark/title settle first, then the card
    // slides in — a small choreographed touch instead of everything
    // fading in at once.
    _heroFadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _cardFadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    ));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    final error = await AuthService.instance.login(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMsg = error);
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          Container(color: AppColors.primaryDark),
          AnimatedBlobAccentBackdrop(color: AppColors.primary),
          SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 36),
                FadeTransition(
                  opacity: _heroFadeAnim,
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const CustomPaint(
                          size: Size(84, 84),
                          painter: _LogoMarkPainter(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('WORKFORCE PLATFORM',
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                            letterSpacing: 2.4,
                          )),
                      const SizedBox(height: 6),
                      Text('HCM Pro',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          )),
                      const SizedBox(height: 6),
                      Text('Manage your people, beautifully.',
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontStyle: FontStyle.italic,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _cardFadeAnim,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 36,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back', style: AppTextStyles.heading1),
                          const SizedBox(height: 4),
                          Text('Sign in to your account',
                              style: AppTextStyles.body2),
                          const SizedBox(height: 24),
                          _buildEmailField(),
                          const SizedBox(height: 14),
                          _buildPasswordField(),
                          if (_errorMsg != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.danger
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: AppColors.danger, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(_errorMsg!,
                                        style: AppTextStyles.body2.copyWith(
                                            color: AppColors.danger)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Sign In',
                                            style: AppTextStyles.button
                                                .copyWith(fontSize: 16)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded,
                                            color: Colors.white, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '© 2026 HCM Pro. All rights reserved.',
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email address',
            style:
                AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'your.name@company.com',
            prefixIcon: Icon(Icons.email_outlined,
                color: AppColors.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password',
            style:
                AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onSubmitted: (_) => _login(),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.textSecondary, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }
}

/// Two overlapping rounded squares — a small bespoke mark instead of a
/// stock Material icon, echoing the overlapping-circle motif used in
/// [BlobAccentBackdrop] elsewhere in the app.
class _LogoMarkPainter extends CustomPainter {
  const _LogoMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final back = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.46, h * 0.46),
      Radius.circular(w * 0.12),
    );
    final front = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.36, w * 0.46, h * 0.46),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(back, Paint()..color = Colors.white.withValues(alpha: 0.55));
    canvas.drawRRect(front, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) => false;
}
