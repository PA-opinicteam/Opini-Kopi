import 'package:flutter/material.dart';
import 'package:opini_kopi/constants/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final Color fillColor;

  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.fillColor = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
