import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for word pronunciation
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSupported = true;

  // Voice settings
  bool _isEnglish = true;
  double _speechRate = 0.5;
  double _pitch = 1.0;

  Future<FlutterTts> get flutterTts async {
    if (_flutterTts != null) return _flutterTts!;
    _flutterTts = FlutterTts();
    await _initTts();
    return _flutterTts!;
  }

  Future<void> _initTts() async {
    if (_isInitialized) return;

    try {
      await _flutterTts!.setLanguage('en-US');
      await _flutterTts!.setSpeechRate(_speechRate);
      await _flutterTts!.setPitch(_pitch);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setSharedInstance(true);

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('TTS initialization error: $e');
      }
      _isSupported = false;
    }
  }

  /// Speak text with TTS
  Future<void> speak(String text) async {
    if (!_isSupported) return;

    try {
      final tts = await flutterTts;

      // Stop any ongoing speech
      await tts.stop();

      // Speak the text
      await tts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('TTS speak error: $e');
      }
      _isSupported = false;
    }
  }

  /// Speak a word with pronunciation
  Future<void> speakWord(String word) async {
    await speak(word);
  }

  /// Stop speaking
  Future<void> stop() async {
    if (!_isSupported) return;

    try {
      final tts = await flutterTts;
      await tts.stop();
    } catch (e) {
      if (kDebugMode) {
        print('TTS stop error: $e');
      }
    }
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    if (!_isSupported) return;

    try {
      final tts = await flutterTts;
      await tts.setSpeechRate(_speechRate);
    } catch (e) {
      if (kDebugMode) {
        print('TTS setSpeechRate error: $e');
      }
    }
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    if (!_isSupported) return;

    try {
      final tts = await flutterTts;
      await tts.setPitch(_pitch);
    } catch (e) {
      if (kDebugMode) {
        print('TTS setPitch error: $e');
      }
    }
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    _isEnglish = languageCode.startsWith('en');
    if (!_isSupported) return;

    try {
      final tts = await flutterTts;
      await tts.setLanguage(languageCode);
    } catch (e) {
      if (kDebugMode) {
        print('TTS setLanguage error: $e');
      }
    }
  }

  /// Toggle between American and British English
  Future<void> toggleAccent() async {
    if (!_isSupported) return;

    try {
      final tts = await flutterTts;
      if (_isEnglish) {
        await tts.setLanguage('en-GB'); // British English
      } else {
        await tts.setLanguage('en-US'); // American English
      }
      _isEnglish = !_isEnglish;
    } catch (e) {
      if (kDebugMode) {
        print('TTS toggleAccent error: $e');
      }
    }
  }

  /// Get current accent description
  String get currentAccent => _isEnglish ? '美式' : '英式';

  /// Check if TTS is supported
  bool get isSupported => _isSupported;
}
