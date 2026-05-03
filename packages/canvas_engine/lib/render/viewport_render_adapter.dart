// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.0] - 29 04 2026
// - ADD: ViewportRenderAdapter — converte WORLD para SCREEN antes de renderizar
// - FIX: imports absolutos (eram relativos)

import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/viewport/viewport.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';

/// Adapter intermediário que aplica a transformação WORLD → SCREEN.
class ViewportRenderAdapter implements RenderAdapter {
  final RenderAdapter _inner;
  final Viewport _viewport;

  ViewportRenderAdapter(this._inner, this._viewport);

  Vector3 _toScreen(Vector3 world) => _viewport.worldToScreen(world);

  @override
  void drawLine(Vector3 start, Vector3 end) =>
      _inner.drawLine(_toScreen(start), _toScreen(end));

  @override
  void drawRect(Vector3 origin, double width, double height) {
    final s = _toScreen(origin);
    _inner.drawRect(s, width * _viewport.scale, height * _viewport.scale);
  }

  @override
  void drawCircle(Vector3 center, double radius) =>
      _inner.drawCircle(_toScreen(center), radius);
}