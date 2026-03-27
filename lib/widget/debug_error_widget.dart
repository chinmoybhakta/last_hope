import 'package:flutter/material.dart';

class DebugErrorWidget extends StatelessWidget {
  final Widget child;
  final String? name;

  const DebugErrorWidget({
    super.key,
    required this.child,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🐛 DebugErrorWidget: Building ${name ?? 'widget'}');
    
    // Set error handler for this widget build
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      debugPrint('🐛 ERROR in ${name ?? 'widget'}: ${errorDetails.exception}');
      debugPrint('🐛 Stack: ${errorDetails.stack}');
      
      return Material(
        color: Colors.red,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.white, size: 50),
              const SizedBox(height: 10),
              const Text(
                'Widget Error',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                name ?? 'Unknown Widget',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Text(
                errorDetails.exception.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    };

    debugPrint('🐛 DebugErrorWidget: Returning child');
    return child;
  }
}
