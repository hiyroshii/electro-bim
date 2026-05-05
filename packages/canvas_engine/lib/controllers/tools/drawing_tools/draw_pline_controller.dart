// REV: 1.5.0
// CHANGELOG:
// [1.5.0] - 04 05 2026
// - CHG: onTap e finish usam CadDocument; _scene renomeado para _document
//
// ... (histórico mantido)

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/documents/cad_document.dart';
import 'package:canvas_engine/domain/entities/pline_shape.dart';
import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/controllers/tools/drawing_tools/drawing_tools_contract.dart';

class DrawPlineController implements DrawingTool {
  final List<Vector3> _vertices = [];
  Vector3? current;
  CadDocument? _document;   // alterado de Scene?

  List<Vector3> get vertices => List.unmodifiable(_vertices);

  @override
  bool get isActive => _vertices.isNotEmpty;

  int get pointCount => _vertices.length;

  @override
  void onTap(Vector3 point, CadDocument document) {
    _document = document;
    _vertices.add(point);
    current = point;
  }

  @override
  void onMove(Vector3 point) {
    if (_vertices.isNotEmpty) current = point;
  }

  @override
  void finish() {
    if (_vertices.length >= 2 && _document != null) {
      _document!.add(PlineShape(List.from(_vertices)));
    }
    reset();
  }

  @override
  void reset() {
    _vertices.clear();
    current = null;
    _document = null;
  }

  void undoLastPoint() {
    if (_vertices.isEmpty) return;
    _vertices.removeLast();
    if (_vertices.isEmpty) {
      current = null;
    } else {
      current = _vertices.last;
    }
  }

  void cancel() => reset();

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