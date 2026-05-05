// REV: 1.2.0
// CHANGELOG:
// - ADD: repasse da propriedade drawColor para o adapter interno
// - FIX: propriedade drawColor reflete no renderizador final

import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/viewport/viewport.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'dart:ui' show Color;

class ViewportRenderAdapter implements RenderAdapter {
  final RenderAdapter _inner;
  final Viewport _viewport;

  ViewportRenderAdapter(this._inner, this._viewport);

  Vector3 _toScreen(Vector3 world) => _viewport.worldToScreen(world);

  @override
  Color get drawColor => _inner.drawColor;
  @override
  set drawColor(Color value) => _inner.drawColor = value;

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
      _inner.drawCircle(_toScreen(center), radius * _viewport.scale);
}