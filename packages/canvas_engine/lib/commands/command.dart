// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: interface Command para padrão undo/redo
// - ADD: execute() e undo() obrigatórios

abstract class Command {
  void execute();
  void undo();
}