import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pip_robot_widget.dart';
import '../widgets/quiz_option_button.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _quizRevealCtrl;
  late Animation<double> _quizFadeAnim;
  late Animation<Offset> _quizSlideAnim;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _confettiCtrl =
        ConfettiController(duration: const Duration(seconds: 2));

    _quizRevealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _quizFadeAnim =
        Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _quizRevealCtrl, curve: Curves.easeOut),
    );
    _quizSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _quizRevealCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _quizRevealCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  PipMood _getMood(AudioState audio, QuizStateData quiz) {
    if (quiz.state == QuizState.success) return PipMood.happy;
    if (quiz.state == QuizState.answered && !quiz.isCorrect) return PipMood.wrong;
    if (audio == AudioState.playing) return PipMood.thinking;
    return PipMood.idle;
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final quizState = ref.watch(quizProvider);

    ref.listen<AudioState>(audioProvider, (prev, next) {
      if (next == AudioState.finished &&
          quizState.state == QuizState.hidden) {
        ref.read(quizProvider.notifier).revealQuiz();
        _quizRevealCtrl.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        });
      }
    });

    ref.listen<QuizStateData>(quizProvider, (prev, next) {
      if (next.state == QuizState.success) {
        _confettiCtrl.play();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('✦',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
        title: const Text('AI Story Buddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BuddyCard(mood: _getMood(audioState, quizState)),
                const SizedBox(height: 12),
                _StoryCard(audioState: audioState),
                const SizedBox(height: 16),
                _ReadButton(audioState: audioState),
                if (audioState == AudioState.error) ...[
                  const SizedBox(height: 12),
                  _ErrorBanner(
                    onRetry: () => ref.read(audioProvider.notifier).retry(),
                  ),
                ],
                if (quizState.state != QuizState.hidden) ...[
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _quizFadeAnim,
                    child: SlideTransition(
                      position: _quizSlideAnim,
                      child: _QuizCard(quizState: quizState),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                Color(0xFFEF9F27),
                Color(0xFFD4537E),
                Color(0xFF378ADD),
              ],
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuddyCard extends StatelessWidget {
  final PipMood mood;
  const _BuddyCard({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          PipRobotWidget(mood: mood),
          const SizedBox(height: 8),
          const Text(
            'PIP THE STORY ROBOT',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final AudioState audioState;
  const _StoryCard({required this.audioState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STORY TEXT',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(Icons.menu_book_rounded,
                  size: 18, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: audioState == AudioState.error ? 0.5 : 1,
            duration: const Duration(milliseconds: 300),
            child: const Text(
              '"Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods..."',
              style:  TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                height: 1.65,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (audioState == AudioState.error)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '(Audio unavailable — read along!)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadButton extends ConsumerWidget {
  final AudioState audioState;
  const _ReadButton({required this.audioState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: audioState == AudioState.error
            ? null
            : () => ref.read(audioProvider.notifier).readStory(),
        style: ElevatedButton.styleFrom(
          backgroundColor: audioState == AudioState.playing
              ? AppColors.primaryDark
              : audioState == AudioState.loading
                  ? AppColors.primaryMid
                  : AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(audioState),
            const SizedBox(width: 10),
            Text(
              _label(audioState),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(AudioState state) {
    if (state == AudioState.loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }
    if (state == AudioState.playing) {
      return const _AudioWave();
    }
    return const Icon(Icons.volume_up_rounded, size: 22);
  }

  String _label(AudioState state) {
    switch (state) {
      case AudioState.loading:
        return 'Preparing story...';
      case AudioState.playing:
        return 'Tap to stop';
      default:
        return 'Read Me a Story';
    }
  }
}

class _AudioWave extends StatefulWidget {
  const _AudioWave();
  @override
  State<_AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<_AudioWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        children: List.generate(5, (i) {
          final delays = [0.0, 0.2, 0.4, 0.2, 0.0];
          final h = 6 + sin((_ctrl.value + delays[i]) * pi) * 10;
          return Container(
            width: 3,
            height: h.clamp(4.0, 18.0),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Oops! Audio couldn\'t load. You can still read along!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF791F1F),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends ConsumerWidget {
  final QuizStateData quizState;
  const _QuizCard({required this.quizState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = quizState.question;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            q.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (quizState.wrongAttempts > 0 &&
              quizState.state != QuizState.success)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Text(
                '${quizState.wrongAttempts} wrong guess${quizState.wrongAttempts > 1 ? 'es' : ''} — keep trying!',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Data-driven: renders any number of options from JSON
          ...q.options.map((opt) {
            OptionState state = OptionState.idle;
            if (quizState.state == QuizState.success &&
                opt == q.answer) {
              state = OptionState.correct;
            } else if (quizState.selectedOption == opt &&
                !quizState.isCorrect) {
              state = OptionState.wrong;
            }
            return QuizOptionButton(
              label: opt,
              state: state,
              onTap: () =>
                  ref.read(quizProvider.notifier).selectOption(opt),
            );
          }),
          if (quizState.state == QuizState.success)
            _SuccessBanner(),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
           Text('🎉', style: TextStyle(fontSize: 36)),
           SizedBox(height: 8),
           Text(
            'Amazing, you got it!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF085041),
            ),
          ),
           SizedBox(height: 4),
           Text(
            'Pip found his shiny blue gear!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF0F6E56),
            ),
          ),
        ],
      ),
    );
  }
}