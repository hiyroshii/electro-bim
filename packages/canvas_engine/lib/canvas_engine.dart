// REV: 1.9.0
// CHANGELOG:
// [1.9.0] - 04 05 2026
// - ADD: export de layer.dart e cad_document.dart (Ciclo 3)
//
// ... (histórico mantido)

library canvas_engine;

// DOMAIN — value objects
export 'domain/value_objects/vector3.dart';

// DOMAIN — entities
export 'domain/entities/shape.dart';
export 'domain/entities/line_shape.dart';
export 'domain/entities/pline_shape.dart';
export 'domain/entities/layer.dart';           // NOVO

// DOMAIN — document
export 'domain/documents/cad_document.dart';    // NOVO

// DOMAIN — geometry
export 'domain/geometry/tolerance.dart';
export 'domain/geometry/primitives/segment.dart';
export 'domain/geometry/primitives/aabb.dart';
export 'domain/geometry/operations/distance.dart';
export 'domain/geometry/operations/intersection.dart';
export 'domain/geometry/operations/projection.dart';

// ENGINE
export 'engine/canvas_engine.dart';
export 'engine/scene.dart';

// VIEWPORT
export 'viewport/viewport.dart';

// RENDER
export 'render/render_adapter.dart';
export 'render/viewport_render_adapter.dart';
export 'render/grid_renderer.dart';

// SERVICES — SNAP (API PÚBLICA)
export 'services/snap/snap.dart';

// COMMANDS
export 'commands/commands.dart';

// CONTROLLERS (barrel único)
export 'controllers/controllers.dart';

// MODELS
export 'models/canvas_mode.dart';
export 'models/cursor_state.dart';