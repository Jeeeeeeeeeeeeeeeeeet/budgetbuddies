import 'package:flutter/material.dart';

class profileformfield extends StatelessWidget{

  final String labelName;
  final String? hintText;
  final bool obscureText;
  final controller;


  const profileformfield({super.key, required this.controller, required this.labelName, this.hintText, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(labelName),
          ],
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hintText,
            filled: true,
          ),
        ),
        ],
    );
  }
}