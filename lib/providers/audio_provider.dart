import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum AudioState { idle, loading, playing, finished, error }

class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier() : super(AudioState.idle);

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  static const _storyText =
      'Once upon a time, a clever little robot named Pip '
      'lost his shiny blue gear in the Whispering Woods.';

  Future<void> _init() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.1);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() => state = AudioState.playing);
    _tts.setCompletionHandler(() => state = AudioState.finished);
    _tts.setErrorHandler((_) => state = AudioState.error);
    _initialized = true;
  }

  Future<void> readStory() async {
    if (state == AudioState.playing) {
      await stop();
      return;
    }
    state = AudioState.loading;
    try {
      await _init();
      state = AudioState.playing;
      await _tts.speak(_storyText);
    } catch (_) {
      state = AudioState.error;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    state = AudioState.idle;
  }

  void retry() {
    state = AudioState.idle;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

final audioProvider =
    StateNotifierProvider<AudioNotifier, AudioState>((ref) => AudioNotifier());
