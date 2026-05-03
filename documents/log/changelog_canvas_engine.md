# CHANGELOG — canvas_engine

Registro de alterações do package `canvas_engine`.
Formato: semver. Categorias: ADD, CHG, FIX, DEL.
Data: DD MM AAAA (sem barras).

---

## [1.3.0] — 29 04 2026 — Geometria Base

### ADD
- `domain/geometry/tolerance.dart` v1.0.0
  — Tolerance com constantes nomeadas: geometric, parallel, hitTestPixels, hitTestWorld(scale)
- `domain/geometry/primitives/segment.dart` v1.0.0
  — Segment imutável; == não-direcional; isDegenerate; direction, length, midpoint, reversed
- `domain/geometry/primitives/aabb.dart` v1.0.0
  — AABB com fromPoints, fromSegment, contains, intersects, expand, union, width, height, center
- `domain/geometry/operations/distance.dart` v1.0.0
  — distancePointToPoint, distancePointToSegment, closestPointOnSegment, isPointOnSegment
- `domain/geometry/operations/intersection.dart` v1.0.0
  — intersectSegments com fórmula de Gavin; IntersectionResult tipado; IntersectionType enum
  — trata paralelo, colinear, none, intersect com Tolerance.parallel (não comparação exata)
- `domain/geometry/operations/projection.dart` v1.0.0
  — projectPointOntoSegment (clampado), projectPointOntoLine (infinita)
  — ProjectionResult com ponto, t e isWithinSegment
- `test/domain/geometry/geometry_test.dart`
  — 30 testes cobrindo todos os módulos do [1.3.0]

### CHG
- `domain/value_objects/vector2.dart` → v1.1.0
  — ADD: ==, hashCode, equalsApprox, cross, normalize, distanceTo, lengthSquared
  — ADD: zero como const estático (em vez de factory zero())
- `domain/entities/shape.dart` → v1.1.0
  — CHG: hitTest recebe tolerance opcional (padrão Tolerance.geometric)
- `domain/entities/line_shape.dart` → v1.1.0
  — ADD: getter segment (Segment interno — Opção B, API pública não muda)
  — ADD: getter bounds (AABB)
  — CHG: hitTest implementado via distancePointToSegment (antes retornava false)
- `canvas_engine.dart` barrel → v1.2.0
  — ADD: exports de tolerance, segment, aabb, distance, intersection, projection

---

## [1.2.0] — 29 04 2026 — Navegação e Interface de Ferramentas

### ADD
- `models/canvas_mode.dart` v1.0.0
  — CanvasMode enum: draw, navigate
- `controllers/tools/tool.dart` v1.0.0
  — Interface Tool: onTap, onMove, reset, drawPreview

### CHG
- `controllers/tools/draw_line_controller.dart` → v1.1.0
  — implements Tool; ADD reset(), drawPreview()
- `controllers/input_controller.dart` → v2.0.0
  — tool tipado como Tool; ADD mode (CanvasMode); ADD onZoom(); ADD setTool()
  — onPanUpdate: modo navigate chama viewport.pan; modo draw alimenta tool
- `canvas_engine.dart` barrel → v1.1.0
  — ADD: exports canvas_mode, tool

---

## [1.1.0] — 29 04 2026 — Sprint 1: Motor Funcional

### ADD
- `domain/value_objects/vector2.dart` v1.0.0
- `domain/entities/shape.dart` v1.0.0
- `domain/entities/line_shape.dart` v1.0.0
- `engine/canvas_engine.dart` v1.0.0
- `engine/scene.dart` v1.0.0
- `viewport/viewport.dart` v1.0.0
- `render/render_adapter.dart` v1.0.0
- `render/viewport_render_adapter.dart` v1.0.0
- `controllers/input_controller.dart` v1.0.0
- `controllers/tools/draw_line_controller.dart` v1.0.0
- `models/cursor_state.dart` v1.0.0
- `services/snap/snap_service.dart` v1.0.0 (stub)
- `services/snap/snap_result.dart` v1.0.0
- `services/snap/snap_type.dart` v1.0.0
- `canvas_engine.dart` barrel v1.0.0
