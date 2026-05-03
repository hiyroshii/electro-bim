// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - INIT: criação do sub-barrel público do Snap module
// - ADD: SnapService, SnapCandidate, SnapResult, SnapType expostos como API pública
// - CHG: providers tornam-se internos (não exportados)
//
// REGRA:
// - Tudo aqui é API pública do Snap System
// - Providers NÃO são expostos aqui

library snap;

export 'snap_service.dart';
export 'snap_candidate.dart';
export 'snap_result.dart';
export 'snap_type.dart';