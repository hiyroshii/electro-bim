// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 05 05 2026
// - FIX: substituição de Color.value depreciado por Color == e toARGB32()
// [1.0.0] - 04 05 2026
// - ADD: ColorPalette — grid de cores predefinidas para escolha de cor do layer
// - ADD: suporte a cores padrão (16 cores básicas + cinzas)

import 'package:flutter/material.dart';

class ColorPalette extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  static const List<Color> colors = [
    // Vermelhos e laranjas
    Color(0xFFFF0000),
    Color(0xFFFF4444),
    Color(0xFFFF8800),
    Color(0xFFFFCC00),
    // Amarelos e verdes
    Color(0xFFFFFF00),
    Color(0xFF88FF00),
    Color(0xFF00FF00),
    Color(0xFF00AA00),
    // Cianos e azuis
    Color(0xFF00FFFF),
    Color(0xFF0088FF),
    Color(0xFF0000FF),
    Color(0xFF4400FF),
    // Roxos e magentas
    Color(0xFF8800FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0088),
    Color(0xFF880088),
    // Preto e cinzas
    Color(0xFF000000),
    Color(0xFF444444),
    Color(0xFF888888),
    Color(0xFFBBBBBB),
    Color(0xFFDDDDDD),
    Color(0xFFFFFFFF),
  ];

  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: colors.map((color) {
        final isSelected = color == selectedColor; // ✅ corrigido
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Diálogo de seleção de cor usando ColorPalette.
Future<Color?> showColorPickerDialog(BuildContext context, Color currentColor) {
  return showDialog<Color>(
    context: context,
    builder: (context) {
      Color selected = currentColor;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Selecionar Cor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPalette(
                  selectedColor: selected,
                  onColorSelected: (color) => setState(() => selected = color),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: selected,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      // ✅ corrigido: usar toARGB32() e formatar com padding
                      '#${selected.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}