// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 04 05 2026
// - ADD: armazena layerIndex para reinseir no layer correto durante undo
// - CHG: usa CadDocument em vez de Scene
//
// [1.0.1] - 04 05 2026
// - FIX: uso de scene.remove e scene.insert
//
// [1.0.0] - 02 05 2026
// - ADD: RemoveShapeCommand para undo/redo na exclusão de entidades

import 'package:canvas_engine/commands/command.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/documents/cad_document.dart';

class RemoveShapeCommand implements Command {
  final CadDocument document;
  final Shape shape;
  final int layerIndex;    // índice do layer onde a shape estava
  final int shapeIndex;    // índice da shape dentro do layer

  RemoveShapeCommand({
    required this.document,
    required this.shape,
    required this.layerIndex,
    required this.shapeIndex,
  });

  @override
  void execute() {
    document.remove(shape);
  }

  @override
  void undo() {
    document.insert(layerIndex, shapeIndex, shape);
  }
}