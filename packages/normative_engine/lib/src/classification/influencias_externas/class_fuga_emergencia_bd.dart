// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: ClassFugaEmergenciaBd — classificação BD (Fase 2).

import '../../contracts/i_classification.dart';
import '../../domain/influencias/codigo_influencia.dart';

/// Dados de entrada para classificação dos materiais processados (BD).
typedef DadosMaterialBd = ({
  bool semRiscoIncendio,        // BD1 — materiais não inflamáveis
  bool riscoIncendio,           // BD2 — materiais combustíveis
  bool riscoExplosaoPo,         // BD3 — pó combustível
  bool riscoExplosaoGasVapor,   // BD4 — gases/vapores inflamáveis
});

/// Classifica os materiais processados ou armazenados na instalação — família BD.
///
/// Determina o risco de incêndio ou explosão do local a partir das
/// características dos materiais presentes.
///
/// Rastreabilidade: NBR 5410:2004 — Tab. 18 (4.2.6 — família BD).
final class ClassFugaEmergenciaBd
    implements IClassification<DadosMaterialBd> {
  const ClassFugaEmergenciaBd();

  @override
  CodigoInfluencia? classificar(final DadosMaterialBd dados) {
    // Prioridade: risco mais severo primeiro
    if (dados.riscoExplosaoGasVapor) return CodigoInfluencia.bd4;
    if (dados.riscoExplosaoPo) return CodigoInfluencia.bd3;
    if (dados.riscoIncendio) return CodigoInfluencia.bd2;
    if (dados.semRiscoIncendio) return CodigoInfluencia.bd1;
    return null;
  }
}
