class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'answer': answer,
      };
}

// Simulated backend response — swap with a real API call later
// Works with 3, 4, or 5 options without any code changes
final backendQuizData = {
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue"
};
