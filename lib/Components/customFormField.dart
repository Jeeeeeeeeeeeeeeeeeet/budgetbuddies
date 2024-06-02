import 'package:flutter/material.dart';

class customFormField extends StatelessWidget {

  final controller;
  final String hintText;
  final bool obscureText;

  const customFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          fillColor: Colors.grey.shade100,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.grey.shade100,
              width: 2.0,
            ),
          ),
          focusedBorder:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.grey.shade100,
              width: 2.0,
            ),
          )
      ),
    );
  }
}