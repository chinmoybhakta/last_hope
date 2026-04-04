import 'package:flutter/material.dart';

class SignInWithHuggingFaceButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignInWithHuggingFaceButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: .spaceBetween,
        children: [
          // Hugging Face emoji as placeholder
          const Text('🤗', style: TextStyle(fontSize: 24)),
          const Text(
            'Sign in',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}