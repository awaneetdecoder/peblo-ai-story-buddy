import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';

enum QuizState { hidden, revealed, answered, success }

class QuizStateData {
  final QuizState state;
  final String? selectedOption;
  final bool isCorrect;
  final int wrongAttempts;
  final QuizQuestion question;

  const QuizStateData({
    required this.state,
    required this.question,
    this.selectedOption,
    this.isCorrect = false,
    this.wrongAttempts = 0,
  });

  QuizStateData copyWith({
    QuizState? state,
    String? selectedOption,
    bool? isCorrect,
    int? wrongAttempts,
  }) =>
      QuizStateData(
        state: state ?? this.state,
        question: question,
        selectedOption: selectedOption ?? this.selectedOption,
        isCorrect: isCorrect ?? this.isCorrect,
        wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      );
}

class QuizNotifier extends StateNotifier<QuizStateData> {
  QuizNotifier()
      : super(QuizStateData(
          state: QuizState.hidden,
          question: QuizQuestion.fromJson(backendQuizData),
        ));

  void revealQuiz() {
    state = state.copyWith(state: QuizState.revealed);
  }

  void selectOption(String option) {
    if (state.state == QuizState.success) return;

    final correct = option == state.question.answer;
    if (correct) {
      state = state.copyWith(
        state: QuizState.success,
        selectedOption: option,
        isCorrect: true,
      );
    } else {
      state = state.copyWith(
        state: QuizState.answered,
        selectedOption: option,
        isCorrect: false,
        wrongAttempts: state.wrongAttempts + 1,
      );
      // Reset selected after shake animation
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          state = state.copyWith(
            state: QuizState.revealed,
            selectedOption: null,
          );
        }
      });
    }
  }

  void reset() {
    state = QuizStateData(
      state: QuizState.hidden,
      question: QuizQuestion.fromJson(backendQuizData),
    );
  }
}

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizStateData>((ref) => QuizNotifier());
