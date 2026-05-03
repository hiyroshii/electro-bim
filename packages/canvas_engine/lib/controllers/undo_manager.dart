// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: UndoManager com pilha de Commands
// - ADD: canUndo / canRedo expostos
// - ADD: clear() para resetar estado

import 'package:flutter/foundation.dart';
import 'package:canvas_engine/commands/command.dart';

class UndoManager extends ChangeNotifier {
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void execute(Command command) {
    command.execute();
    _undoStack.add(command);
    _redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    final command = _undoStack.removeLast();
    command.undo();
    _redoStack.add(command);
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    final command = _redoStack.removeLast();
    command.execute();
    _undoStack.add(command);
    notifyListeners();
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }
}