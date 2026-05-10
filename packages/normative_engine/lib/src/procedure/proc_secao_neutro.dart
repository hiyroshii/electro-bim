// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: cálculo da seção mínima do condutor neutro conforme 6.2.6.2.

import '../contracts/i_procedure.dart';
import '../enums/numero_fases.dart';
import '../tables/tabela_47_48_secao_minima_neutro.dart';

/// Calcula a seção mínima do condutor neutro para um condutor de fase dado.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.6.2.
final class ProcSecaoNeutro implements IProcedure<(double, NumeroFases, bool), double> {
  const ProcSecaoNeutro();

  /// Retorna a seção mínima do neutro (mm²).
  ///
  /// [entrada] = (secaoFase mm², numeroFases, harmonicasAcima15pct)
  @override
  double resolver(final (double, NumeroFases, bool) entrada) {
    final (secaoFase, numeroFases, harmonicasAcima15pct) = entrada;

    // Monofásico: neutro obrigatoriamente igual à fase.
    // Rastreabilidade: NBR 5410:2004 — 6.2.6.2.2.
    if (numeroFases == NumeroFases.monofasico) return secaoFase;

    // Bifásico/trifásico com harmônicas > 15%: neutro >= fase.
    // Rastreabilidade: NBR 5410:2004 — 6.2.6.2.3 e 6.2.6.2.4.
    if (harmonicasAcima15pct) return secaoFase;

    // Trifásico com harmônicas ≤ 15% e fase > 25 mm²:
    // redução permitida conforme Tabela 48.
    // Rastreabilidade: NBR 5410:2004 — 6.2.6.2.6.
    if (secaoFase > 25.0) return tabelaNeutroReduzido[secaoFase] ?? secaoFase;

    // Fase ≤ 25 mm² com harmônicas ≤ 15%: neutro = fase.
    // Rastreabilidade: NBR 5410:2004 — 6.2.6.2.6.
    return secaoFase;
  }
}
