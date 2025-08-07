import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/image_generation_service.dart';
import '../constants/api_constants.dart';

class Message {
  final String text;
  final bool isUser;
  final String? imageBase64;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    this.imageBase64,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CopticImageGenerationService _imageService =
      CopticImageGenerationService(
    huggingFaceApiKey: ApiConstants.huggingFaceApiKey,
  );

  List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(Message(
      text:
          "مرحباً! أنا مولد الصور القبطية. اكتب وصفاً بالعربية لصورة دينية قبطية وسوف إنشاء الصورة لك باستخدام الذكاء الاصطناعي.",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _generateResponse(String userInput) async {
    setState(() {
      _messages.add(Message(
        text: userInput,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final imageBase64 = await _imageService.generateCopticImage(userInput);
      setState(() {
        _messages.add(Message(
          text: "تم إنشاء الصورة بنجاح:",
          isUser: false,
          imageBase64: imageBase64,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          text: "عذراً، حدث خطأ في إنشاء الصورة. حاول مرة أخرى.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit() {
    final input = _controller.text.trim();
    if (input.isNotEmpty && !_isLoading) {
      _generateResponse(input);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF212121) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF2D2D2D) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, size: 24),
            SizedBox(width: 8),
            Text("مولد الصور القبطية ",
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, isDark);
              },
            ),
          ),
          if (_isLoading)
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 16),
                  Text("جاري إنشاء الصورة...",
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
            ),
          _buildInputSection(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.indigo
                    : (isDark ? Color(0xFF2D2D2D) : Colors.white),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 16,
                    ),
                  ),
                  if (message.imageBase64 != null) ...[
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(message.imageBase64!.split(',').last),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: 200,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                'فشل في تحميل الصورة',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2D2D2D) : Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF3D3D3D) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "اكتب وصف الصورة القبطية التي تريدها هنا...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  maxLines: null,
                  enabled: !_isLoading,
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: _isLoading ? null : _handleSubmit,
                icon: Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.send,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
