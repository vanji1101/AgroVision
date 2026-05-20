import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../theme/app_colors.dart';

// ─── Chat message model ─────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  const _ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class VoiceAIScreen extends StatefulWidget {
  const VoiceAIScreen({super.key});
  @override
  State<VoiceAIScreen> createState() => _VoiceAIScreenState();
}

class _VoiceAIScreenState extends State<VoiceAIScreen>
    with SingleTickerProviderStateMixin {
  bool _listening = false;
  bool _isSending = false;
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late AnimationController _pulse;

  final List<_ChatMessage> _messages = [];
  
  late final AudioRecorder _recorder;
  late final AudioPlayer _player;
  String? _audioPath;

  final List<_QuickQ> _quick = const [
    _QuickQ('Weather forecast', 'வானிலை'),
    _QuickQ('Crop prices', 'விலைகள்'),
    _QuickQ('Soil health', 'மண் ஆரோக்கியம்'),
    _QuickQ('Government schemes', 'அரசு திட்டங்கள்'),
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _recorder = AudioRecorder();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  // ─── Send message to backend ──────────────────────────────────────────────
  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMessage(
          text: trimmed, isUser: true, timestamp: DateTime.now()));
      _isSending = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    try {
      final reply = await ApiService.postChat(trimmed);
      setState(() {
        _messages.add(_ChatMessage(
            text: reply, isUser: false, timestamp: DateTime.now()));
      });
    } catch (e) {
      _addErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _addErrorMessage(String msg) {
    setState(() {
      _messages.add(_ChatMessage(
          text: msg, isUser: false, timestamp: DateTime.now()));
    });
  }

  // ─── Voice Recording Logic ────────────────────────────────────────────────
  Future<void> _toggleListening() async {
    if (_listening) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        String path = '';
        try {
          final dir = await getTemporaryDirectory();
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          path = p.join(dir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.wav');
        } catch (e) {
          _addErrorMessage('Local storage is not supported on this device. (Are you running on Web?)');
          return;
        }
        
        await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
        setState(() {
          _listening = true;
          _audioPath = path;
        });
      } else {
        _addErrorMessage('Microphone permission denied.');
      }
    } catch (e) {
      _addErrorMessage('Could not start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      setState(() {
        _listening = false;
        _isSending = true;
      });

      if (path != null) {
        await _sendVoiceMessage(path);
      }
    } catch (e) {
      _addErrorMessage('Error stopping recording: $e');
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendVoiceMessage(String path) async {
    try {
      final result = await ApiService.postVoice(path);

      final transcribed = result['transcribed'] as String;
      final replyText = result['replyText'] as String;
      final audioBytes = result['audioBytes'] as List<int>;

      setState(() {
        _messages.add(_ChatMessage(text: transcribed, isUser: true, timestamp: DateTime.now()));
        _messages.add(_ChatMessage(text: replyText, isUser: false, timestamp: DateTime.now()));
      });

      // Play the returned audio
      try {
        final dir = await getTemporaryDirectory();
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final responseAudioPath = p.join(dir.path, 'response_${DateTime.now().millisecondsSinceEpoch}.wav');
        final file = File(responseAudioPath);
        await file.writeAsBytes(audioBytes);
        
        await _player.play(DeviceFileSource(responseAudioPath));
      } catch (e) {
        _addErrorMessage('Could not play audio response (Local storage not supported).');
      }
    } catch (e) {
      _addErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('AgroVision AI Chat',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text('குரல் உதவியாளர்',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
            ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
          ),
          // Bottom input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── Empty state (greeting + quick questions) ──────────────────────────────
  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        // Greeting bubble
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: const TextSpan(
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  children: [
                    TextSpan(
                        text: 'Vanakkam! ',
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600)),
                    TextSpan(text: 'How can I help you today?'),
                  ],
                )),
                const SizedBox(height: 4),
                const Text(
                    'வணக்கம்! நான் உங்களுக்கு எப்படி உதவ முடியும்?',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ]),
        ),
        const SizedBox(height: 24),
        // Listening indicator
        if (_listening) _buildListeningIndicator(),
        // Quick questions label
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('Quick questions / விரைவு கேள்விகள்',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ),
        // Quick question grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: _quick
              .map((q) => GestureDetector(
                    onTap: () => _sendMessage(q.en),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.15)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6)
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(q.en,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(q.ta,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                          ]),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ─── Message list ─────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isSending) {
          return _buildTypingIndicator();
        }
        final msg = _messages[index];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
            const SizedBox(width: 10),
            const Text('Thinking...',
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        double factor;
        switch (index % 3) {
          case 0:
            factor = _pulse.value;
            break;
          case 1:
            factor = 1 - _pulse.value;
            break;
          default:
            factor = 0.5;
        }
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.4 + 0.6 * factor),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // ─── Listening indicator ──────────────────────────────────────────────────
  Widget _buildListeningIndicator() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ...List.generate(
                  5,
                  (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 4,
                        height: 10 +
                            18 *
                                ((i % 3 == 0)
                                    ? _pulse.value
                                    : (i % 3 == 1)
                                        ? (1 - _pulse.value)
                                        : 0.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
              const SizedBox(width: 10),
              const Text('Listening...',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Input bar ────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
      child: Column(children: [
        Row(children: [
          // Mic button
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _listening ? Colors.red : AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.mic, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          // Text field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _ctrl,
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Type your question...',
                  hintStyle: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: () => _sendMessage(_ctrl.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isSending
                    ? AppColors.primaryGreen.withOpacity(0.5)
                    : AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        const Text('Tap mic to speak in Tamil or English',
            style:
                TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _QuickQ {
  final String en, ta;
  const _QuickQ(this.en, this.ta);
}
