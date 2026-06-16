import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum OptionState { idle, correct, wrong }

class QuizOptionButton extends StatefulWidget {
  final String label;
  final OptionState state;
  final VoidCallback onTap;

  const QuizOptionButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  State<QuizOptionButton> createState() => _QuizOptionButtonState();
}

class _QuizOptionButtonState extends State<QuizOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
  }

  @override
  void didUpdateWidget(QuizOptionButton old) {
    super.didUpdateWidget(old);
    if (widget.state == OptionState.wrong && old.state != OptionState.wrong) {
      HapticFeedback.mediumImpact();
      _shakeCtrl.forward(from: 0).then((_) => _shakeCtrl.reset());
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.state) {
      case OptionState.correct:
        return AppColors.accentLight;
      case OptionState.wrong:
        return AppColors.errorLight;
      case OptionState.idle:
        return AppColors.surface;
    }
  }

  Color get _borderColor {
    switch (widget.state) {
      case OptionState.correct:
        return AppColors.accent;
      case OptionState.wrong:
        return AppColors.error;
      case OptionState.idle:
        return AppColors.border;
    }
  }

  Color get _textColor {
    switch (widget.state) {
      case OptionState.correct:
        return const Color(0xFF085041);
      case OptionState.wrong:
        return const Color(0xFF791F1F);
      case OptionState.idle:
        return AppColors.textPrimary;
    }
  }

  Widget get _trailingIcon {
    switch (widget.state) {
      case OptionState.correct:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        );
      case OptionState.wrong:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 14),
        );
      case OptionState.idle:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) {
        final offset =
            _shakeCtrl.isAnimating ? sin(_shakeAnim.value * pi * 5) * 9 : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.state == OptionState.idle ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
              _trailingIcon,
            ],
          ),
        ),
      ),
    );
  }
}
