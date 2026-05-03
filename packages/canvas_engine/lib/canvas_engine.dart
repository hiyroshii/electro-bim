// REV: 1.8.0
// CHANGELOG:
// [1.8.0] - 02 05 2026
// - ADD: export de commands (barrel)
// - ADD: export de PlineShape
// - CHG: controllers agora via barrel controllers.dart
// - CHG: tool.dart renomeado para drawing_tools_contract.dart (via barrel)
// - ADD: UndoManager no barrel de controllers
//
// [1.7.0] - 02 05 2026
// - CHG: Snap providers removidos da API pública
// - ADD: Snap sub-barrel (services/snap/snap.dart) como entrada única
//
// [1.6.0] - 02 05 2026
// - ADD: export snap_candidate.dart, intersection_snap_provider.dart
//
// [1.5.0] - 02 05 2026
// - CHG: export vector3.dart

library canvas_engine;

// DOMAIN — value objects
export 'domain/value_objects/vector3.dart';

// DOMAIN — entities
export 'domain/entities/shape.dart';
export 'domain/entities/line_shape.dart';
export 'domain/entities/pline_shape.dart';

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