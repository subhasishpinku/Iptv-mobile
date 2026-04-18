import 'package:flutter/material.dart';

class TextWidgets extends StatelessWidget {
  const TextWidgets({
    super.key,
    required this.textController,
    required this.labelText,
    required this.hintText,
    required this.obscureText,
  });

  final TextEditingController textController;
  final String labelText;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        obscureText: obscureText,
        obscuringCharacter: "*",
        controller: textController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          hintText: hintText,
        ),
      ),
    );
  }
}