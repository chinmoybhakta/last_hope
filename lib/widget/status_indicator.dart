import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String message;
  final bool isReady;
  final bool isLoading;
  
  const StatusIndicator({
    super.key,
    required this.message,
    this.isReady = false,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    Color textColor;
    IconData icon;
    
    if (isLoading) {
      textColor = Colors.orange;
      icon = Icons.downloading;
    } else if (isReady) {
      textColor = Colors.green;
      icon = Icons.check_circle;
    } else {
      textColor = Colors.grey;
      icon = Icons.warning_amber;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}