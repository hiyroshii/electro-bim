// REV: 1.0.3
// CHANGELOG:
// [1.0.3] - 04 05 2026
// - ADD: undo durante desenho de polilinha/linha (Ctrl+Z quando ferramenta ativa)
// - ADD: Delete para excluir entidade selecionada
// - CHG: Ctrl+Z no modo draw cancela último segmento ou reseta linha
//
// [1.0.2] - 02 05 2026
// - ADD: atalho Delete (LogicalKeyboardKey.delete) para excluir entidade selecionada
//
// [1.0.1] - 02 05 2026
// - REM: setas removidas (tratadas diretamente no CanvasView para nudge contínuo)
//
// [1.0.0] - 02 05 2026
// - ADD: função handleKeyEvent centralizando atalhos de teclado
// - undo/redo (Ctrl+Z / Ctrl+Y), Escape, V (select), N (pan)

import 'package:flutter/services.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;

bool handleKeyEvent(
  KeyEvent event,
  engine.InputController input,
  void Function() repaint,
  void Function() setToolSelect,
  void Function() setToolPan,
) {
  if (event is! KeyDownEvent) return false;

  final key = event.logicalKey;
  final ctrl = HardwareKeyboard.instance.isControlPressed ||
      HardwareKeyboard.instance.isMetaPressed;

  // Undo / Redo
  if (key == LogicalKeyboardKey.keyZ && ctrl) {
    if (input.mode == engine.CanvasMode.draw && input.tool.isActive) {
      input.undoDrawing();           // desfaz último ponto/cancela linha
    } else {
      input.undoManager.undo();      // undo normal
    }
    repaint();
    return true;
  }
  if (key == LogicalKeyboardKey.keyY && ctrl) {
    input.undoManager.redo();
    repaint();
    return true;
  }

  // Escape
  if (key == LogicalKeyboardKey.escape) {
    if (input.mode == engine.CanvasMode.select ||
        input.mode == engine.CanvasMode.navigate) {
      input.clearSelection();
    } else {
      input.finishTool();
    }
    repaint();
    return true;
  }

  // Ferramentas
  if (key == LogicalKeyboardKey.keyV) {
    setToolSelect();
    return true;
  }
  if (key == LogicalKeyboardKey.keyN) {
    setToolPan();
    return true;
  }

  // Excluir entidade selecionada
  if (key == LogicalKeyboardKey.delete) {
    input.deleteSelected();
    repaint();
    return true;
  }

  return false;
}