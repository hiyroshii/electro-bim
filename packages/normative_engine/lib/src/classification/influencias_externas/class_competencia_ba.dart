// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: ClassCompetenciaBa — classificação BA (Fase 2).

import '../../contracts/i_classification.dart';
import '../../domain/influencias/codigo_influencia.dart';

/// Dados de entrada para classificação da competência das pessoas (BA).
typedef DadosCompetenciaBa = ({
  bool pessoalHabilitado,     // eletricistas qualificados (BA4/BA5)
  bool pessoalEspecializado,  // engenheiros/técnicos (BA5)
});

/// Classifica a competência das pessoas presentes na instalação — família BA.
///
/// Determina o código BA conforme o nível de qualificação do pessoal
/// que terá acesso à instalação.
///
/// Rastreabilidade: NBR 5410:2004 — Tab. 15 (4.2.6 — família BA).
final class ClassCompetenciaBa
    implements IClassification<DadosCompetenciaBa> {
  const ClassCompetenciaBa();

  @override
  CodigoInfluencia? classificar(final DadosCompetenciaBa dados) {
    if (dados.pessoalEspecializado) return CodigoInfluencia.ba5;
    if (dados.pessoalHabilitado) return CodigoInfluencia.ba4;
    return null; // BA1/BA2/BA3 — leigos/instruídos, sem código especial relevante
  }
}
