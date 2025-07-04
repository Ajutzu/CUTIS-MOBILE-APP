import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

// A simple message model
class _ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? suggestions;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.suggestions,
  });
}

class AskAIPage extends StatefulWidget {
  final Map<String, dynamic>? historyRecord;

  const AskAIPage({Key? key, this.historyRecord}) : super(key: key);

  @override
  State<AskAIPage> createState() => _AskAIPageState();
}

class _AskAIPageState extends State<AskAIPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    String welcomeText;
    List<String> suggestions;

    if (widget.historyRecord != null) {
      welcomeText =
          "Hello! I see you have a question about your record for '${widget.historyRecord!['diagnosis']}'. How can I help you today?";
      suggestions = [
        "What are the common treatments for ${widget.historyRecord!['diagnosis']}?",
        "Is ${widget.historyRecord!['diagnosis']} contagious?",
        "What lifestyle changes can help?",
      ];
    } else {
      welcomeText =
          "Hello! I'm your personal AI assistant. How can I help you with your skin concerns today?";
      suggestions = [
        "What are the symptoms of acne?",
        "How can I treat dry skin?",
        "What is this rash?",
      ];
    }
    setState(() {
      _messages.add(_ChatMessage(
        text: welcomeText,
        isUser: false,
        suggestions: suggestions,
      ));
    });
  }

  void _sendMessage({String? text}) {
    final messageText = text ?? _controller.text;
    if (messageText.isNotEmpty) {
      setState(() {
        // Remove suggestions from previous messages
        for (var i = 0; i < _messages.length; i++) {
          if (_messages[i].suggestions != null) {
            _messages[i] = _ChatMessage(text: _messages[i].text, isUser: _messages[i].isUser);
          }
        }
        _messages.add(_ChatMessage(text: messageText, isUser: true));
        _controller.clear();

        // Simulate AI response
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _messages.add(_ChatMessage(
                text: "Thank you for your question. I am analyzing it and will provide a response shortly.",
                isUser: false));
            _scrollToBottom();
          });
        });
      });
      _scrollToBottom();
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isAi = !message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAi)
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
              if (isAi) const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: isAi ? AppColors.secondary : AppColors.primary,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(color: isAi ? Colors.black87 : Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (message.suggestions != null && message.suggestions!.isNotEmpty)
            _buildSuggestionChips(message.suggestions!),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(List<String> suggestions) {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0, top: 10.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: suggestions.map((q) {
          return ActionChip(
            label: Text(q, style: const TextStyle(color: AppColors.primary)),
            onPressed: () => _sendMessage(text: q),
            backgroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: () => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }
}
