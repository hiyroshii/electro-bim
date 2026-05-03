// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: MoveGripCommand — move um grip e permite desfazer
// - ADD: armazena from/to para undo preciso

import 'package:canvas_engine/commands/command.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';

class MoveGripCommand implements Command {
  final Shape shape;
  final int gripIndex;
  final Vector3 from;
  final Vector3 to;

  MoveGripCommand({
    required this.shape,
    required this.gripIndex,
    required this.from,
    required this.to,
  });

  @override
  void execute() => shape.moveGrip(gripIndex, to);

  @override
  void undo() => shape.moveGrip(gripIndex, from);
}