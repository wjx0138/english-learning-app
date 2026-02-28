import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/typing_practice.dart';
import '../../core/providers/app_provider.dart';

/// Typing Practice Settings Page
class TypingSettingsPage extends StatefulWidget {
  const TypingSettingsPage({super.key});

  @override
  State<TypingSettingsPage> createState() => _TypingSettingsPageState();
}

class _TypingSettingsPageState extends State<TypingSettingsPage> {
  late TypingSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = context.read<AppProvider>().typingSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打字练习设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sound settings
          _buildSectionCard(
            context,
            '声音设置',
            [
              SwitchListTile(
                title: const Text('键盘音效'),
                subtitle: const Text('打字时播放按键声音'),
                value: _settings.soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(soundEnabled: value);
                  });
                  _saveSettings();
                },
              ),
              SwitchListTile(
                title: const Text('自动播放发音'),
                subtitle: const Text('听写模式自动播放单词发音'),
                value: _settings.autoPlayAudio,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(autoPlayAudio: value);
                  });
                  _saveSettings();
                },
              ),
              if (_settings.autoPlayAudio)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '播放延迟: ${_settings.autoPlayDelay}秒',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Slider(
                        value: _settings.autoPlayDelay,
                        min: 0.5,
                        max: 3.0,
                        divisions: 5,
                        label: '${_settings.autoPlayDelay}秒',
                        onChanged: (value) {
                          setState(() {
                            _settings = _settings.copyWith(autoPlayDelay: value);
                          });
                          _saveSettings();
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Display settings
          _buildSectionCard(
            context,
            '显示设置',
            [
              SwitchListTile(
                title: const Text('显示提示'),
                subtitle: const Text('显示字母数量提示'),
                value: _settings.showHint,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(showHint: value);
                  });
                  _saveSettings();
                },
              ),
              SwitchListTile(
                title: const Text('显示进度'),
                subtitle: const Text('显示练习进度条'),
                value: _settings.showProgress,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(showProgress: value);
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Difficulty settings
          _buildSectionCard(
            context,
            '难度设置',
            [
              ListTile(
                title: const Text('最大尝试次数'),
                subtitle: Text('${_settings.maxAttempts} 次'),
                trailing: DropdownButton<int>(
                  value: _settings.maxAttempts,
                  items: [1, 2, 3, 5, 10].map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text('$value 次'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings = _settings.copyWith(maxAttempts: value);
                      });
                      _saveSettings();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _saveSettings() {
    context.read<AppProvider>().updateTypingSettings(_settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设置已保存'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
