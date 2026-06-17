import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _buttonPressed = false;
  String? _errorMsg;

  late AnimationController _entranceCtrl;
  late Animation<double> _illustrationFadeAnim;
  late Animation<double> _formFadeAnim;
  late Animation<Offset> _formSlideAnim;

  // A slow, perpetual idle bob for the illustration — the screen should
  // feel alive even before anyone touches it.
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _illustrationFadeAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _formFadeAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _formSlideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    ));
    _entranceCtrl.forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _floatCtrl.dispose();
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
    final screenHeight = MediaQuery.of(context).size.height;
    final illustrationHeight = (screenHeight * 0.36).clamp(260.0, 340.0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _illustrationFadeAnim,
              child: ClipPath(
                clipper: _CurvedBottomClipper(),
                child: Container(
                  height: illustrationHeight,
                  width: double.infinity,
                  color: AppColors.primaryDark,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _IllustrationBackdropPainter()),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Row(
                            children: [
                              Text('HCM Pro',
                                  style: AppTextStyles.heading2.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  )),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Workforce Platform',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _floatCtrl,
                          builder: (context, child) {
                            final dy = -6 + 12 * _floatCtrl.value;
                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: child,
                            );
                          },
                          child: CustomPaint(
                            painter: _HeroBadgePainter(),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SlideTransition(
                position: _formSlideAnim,
                child: FadeTransition(
                  opacity: _formFadeAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back', style: AppTextStyles.displayLarge),
                      const SizedBox(height: 4),
                      Text('Sign in to get back to your team.',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          )),
                      const SizedBox(height: 28),
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
                                color: AppColors.danger.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.danger, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_errorMsg!,
                                    style: AppTextStyles.body2
                                        .copyWith(color: AppColors.danger)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTapDown: (_) => setState(() => _buttonPressed = true),
                        onTapUp: (_) => setState(() => _buttonPressed = false),
                        onTapCancel: () => setState(() => _buttonPressed = false),
                        child: AnimatedScale(
                          scale: _buttonPressed ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5),
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
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Text(
                          '© 2026 HCM Pro. All rights reserved.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

/// The illustration panel's bottom edge curves gently into the page
/// instead of cutting straight across — the single biggest lever for
/// "not the generic template" composition.
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 36)
      ..quadraticBezierTo(
          size.width * 0.5, size.height + 28, size.width, size.height - 36)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Soft layered circles behind the hero badge.
class _IllustrationBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15),
        size.width * 0.4, Paint()..color = AppColors.primary.withValues(alpha: 0.5));
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.85),
        size.width * 0.3, Paint()..color = AppColors.primary.withValues(alpha: 0.35));
  }

  @override
  bool shouldRepaint(covariant _IllustrationBackdropPainter oldDelegate) => false;
}

/// A single hero shape — an "approved" clipboard badge — instead of a
/// cluttered scene. Sized and centered using its own width (not an
/// eyeballed offset) and kept with a large safety margin above the
/// curved bottom edge so it can never be clipped.
class _HeroBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    const boardW = 118.0;
    const boardH = 148.0;
    // Must clear the "HCM Pro" / "Workforce Platform" header row above it.
    final top = size.height * 0.27;
    final left = cx - boardW / 2;

    // Soft shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(left + 6, top + 12, boardW, boardH), const Radius.circular(20)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    // Board.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, boardW, boardH), const Radius.circular(20)),
      Paint()..color = Colors.white,
    );

    // Clip at the top.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - boardW * 0.18, top - 12, boardW * 0.36, 24),
          const Radius.circular(7)),
      Paint()..color = AppColors.roleHrManager,
    );

    // Big checkmark in a circle — the headline moment.
    final circleCenter = Offset(cx, top + boardH * 0.36);
    canvas.drawCircle(circleCenter, 32,
        Paint()..color = AppColors.success.withValues(alpha: 0.16));
    final checkPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(circleCenter.dx - 14, circleCenter.dy)
        ..lineTo(circleCenter.dx - 3, circleCenter.dy + 12)
        ..lineTo(circleCenter.dx + 16, circleCenter.dy - 13),
      checkPaint,
    );

    // Lines of "text" below the checkmark.
    final linePaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = top + boardH * 0.64 + i * 24;
      canvas.drawLine(
          Offset(left + boardW * 0.16, y), Offset(left + boardW * 0.84, y), linePaint);
    }

    // Floating accent dots, kept well clear of the bottom edge.
    canvas.drawCircle(Offset(left - 36, top + 8), 7,
        Paint()..color = AppColors.roleEmployee.withValues(alpha: 0.85));
    canvas.drawCircle(Offset(left + boardW + 34, top + boardH * 0.3), 5,
        Paint()..color = Colors.white.withValues(alpha: 0.7));
    canvas.drawCircle(Offset(left - 20, top + boardH * 0.75), 5,
        Paint()..color = AppColors.roleManager.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(covariant _HeroBadgePainter oldDelegate) => false;
}
