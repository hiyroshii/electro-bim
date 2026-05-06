// REV: 1.10.1
// CHANGELOG:
// - REF: exports unificados através dos novos sub-barrels entities e geometry
library canvas_engine;

// DOMAIN — value objects
export 'domain/value_objects/vector3.dart';

// DOMAIN — entities (barrel)
export 'domain/entities/entities.dart';

// DOMAIN — document
export 'domain/documents/cad_document.dart';

// DOMAIN — geometry (barrel)
export 'domain/geometry/geometry.dart';

// ENGINE
export 'engine/canvas_engine.dart';
export 'engine/scene.dart';

// VIEWPORT
export 'viewport/viewport.dart';

// RENDER (barrel)
export 'render/render.dart';

// SERVICES — SNAP (API PÚBLICA)
export 'services/snap/snap.dart';

// COMMANDS
export 'commands/commands.dart';

// CONTROLLERS (barrel)
export 'controllers/controllers.dart';

// MODELS (barrel)
export 'models/models.dart';