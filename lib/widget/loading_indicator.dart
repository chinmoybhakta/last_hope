import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final Color? color;
  
  const LoadingIndicator({
    super.key,
    required this.message,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: color != null
                ? AlwaysStoppedAnimation<Color>(color!)
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              color: color ?? Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}