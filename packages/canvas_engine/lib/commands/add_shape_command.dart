// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 04 05 2026
// - ADD: registro do layer de origem (CadDocument/layer) para undo/redo preciso
// - CHG: usa CadDocument em vez de Scene
//
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
import 'package:canvas_engine/domain/documents/cad_document.dart';

class AddShapeCommand implements Command {
  final CadDocument document;
  final Shape shape;
  final int layerIndex; // índice do layer onde a shape foi criada

  AddShapeCommand({
    required this.document,
    required this.shape,
    required this.layerIndex,
  });

  @override
  void execute() {
    if (!document.contains(shape)) {
      // reinsere no layer original
      if (layerIndex >= 0 && layerIndex < document.layers.length) {
        document.layers[layerIndex].add(shape);
      } else {
        document.add(shape); // fallback: layer ativa
      }
    }
  }

  @override
  void undo() {
    document.remove(shape);
  }
}