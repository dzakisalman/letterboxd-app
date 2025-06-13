import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final Function(T) onToggle;
  final Function() onClear;
  final String Function(T) itemLabelBuilder;
  final bool isSingleSelect;

  const FilterSection({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onToggle,
    required this.onClear,
    required this.itemLabelBuilder,
    this.isSingleSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (selectedItems.isNotEmpty)
            TextButton(
              onPressed: onClear,
              child: Text(
                'Clear All',
                style: GoogleFonts.openSans(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      shape: const Border(),
      collapsedShape: const Border(),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(
                itemLabelBuilder(item),
                style: GoogleFonts.openSans(
                  color: isSelected ? const Color(0xFF1F1D36) : Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) => onToggle(item),
              backgroundColor: const Color(0xFF3D3B54),
              selectedColor: const Color(0xFFE9A6A6),
              checkmarkColor: const Color(0xFF1F1D36),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
} 