import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/conversation_service.dart';
import '../../../data/providers/app_state_provider.dart';
import '../../widgets/ai_widgets/model_selection_dialog.dart';
import 'chat_screen.dart';
import 'conversation_list_screen.dart';
import 'login_screen.dart';
import 'model_browser_screen.dart';
import 'user_manual_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _HomeScreenView(ref: ref);
  }
}

class _HomeScreenView extends StatefulWidget {
  final WidgetRef ref;

  const _HomeScreenView({required this.ref});

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView> {
  final ConversationService _conversationService = ConversationService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize conversation storage
      await _conversationService.init();

      // Check auth and model status using providers
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 100));

      widget.ref.read(authProvider.notifier).checkAuthStatus();
      widget.ref.read(modelAvailabilityProvider.notifier).checkForModels();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      log('Error initializing app: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _navigateToChat() async {
    final modelAvailability = widget.ref.read(modelAvailabilityStateProvider);

    if (modelAvailability.hasModel) {
      // Show model selection dialog
      final selectedModelPath = await showDialog<String>(
        context: context,
        builder: (context) => const ModelSelectionDialog(),
      );

      if (selectedModelPath != null) {
        // Load the selected model
        final loaded = await widget.ref
            .read(modelLoaderProvider.notifier)
            .loadSpecificModel(
              selectedModelPath,
              onStatus: (status) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(status)));
              },
            );

        if (loaded) {
          // ignore: use_build_context_synchronously
          Navigator.of(
            // ignore: use_build_context_synchronously
            context,
          ).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(
            // ignore: use_build_context_synchronously
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to load model')));
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No models available')));
    }
  }

  void _navigateToModelBrowser() {
    final authState = widget.ref.read(authStateProvider);

    if (authState.isLoggedIn) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ModelBrowserScreen()));
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _navigateToConversations() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ConversationListScreen()));
  }

  void _navigateToUserManual() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UserManualScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final modelAvailability = ref.watch(modelAvailabilityStateProvider);
        final authState = ref.watch(authStateProvider);

        if (!_isInitialized || modelAvailability.isLoading) {
          return _buildLoadingState();
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green.shade900, Colors.black],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LAST HOPE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          onPressed: _navigateToConversations,
                          icon: const Icon(Icons.history, color: Colors.white),
                          tooltip: 'Conversation History',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                modelAvailability.hasModel
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: modelAvailability.hasModel
                                    ? Colors.green
                                    : Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                modelAvailability.hasModel
                                    ? 'Model Available'
                                    : 'No Model Found',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            modelAvailability.hasModel
                                ? 'Ready to start chatting with your AI assistant'
                                : 'Please download a model to start using the app',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                          if (modelAvailability.error != null)
                            Text(
                              'Error: ${modelAvailability.error}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Main Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: modelAvailability.hasModel
                            ? _navigateToChat
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: modelAvailability.hasModel
                              ? Colors.green
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: modelAvailability.hasModel ? 8 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              modelAvailability.hasModel
                                  ? 'Start Chat'
                                  : 'No Model Available',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Secondary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _navigateToModelBrowser,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              authState.isLoggedIn ? Icons.folder : Icons.login,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              authState.isLoggedIn
                                  ? 'Browse Models'
                                  : 'Sign In to Download Models',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Debug Information
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Information',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Models Found: ${modelAvailability.availableModels.length}',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                          ),
                          if (modelAvailability.availableModels.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Models:',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                  ),
                                ),
                                ...modelAvailability.availableModels
                                    .take(3)
                                    .map(
                                      (model) => Text(
                                        '• ${model.split('/').last}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickAction(
                                  icon: Icons.refresh,
                                  label: 'Refresh',
                                  onTap: () async {
                                    await ref
                                        .read(
                                          modelAvailabilityProvider.notifier,
                                        )
                                        .refreshModels();
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Model status refreshed'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildQuickAction(
                                  icon: Icons.book_outlined,
                                  label: 'User Manual',
                                  onTap: _navigateToUserManual,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickAction(
                                  icon: Icons.manage_search,
                                  label: 'Manage Models',
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const ModelSelectionDialog(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade900, Colors.black],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.forest, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'LAST HOPE',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Offline Survival AI',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 20),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
