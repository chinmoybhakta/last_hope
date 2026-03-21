import 'package:flutter/material.dart';

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> sections = [
    {
      'title': '📱 Welcome to Last Hope',
      'content': 'Last Hope is your personal offline AI survival assistant that works completely without internet connectivity.',
      'icon': Icons.home,
      'color': Colors.green,
    },
    {
      'title': '🚀 Quick Start Guide',
      'content': '1. Launch the app\n2. Download your first model\n3. Start your first conversation',
      'icon': Icons.rocket_launch,
      'color': Colors.blue,
    },
    {
      'title': '🏕️ Survival Capabilities',
      'content': '• Daily needs & essentials\n• Hunting & fishing\n• First aid & medical\n• Navigation & orientation\n• Emergency protocols\n• Resource management',
      'icon': Icons.campaign,
      'color': Colors.orange,
    },
    {
      'title': '💬 Getting Best Responses',
      'content': 'Ask specific questions like:\n• "How do I purify water in the wilderness?"\n• "What should I do if I encounter a bear?"\n• "How do I build a debris shelter?"',
      'icon': Icons.chat,
      'color': Colors.purple,
    },
    {
      'title': '🗂️ Conversation Management',
      'content': '• All conversations auto-saved\n• Access via History button\n• Rename conversations for organization\n• Delete unwanted conversations',
      'icon': Icons.history,
      'color': Colors.teal,
    },
    {
      'title': '🔧 Model Management',
      'content': '• TinyLlama 1.1B (600MB) - Fast, basic\n• Phi-2 2.7B (900MB) - Complex reasoning\n• Llama 3.2 1B (800MB) - Better conversations\n• Qwen 2.5 1.5B (900MB) - Best overall',
      'icon': Icons.settings_suggest,
      'color': Colors.red,
    },
    {
      'title': '🆘 Emergency Quick Reference',
      'content': 'Rule of 3s:\n• 3 minutes without air\n• 3 hours without shelter\n• 3 days without water\n• 3 weeks without food',
      'icon': Icons.emergency,
      'color': Colors.amber,
    },
    {
      'title': '📚 Advanced Usage Tips',
      'content': '• Build reference library conversations\n• Ask follow-up questions\n• Test different scenarios\n• Choose right model for task',
      'icon': Icons.psychology,
      'color': Colors.indigo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'User Manual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _showAboutDialog,
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: sections.length + 1, // +1 for the header section
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeaderSection();
                    }
                    
                    final section = sections[index - 1];
                    return _buildSectionCard(section);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.green.shade300, size: 30),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Last Hope - Offline AI Survival Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Your complete guide to using the offline AI survival assistant. Works 100% without internet connection!',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              _buildFeatureChip('100% Offline', Icons.wifi_off),
              _buildFeatureChip('Privacy First', Icons.lock),
              _buildFeatureChip('AI Powered', Icons.smart_toy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return SizedBox(
      width: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green.shade300, size: 16),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.green.shade300,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section) {
    final icon = section['icon'] as IconData;
    final color = section['color'] as Color;
    final title = section['title'] as String;
    final content = section['content'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Last Hope'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0'),
            SizedBox(height: 10),
            Text('Last Hope is your offline AI survival assistant, providing expert guidance when you need it most.'),
            SizedBox(height: 10),
            Text('Features:'),
            Text('• 100% offline operation'),
            Text('• Multiple AI models'),
            Text('• Conversation memory'),
            Text('• Privacy-first design'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
