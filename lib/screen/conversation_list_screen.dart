import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:last_hope_ai/data/model/conversation_message.dart';
import 'package:last_hope_ai/data/provider/app_state_provider.dart';
import 'package:last_hope_ai/service/conversation_service.dart';
import 'package:last_hope_ai/widget/model_selection_dialog.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final ConversationService _conversationService = ConversationService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversations = _conversationService.getAllConversations();
      _isLoading = false;
    });
  }

  void _deleteConversation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _conversationService.deleteConversation(id);
      _loadConversations();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation deleted')),
      );
    }
  }


  void _openConversation(Conversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(conversationId: conversation.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: const Text('Conversation History'),
        actions: [
          IconButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All'),
                  content: const Text('Delete all conversations?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete All', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _conversationService.clearAll();
                _loadConversations();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All conversations cleared')),
                );
              }
            },
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _conversations.isEmpty
              ? _buildEmptyState()
              : _buildConversationList(),
      floatingActionButton: Consumer(
        builder: (_, ref, _) {
          final modelAvailability = ref.watch(modelAvailabilityStateProvider);
          void navigateToChat() async {
            if (modelAvailability.hasModel) {
              // Show model selection dialog
              final selectedModelPath = await showDialog<String>(
                context: context,
                builder: (context) => const ModelSelectionDialog(),
              );

              if (selectedModelPath != null) {
                // Load the selected model
                final loaded = await ref.read(modelLoaderProvider.notifier).loadSpecificModel(
                  selectedModelPath,
                  onStatus: (status) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(status)),
                    );
                  },
                );

                if (loaded) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to load model')),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No models available')),
              );
            }
          }
          return FloatingActionButton(
            onPressed: modelAvailability.hasModel ? navigateToChat : null,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 20),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start a new chat to see it here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (_, ref, _) {
              final modelAvailability = ref.watch(modelAvailabilityStateProvider);
              void navigateToChat() async {
                if (modelAvailability.hasModel) {
                  // Show model selection dialog
                  final selectedModelPath = await showDialog<String>(
                    context: context,
                    builder: (context) => const ModelSelectionDialog(),
                  );

                  if (selectedModelPath != null) {
                    // Load the selected model
                    final loaded = await ref.read(modelLoaderProvider.notifier).loadSpecificModel(
                      selectedModelPath,
                      onStatus: (status) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(status)),
                        );
                      },
                    );

                    if (loaded) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to load model')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No models available')),
                  );
                }
              }
              return ElevatedButton(
                onPressed: modelAvailability.hasModel ? navigateToChat : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start New Chat'),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationCard(conversation);
      },
    );
  }

  Widget _buildConversationCard(Conversation conversation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Colors.grey[900],
      child: ListTile(
        onTap: () => _openConversation(conversation),
        title: Text(
          conversation.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (conversation.messages.isNotEmpty)
              Text(
                conversation.messages.last.content,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                'No messages yet',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Updated ${DateFormat('MMM dd, HH:mm').format(conversation.updatedAt)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          color: Colors.white,
          onSelected: (value) {
            if (value == 'delete') {
              _deleteConversation(conversation.id);
            } else if (value == 'rename') {
              _renameConversation(conversation);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Rename'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _renameConversation(Conversation conversation) async {
    final controller = TextEditingController(text: conversation.title);
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty) {
      await _conversationService.updateConversationTitle(conversation.id, newName.trim());
      _loadConversations();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation renamed')),
      );
    }
  }
}
