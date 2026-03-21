import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:last_hope/feature/screens/ai_screens/setting_screen.dart';
import '../../../core/services/conversation_service.dart';
import '../../../core/services/model_loader_service.dart';
import '../../../data/models/conversation_message.dart';

// UI ChatMessage class
class ChatMessage {
  String text;
  bool isUser;
  bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
  });
}

// Preprocess AI response to remove leading punctuation and clean up formatting
String _preprocessResponse(String response) {
  if (response.isEmpty) return response;
  
  // Remove leading punctuation (.?!)
  String cleaned = response;
  while (cleaned.isNotEmpty && RegExp(r'^[.?!]').hasMatch(cleaned[0])) {
    cleaned = cleaned.substring(1).trim();
  }
  
  // Ensure first character is capitalized
  if (cleaned.isNotEmpty && cleaned[0] == cleaned[0].toLowerCase()) {
    cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
  }
  
  return cleaned;
}

class ChatScreen extends StatefulWidget {
  final String? conversationId;

  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ModelLoaderService _loader = ModelLoaderService();
  final ConversationService _conversationService = ConversationService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  String _status = 'Loading model...';
  Conversation? _conversation;
  
  // Stream subscription and disposal tracking
  StreamSubscription<String>? _responseSubscription;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Load or create conversation
    if (widget.conversationId != null) {
      _conversation = _conversationService.getConversation(widget.conversationId!);
      if (_conversation != null) {
        // Convert stored messages to UI messages
        _messages.clear();
        for (final msg in _conversation!.messages) {
          _messages.add(ChatMessage(
            text: msg.content,
            isUser: msg.isUser,
            isLoading: false,
          ));
        }
      }
    }
    
    // Load model
    await _loadModel();
  }

  Future<void> _loadModel() async {
    if (!_loader.isLoaded) {
      final loaded = await _loader.loadFirstAvailableModel(
        onStatus: (status) {
          setState(() {
            _status = status;
          });
        },
      );
      
      if (!loaded) {
        setState(() {
          _status = 'No model loaded. Please download a model first.';
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelResponseStream();
    _controller.dispose();
    super.dispose();
  }

  void _cancelResponseStream() {
    if (_responseSubscription != null) {
      _responseSubscription!.cancel();
      _responseSubscription = null;
    }
    // Also stop the model generation if active
    if (_isGenerating) {
      _loader.stopGeneration();
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _sendMessage() async {
    if (!_loader.isLoaded) {
      setState(() {
        _messages.add(ChatMessage(text: 'Please wait for model to load...', isUser: false));
      });
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Create or get conversation
    _conversation ??= await _conversationService.createConversation(
        'Chat ${DateFormat('MMM dd, HH:mm').format(DateTime.now())}',
      );

    // Save user message
    final userMessage = ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
      modelUsed: 'TinyLlama', // Could be dynamic
    );

    await _conversationService.addMessage(_conversation!.id, userMessage);

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isGenerating = true;
      _messages.add(ChatMessage(text: '', isUser: false, isLoading: true));
    });

    try {
      String response = '';
      
      // Cancel any existing subscription
      _cancelResponseStream();
      
      // Use new streaming API with subscription tracking
      final stream = _loader.generateResponse(text);
      
      _responseSubscription = stream.listen(
        (token) {
          if (!_isDisposed) {
            response += token;
            _safeSetState(() {
              _messages.last.text = _preprocessResponse(response);
            });
          }
        },
        onError: (error) {
          if (!_isDisposed) {
            _safeSetState(() {
              _messages.last.text = 'Error: $error';
              _messages.last.isLoading = false;
              _isGenerating = false;
            });
            log('Stream error: $error');
          }
        },
        onDone: () {
          if (!_isDisposed) {
            _safeSetState(() {
              _messages.last.isLoading = false;
              _isGenerating = false;
            });

            // Save AI response with preprocessing
            if (_conversation != null && response.isNotEmpty) {
              final processedResponse = _preprocessResponse(response);
              final aiMessage = ConversationMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                content: processedResponse,
                isUser: false,
                timestamp: DateTime.now(),
                modelUsed: 'TinyLlama',
              );
              _conversationService.addMessage(_conversation!.id, aiMessage);
            }
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!_isDisposed) {
        _safeSetState(() {
          _messages.last.text = 'Error: $e';
          _messages.last.isLoading = false;
          _isGenerating = false;
        });
        log('Error in _sendMessage: $e');
      }
    } finally {
      _responseSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survival Assistant'),
        backgroundColor: Colors.green[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=> SettingsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Model status indicator
          if (!_loader.isLoaded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange[900],
              child: Row(
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                return MessageBubble(message: msg);
              },
            ),
          ),
          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                top: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isGenerating,
                    decoration: InputDecoration(
                      hintText: 'Ask a survival question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green[800],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isGenerating ? null : _sendMessage,
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

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(Icons.forest, size: 16, color: Colors.white),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                if (!message.isLoading && message.text.isNotEmpty) {
                  _copyToClipboard(context, message.text);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: message.isUser ? Colors.green[800] : Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        message.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    if (!message.isLoading && message.text.isNotEmpty)
                      const SizedBox(height: 4),
                    if (!message.isLoading && message.text.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.content_copy,
                            color: Colors.grey[400],
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap and hold to copy',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}