import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants.dart';

class AiChatWidget extends StatefulWidget {
  const AiChatWidget({super.key});

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'text': 'مرحباً! أنا المساعد الذكي لشركة نسيم (Naseem). كيف يمكنني مساعدتك اليوم بخصوص خدمات التكييف؟'}
  ];
  bool _isLoading = false;
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: kGeminiApiKey,
      systemInstruction: Content.system('''أنت مساعد ذكي لشركة "نسيم للتبريد والتكييف - Naseem". 
مهمتك هي الإجابة على استفسارات العملاء بناءً على المعلومات التالية فقط.
إذا سألك العميل عن شيء غير موجود في المعلومات، اعتذر بلباقة وأخبره أنه يمكنه التواصل عبر الهاتف (+966 50 000 0000).
كن ودوداً، مختصراً، واحترافياً. تحدث باللغة العربية.

الخدمات المتوفرة:
- تنظيف مكيف سبليت: تنظيف شامل للوحدة (120 ريال, ضمان 30 يوم)
- صيانة وإصلاح مكيفات: (200 ريال, ضمان 30 يوم)
- تعبئة فريون: (150 ريال, ضمان 30 يوم)
- لحام نحاس: (250 ريال, ضمان 30 يوم)
- تنظيف داكت سنترال: (500 ريال, ضمان 30 يوم)

الأسئلة الشائعة:
س: متى يتم الدفع؟ ج: الدفع بعد الخدمة.
س: ما هي مناطق العمل؟ ج: في جميع أحياء مدينة جدة.'''),
    );
    _chatSession = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (kGeminiApiKey == 'ضع_مفتاح_جوجل_هنا') {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'عذراً، لم يتم إعداد مفتاح الذكاء الاصطناعي (API Key) بعد.'});
      });
      return;
    }

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      setState(() {
        _messages.add({'role': 'assistant', 'text': response.text ?? 'حدث خطأ غير متوقع.'});
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
