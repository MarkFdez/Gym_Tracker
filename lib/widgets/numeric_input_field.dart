import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool allowDecimal;

  const NumericInputField({
    super.key,
    required this.controller,
    required this.label,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: allowDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(allowDecimal ? r'^\d+\.?\d{0,2}' : r'\d+'),
        ),
      ],
    );
  }
}
