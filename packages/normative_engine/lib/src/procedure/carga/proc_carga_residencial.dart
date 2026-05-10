// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: P-6 — carga mínima de circuito residencial por cômodo e tipo de circuito.

import '../../contracts/i_procedure.dart';
import '../../domain/instalacao/tag_circuito.dart';
import '../../domain/locais/tipo_comodo.dart';
import '../../tables/habitacao/tabela_carga_iluminacao.dart';
import '../../tables/habitacao/tabela_potencia_tug.dart';

/// Parâmetros de entrada para [ProcCargaResidencial].
typedef EntradaCargaResidencial = ({
  TipoComodo comodo,
  TagCircuito tag,
  int quantidade, // pontos de iluminação ou tomadas
});

/// P-6 — Carga mínima normativa de um circuito residencial (VA).
///
/// Consulta T-13 para circuitos IL e T-14 para circuitos TUG.
/// TUE retorna 0 — a potência é a da carga específica, declarada pelo projetista.
/// Circuitos de alimentação (MED, QDG, QD) retornam 0 — sem piso normativo por ponto.
///
/// Rastreabilidade: NBR 5410:2004 — Seção 9.5.
final class ProcCargaResidencial
    implements IProcedure<EntradaCargaResidencial, double> {
  const ProcCargaResidencial();

  @override
  double resolver(final EntradaCargaResidencial entrada) => switch (entrada.tag) {
    TagCircuito.il =>
        cargaIlPorPonto(entrada.comodo) * entrada.quantidade,
    TagCircuito.tug =>
        cargaTugPorPonto(entrada.comodo) * entrada.quantidade,
    _ => 0.0,
  };
}
