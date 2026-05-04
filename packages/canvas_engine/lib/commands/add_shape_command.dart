// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 04 05 2026
// - FIX: uso de scene.add e scene.remove (evita UnmodifiableListView)
//
// [1.0.1] - 02 05 2026
// - FIX: execute só adiciona se a shape não estiver no scene
//
// [1.0.0] - 02 05 2026
// - ADD: AddShapeCommand para undo/redo na criação de entidades

import 'package:canvas_engine/commands/command.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/engine/scene.dart';

class AddShapeCommand implements Command {
  final Scene scene;
  final Shape shape;

  AddShapeCommand({required this.scene, required this.shape});

  @override
  void execute() {
    if (!scene.elements.contains(shape)) {
      scene.add(shape);
    }
  }

  @override
  void undo() {
    scene.remove(shape);
  }
}