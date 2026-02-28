import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// 音效服务 - 播放键盘音效和其他音效
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  /// 是否启用音效
  bool get soundEnabled => _soundEnabled;

  /// 切换音效开关
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  /// 设置音效开关
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// 播放键盘按键音效
  Future<void> playKeySound() async {
    if (!_soundEnabled) return;
    try {
      // 使用系统音效
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // 如果系统音效不可用，静默失败
    }
  }

  /// 播放正确答案音效
  Future<void> playCorrectSound() async {
    if (!_soundEnabled) return;
    try {
      await _playTone(600, 100); // 高音短促
    } catch (e) {
      // 静默失败
    }
  }

  /// 播放错误答案音效
  Future<void> playWrongSound() async {
    if (!_soundEnabled) return;
    try {
      await _playTone(200, 200); // 低音较长
    } catch (e) {
      // ���默失败
    }
  }

  /// 播放成功音效
  Future<void> playSuccessSound() async {
    if (!_soundEnabled) return;
    try {
      // 连续上升的音调
      await _playTone(400, 100);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(600, 100);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(800, 150);
    } catch (e) {
      // 静默失败
    }
  }

  /// 播放成就解锁音效
  Future<void> playAchievementSound() async {
    if (!_soundEnabled) return;
    try {
      // 华丽的音效序列
      await _playTone(523, 150); // C5
      await Future.delayed(const Duration(milliseconds: 80));
      await _playTone(659, 150); // E5
      await Future.delayed(const Duration(milliseconds: 80));
      await _playTone(784, 150); // G5
      await Future.delayed(const Duration(milliseconds: 80));
      await _playTone(1047, 300); // C6
    } catch (e) {
      // 静默失败
    }
  }

  /// 播放升级音效
  Future<void> playLevelUpSound() async {
    if (!_soundEnabled) return;
    try {
      // 升级音效
      await _playTone(440, 100);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(554, 100);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(659, 100);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(880, 400);
    } catch (e) {
      // 静默失败
    }
  }

  /// 播放完成音效
  Future<void> playCompleteSound() async {
    if (!_soundEnabled) return;
    try {
      await _playTone(523, 200);
      await Future.delayed(const Duration(milliseconds: 100));
      await _playTone(659, 300);
    } catch (e) {
      // 静默失败
    }
  }

  /// 播放指定频率的音调
  Future<void> _playTone(int frequency, int durationMs) async {
    // 注意：在Web平台上，这个方法可能不工作
    // 在实际应用中，应该使用实际的音频文件
    // 这里使用系统音效作为后备
    try {
      // 对于简单的音效，可以使用系统音效
      if (frequency >= 500) {
        await SystemSound.play(SystemSoundType.alert);
      } else {
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      // 静默失败
    }
  }

  /// 停止所有音效
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// 释放资源
  void dispose() {
    _audioPlayer.dispose();
  }
}
