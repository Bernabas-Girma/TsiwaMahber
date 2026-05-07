import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/notifications/data/telegram_service.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class TelegramSettingsScreen extends StatefulWidget {
  final String areaId;

  const TelegramSettingsScreen({
    super.key,
    required this.areaId,
  });

  @override
  State<TelegramSettingsScreen> createState() =>
      _TelegramSettingsScreenState();
}

class _TelegramSettingsScreenState
    extends State<TelegramSettingsScreen> {
  final _telegramService = TelegramService();
  final _botTokenController = TextEditingController();
  final _chatIdController = TextEditingController();

  bool _isEnabled = false;
  bool _sendAnnouncements = true;
  bool _sendEvents = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTesting = false;
  String? _botName;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _botTokenController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final config = await _telegramService.getConfig(widget.areaId);
    if (config != null && mounted) {
      setState(() {
        _botTokenController.text = config.botToken;
        _chatIdController.text = config.chatId;
        _isEnabled = config.isEnabled;
        _sendAnnouncements = config.sendAnnouncements;
        _sendEvents = config.sendEvents;
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.telegramConnection),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.telegram,
                                color: Colors.blue, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              S.telegramBotTitle,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Switch(
                              value: _isEnabled,
                              onChanged: (value) {
                                setState(() => _isEnabled = value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          S.telegramDesc,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted),
                        ),
                        if (_botName != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              '✓ ተገናኝቷል: $_botName',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.botSettings,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          S.botCreateHint,
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _botTokenController,
                          decoration: const InputDecoration(
                            labelText: 'Bot Token',
                            hintText: '123456:ABC-...',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _chatIdController,
                          decoration: const InputDecoration(
                            labelText: 'Chat ID',
                            hintText: '-1001234567890',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isTesting
                                ? null
                                : _testConnection,
                            icon: _isTesting
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child:
                                        CircularProgressIndicator(
                                            strokeWidth: 2),
                                  )
                                : const Icon(Icons.send),
                            label: Text(S.testConnection),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.notifTypes,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        SwitchListTile(
                          title: const Text('ማሳሰቢያዎች / መልእክቶች'),
                          subtitle: Text(
                              S.sendAnnouncements),
                          value: _sendAnnouncements,
                          onChanged: (value) {
                            setState(
                                () => _sendAnnouncements = value);
                          },
                        ),
                        SwitchListTile(
                          title: Text(S.events),
                          subtitle: Text(
                              S.sendEvents),
                          value: _sendEvents,
                          onChanged: (value) {
                            setState(() => _sendEvents = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      : Text(S.save),
                ),
              ],
            ),
    );
  }

  Future<void> _testConnection() async {
    final token = _botTokenController.text.trim();
    final chatId = _chatIdController.text.trim();

    if (token.isEmpty || chatId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bot Token እና Chat ID ያስፈልጋል')),
      );
      return;
    }

    setState(() => _isTesting = true);

    try {
      final botName = await _telegramService.getBotInfo(token);
      final success =
          await _telegramService.testConnection(token, chatId);

      if (mounted) {
        setState(() => _botName = botName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'ግንኙነት ተሳክቷል!' : 'ግንኙነት አልተሳካም',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ስህተት: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final config = TelegramConfig(
        botToken: _botTokenController.text.trim(),
        chatId: _chatIdController.text.trim(),
        isEnabled: _isEnabled,
        sendAnnouncements: _sendAnnouncements,
        sendEvents: _sendEvents,
      );

      await _telegramService.saveConfig(widget.areaId, config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.saved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ስህተት: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
