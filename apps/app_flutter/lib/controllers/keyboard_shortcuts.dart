// REV: 1.1.0
// CHANGELOG:
// - ADD: atalhos R (Rectangle) e C (Circle)
// - CHG: assinatura da função expandida com setToolRectangle e setToolCircle

import 'package:flutter/services.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;

bool handleKeyEvent(
  KeyEvent event,
  engine.InputController input,
  void Function() repaint,
  void Function() setToolSelect,
  void Function() setToolPan,
  void Function() setToolRectangle,
  void Function() setToolCircle,
) {
  if (event is! KeyDownEvent) return false;

  final key = event.logicalKey;
  final ctrl = HardwareKeyboard.instance.isControlPressed ||
      HardwareKeyboard.instance.isMetaPressed;

  // Undo / Redo
  if (key == LogicalKeyboardKey.keyZ && ctrl) {
    if (input.mode == engine.CanvasMode.draw && input.tool.isActive) {
      input.undoDrawing();
    } else {
      input.undoManager.undo();
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
  if (key == LogicalKeyboardKey.keyR) {
    setToolRectangle();
    return true;
  }
  if (key == LogicalKeyboardKey.keyC) {
    setToolCircle();
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