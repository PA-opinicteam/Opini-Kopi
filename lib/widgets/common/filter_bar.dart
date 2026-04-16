import 'package:flutter/material.dart';
import 'package:opini_kopi/constants/app_colors.dart';

class FilterBar<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T item) labelBuilder;

  const FilterBar({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(8),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(labelBuilder(item)),
              ),
            )
            .toList(),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }
}
