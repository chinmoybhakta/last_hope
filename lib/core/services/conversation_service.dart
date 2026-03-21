import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/conversation_message.dart';
import 'hive_service.dart';

class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  late Box<Conversation> _conversationsBox;

  Future<void> init() async {
    final hiveService = HiveService();
    _conversationsBox = await hiveService.openBox<Conversation>('conversations');
  }

  // Get all conversations
  List<Conversation> getAllConversations() {
    return _conversationsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // Get conversation by ID
  Conversation? getConversation(String id) {
    try {
      return _conversationsBox.values
          .cast<Conversation>()
          .firstWhere((conv) => conv.id == id);
    } catch (e) {
      return null;
    }
  }

  // Save conversation
  Future<void> saveConversation(Conversation conversation) async {
    await _conversationsBox.put(conversation.id, conversation);
  }

  // Add message to conversation
  Future<void> addMessage(String conversationId, ConversationMessage message) async {
    final conversation = getConversation(conversationId);
    if (conversation != null) {
      final updatedMessages = [...conversation.messages, message];
      final updatedConversation = conversation.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );
      await saveConversation(updatedConversation);
    }
  }

  // Create new conversation
  Future<Conversation> createConversation(String title) async {
    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await saveConversation(conversation);
    return conversation;
  }

  // Delete conversation
  Future<void> deleteConversation(String id) async {
    await _conversationsBox.delete(id);
  }

  // Clear all conversations
  Future<void> clearAll() async {
    await _conversationsBox.clear();
  }

  // Update conversation title
  Future<void> updateConversationTitle(String id, String newTitle) async {
    final conversation = getConversation(id);
    if (conversation != null) {
      final updatedConversation = conversation.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      await saveConversation(updatedConversation);
    }
  }
}
