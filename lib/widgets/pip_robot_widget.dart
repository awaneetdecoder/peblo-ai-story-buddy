import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PipMood { idle, happy, wrong, thinking }

class PipRobotWidget extends StatefulWidget {
  final PipMood mood;
  const PipRobotWidget({super.key, this.mood = PipMood.idle});

  @override
  State<PipRobotWidget> createState() => _PipRobotWidgetState();
}

class _PipRobotWidgetState extends State<PipRobotWidget>
    with TickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _bounceCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _antennaCtrl;

  late Animation<double> _breatheAnim;
  late Animation<double> _bounceAnim;
  late Animation<double> _shakeAnim;
  late Animation<double> _antennaAnim;

  bool _eyeOpen = true;

  @override
  void initState() {
    super.initState();

    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _startBlinkLoop();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnim = Tween<double>(begin: 0, end: -18).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);

    _antennaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _antennaAnim = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _antennaCtrl, curve: Curves.easeInOut),
    );
  }

  void _startBlinkLoop() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 2500 + Random().nextInt(2000)));
      if (!mounted) break;
      setState(() => _eyeOpen = false);
      await Future.delayed(const Duration(milliseconds: 110));
      if (!mounted) break;
      setState(() => _eyeOpen = true);
    }
  }

  @override
  void didUpdateWidget(PipRobotWidget old) {
    super.didUpdateWidget(old);
    if (widget.mood != old.mood) {
      if (widget.mood == PipMood.happy) {
        _bounceCtrl.forward(from: 0).then((_) => _bounceCtrl.reverse());
      } else if (widget.mood == PipMood.wrong) {
        _shakeCtrl.forward(from: 0).then((_) => _shakeCtrl.reset());
      }
    }
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _blinkCtrl.dispose();
    _bounceCtrl.dispose();
    _shakeCtrl.dispose();
    _antennaCtrl.dispose();
    super.dispose();
  }

  Color get _bodyColor {
    switch (widget.mood) {
      case PipMood.happy:
        return const Color(0xFFD4EDDA);
      case PipMood.wrong:
        return const Color(0xFFFFE8E8);
      case PipMood.thinking:
        return const Color(0xFFFFF8E1);
      case PipMood.idle:
        return AppColors.primaryLight;
    }
  }

  Color get _accentColor {
    switch (widget.mood) {
      case PipMood.happy:
        return AppColors.accent;
      case PipMood.wrong:
        return AppColors.error;
      case PipMood.thinking:
        return const Color(0xFFBA7517);
      case PipMood.idle:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_breatheAnim, _bounceAnim, _shakeAnim, _antennaAnim]),
      builder: (context, _) {
        final shakeOffset = _shakeCtrl.isAnimating
            ? sin(_shakeAnim.value * pi * 6) * 10
            : 0.0;

        return Transform.translate(
          offset: Offset(shakeOffset, _bounceAnim.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 120,
            height: 120 + _breatheAnim.value,
            decoration: BoxDecoration(
              color: _bodyColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: CustomPaint(
              painter: _PipPainter(
                mood: widget.mood,
                eyeOpen: _eyeOpen,
                accentColor: _accentColor,
                antennaAngle: _antennaAnim.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PipPainter extends CustomPainter {
  final PipMood mood;
  final bool eyeOpen;
  final Color accentColor;
  final double antennaAngle;

  _PipPainter({
    required this.mood,
    required this.eyeOpen,
    required this.accentColor,
    required this.antennaAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()..isAntiAlias = true;

    // Antenna
    paint.color = AppColors.primaryDark;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    final antX = cx + sin(antennaAngle) * 12;
    canvas.drawLine(Offset(cx, cy - 42), Offset(antX, cy - 58), paint);
    paint.style = PaintingStyle.fill;
    paint.color = accentColor;
    canvas.drawCircle(Offset(antX, cy - 60), 5, paint);

    // Head
    paint.color = AppColors.primaryDark;
    paint.style = PaintingStyle.fill;
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 14), width: 68, height: 50),
      const Radius.circular(12),
    );
    canvas.drawRRect(headRect, paint);

    // Eye sockets
    paint.color = AppColors.primaryLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 14, cy - 16), width: 18, height: eyeOpen ? 14 : 3),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 14, cy - 16), width: 18, height: eyeOpen ? 14 : 3),
        const Radius.circular(5),
      ),
      paint,
    );

    // Eye pupils
    if (eyeOpen) {
      paint.color = accentColor;
      canvas.drawCircle(Offset(cx - 14, cy - 16), 4, paint);
      canvas.drawCircle(Offset(cx + 14, cy - 16), 4, paint);
      paint.color = Colors.white;
      canvas.drawCircle(Offset(cx - 12, cy - 18), 1.5, paint);
      canvas.drawCircle(Offset(cx + 16, cy - 18), 1.5, paint);
    }

    // Mouth
    paint.color = _mouthColor;
    if (mood == PipMood.happy) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      paint.strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(cx - 12, cy - 4)
        ..quadraticBezierTo(cx, cy + 4, cx + 12, cy - 4);
      canvas.drawPath(path, paint);
    } else if (mood == PipMood.wrong) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      paint.strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(cx - 10, cy + 2)
        ..quadraticBezierTo(cx, cy - 4, cx + 10, cy + 2);
      canvas.drawPath(path, paint);
    } else {
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy - 3), width: 22, height: 5),
          const Radius.circular(3),
        ),
        paint,
      );
    }

    // Body
    paint.style = PaintingStyle.fill;
    paint.color = AppColors.primaryDark;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 30), width: 60, height: 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, paint);

    // Chest light
    paint.color = accentColor;
    canvas.drawCircle(Offset(cx, cy + 30), 6, paint);
    paint.color = Colors.white.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(cx - 1, cy + 28), 2, paint);

    // Arms
    paint.color = AppColors.primaryDark;
    final armL = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 38, cy + 28), width: 10, height: 20),
      const Radius.circular(5),
    );
    final armR = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 38, cy + 28), width: 10, height: 20),
      const Radius.circular(5),
    );
    canvas.drawRRect(armL, paint);
    canvas.drawRRect(armR, paint);

    // Legs
    final legL = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 14, cy + 52), width: 12, height: 16),
      const Radius.circular(4),
    );
    final legR = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 14, cy + 52), width: 12, height: 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(legL, paint);
    canvas.drawRRect(legR, paint);
  }

  Color get _mouthColor {
    switch (mood) {
      case PipMood.happy:
        return AppColors.accent;
      case PipMood.wrong:
        return AppColors.error;
      default:
        return AppColors.primaryMid;
    }
  }

  @override
  bool shouldRepaint(_PipPainter old) =>
      old.mood != mood ||
      old.eyeOpen != eyeOpen ||
      old.antennaAngle != antennaAngle ||
      old.accentColor != accentColor;
}