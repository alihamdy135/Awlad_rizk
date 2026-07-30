import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api_service.dart';
import '../constants.dart';

class AiChatWidget extends StatefulWidget {
  const AiChatWidget({super.key});

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'text': 'مرحباً! أنا المساعد الذكي لأولاد رزق. كيف يمكنني مساعدتك اليوم بخصوص خدمات التكييف؟'}
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final responseText = await ApiService.sendChatMessage(text);
      setState(() {
        _messages.add({'role': 'assistant', 'text': responseText});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'عذراً، لم أتمكن من الرد. يرجى المحاولة لاحقاً.'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(kColorPrimary),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text('المساعد الذكي', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final isUser = _messages[i]['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(kColorCardWarm) : const Color(kColorPrimary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomLeft: isUser ? const Radius.circular(0) : const Radius.circular(16),
                        bottomRight: isUser ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      _messages[i]['text']!,
                      style: GoogleFonts.cairo(fontSize: 14, color: isUser ? const Color(kColorSecondary) : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: Color(kColorPrimary))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'اكتب استفسارك هنا...',
                      hintStyle: GoogleFonts.cairo(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(kColorPrimary),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
