// REV: 1.4.0
// CHANGELOG:
// [1.4.0] - 02 05 2026
// - ADD: undoLastPoint() para desfazer último vértice durante o desenho
// - ADD: getter isActive e pointCount
// - ADD: cancel() para resetar sem finalizar (Ctrl+Z na polilinha vazia)
// - FIX: Ctrl+Z durante desenho agora remove vértices sem perder a ferramenta
//
// [1.3.0] - 02 05 2026
// - FIX: scene armazenado como campo para uso em finish()
// - CHG: acumula vértices em lista interna
// - CHG: drawPreview() renderiza polyline parcial
// - CHG: finish() cria PlineShape unificada e adiciona à scene
// - CHG: reset() limpa sem criar entidade
// - FIX: não mais cria LineShape individuais
// - CHG: implements DrawingTool (ex-Tool)
//
// [1.2.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.0] - 01 05 2026
// - ADD: DrawPlineController — polilinha contínua

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/engine/scene.dart';
import 'package:canvas_engine/domain/entities/pline_shape.dart';
import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/controllers/tools/drawing_tools/drawing_tools_contract.dart';

class DrawPlineController implements DrawingTool {
  final List<Vector3> _vertices = [];
  Vector3? current;
  Scene? _scene;

  List<Vector3> get vertices => List.unmodifiable(_vertices);

  @override
  bool get isActive => _vertices.isNotEmpty;

  int get pointCount => _vertices.length;

  @override
  void onTap(Vector3 point, Scene scene) {
    _scene = scene;
    _vertices.add(point);
    current = point;
  }

  @override
  void onMove(Vector3 point) {
    if (_vertices.isNotEmpty) current = point;
  }

  @override
  void finish() {
    if (_vertices.length >= 2 && _scene != null) {
      _scene!.add(PlineShape(List.from(_vertices)));
    }
    reset();
  }

  @override
  void reset() {
    _vertices.clear();
    current = null;
    _scene = null;
  }

  /// Remove o último vértice inserido. Se sobrar 1 vértice, também o remove.
  void undoLastPoint() {
    if (_vertices.isEmpty) return;
    _vertices.removeLast();
    if (_vertices.isEmpty) {
      current = null; // sem vértices, não há preview
    } else {
      current = _vertices.last;
    }
  }

  /// Cancela completamente a polilinha (reseta estado sem adicionar ao scene).
  void cancel() {
    reset();
  }

  @override
  void drawPreview(RenderAdapter adapter) {
    final preview = [..._vertices];
    if (current != null && _vertices.isNotEmpty) {
      preview.add(current!);
    }
    for (int i = 0; i < preview.length - 1; i++) {
      adapter.drawLine(preview[i], preview[i + 1]);
    }
  }
}