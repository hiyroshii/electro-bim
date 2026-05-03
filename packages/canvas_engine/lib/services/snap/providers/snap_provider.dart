// REV: 3.0.0
// CHANGELOG:
// [3.0.0] - 02 05 2026
// - CHG: compute() removido — substituído por computeCandidates()
//        retorna múltiplos SnapCandidate (Ciclo 1 — Snap robusto)
// - ADD: nova assinatura com retorno List<SnapCandidate>
//
// [2.0.0] - 02 05 2026
// - CHG: provider gera múltiplos candidatos internos (preparação)
// - ADD: score interno
//
// [1.0.0] - 02 05 2026
// - ADD: SnapProvider original com compute()

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/services/snap/snap_candidate.dart';

abstract class SnapProvider {
  /// Retorna todos os pontos de snap que este provedor consegue
  /// extrair da [shape] em relação ao [point] do cursor.
  List<SnapCandidate> computeCandidates({
    required Vector3 point,
    required Shape shape,
    required double zoom,
  });
}