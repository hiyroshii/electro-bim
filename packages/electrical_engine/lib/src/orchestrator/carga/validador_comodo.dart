// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - ADD: implementação completa de validar().
// [1.0.0] - 2026-04
// - ADD: scaffold de ValidadorComodo.

import '../../models/carga/comodo.dart';
import '../../models/carga/relatorio_carga.dart';

/// Limites normativos por regra de tomada.
/// Rastreabilidade: NBR 5410:2004 — 9.1.2.2.
const double _tugMinPorPerimetro = 5.0; // 1 TUG a cada 5m
const int _tugMinimoFixo = 2;
const int _ilMinimo = 1;

/// Valida se um cômodo atende os mínimos normativos de TUG e IL.
///
/// Rastreabilidade: NBR 5410:2004 — 9.1.2 e 9.1.3.
final class ValidadorComodo {
  const ValidadorComodo();

  /// Valida o cômodo e retorna a previsão de carga com status.
  PrevisaoCargaComodo validar(Comodo comodo) {
    final tugTotal = comodo.pontosTug.length;
    final ilTotal = comodo.pontosIl.length;
    final vaTotalComodo = _calcularVaTotal(comodo);

    final aprovado = _validarTugs(comodo, tugTotal) &&
        _validarIls(ilTotal);

    return PrevisaoCargaComodo(
      comodo: comodo,
      tugTotal: tugTotal,
      ilTotal: ilTotal,
      vaTotalComodo: vaTotalComodo,
      status: aprovado ? StatusPrevisao.aprovado : StatusPrevisao.reprovadoNorma,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool _validarTugs(Comodo comodo, int tugTotal) {
    return switch (comodo.regraTomadasComodo) {
      RegraTomadasComodo.porPerimetro =>
        tugTotal >= (comodo.perimetroM / _tugMinPorPerimetro).ceil(),
      RegraTomadasComodo.minimoFixo =>
        tugTotal >= _tugMinimoFixo,
      RegraTomadasComodo.custom => true, // usuário define, sem validação mínima
    };
  }

  bool _validarIls(int ilTotal) => ilTotal >= _ilMinimo;

  double _calcularVaTotal(Comodo comodo) {
    final vaTug = comodo.pontosTug.fold(0.0, (s, p) => s + p.potenciaVA);
    final vaIl  = comodo.pontosIl.fold(0.0, (s, p) => s + p.potenciaVA);
    return vaTug + vaIl;
  }
}
