// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-05
// - FIX: construtor de Disjuntor movido antes do campo.
// [1.0.1] - 2026-04
// - ADD: implementação completa de selecionar().
// [1.0.0] - 2026-04
// - ADD: scaffold de PoliticaDisjuntor.

/// Disjuntor comercial disponível no catálogo.
final class Disjuntor {
  const Disjuntor(this.in_);

  final double in_;
}

/// Seleciona o menor In >= Ib no catálogo.
/// Rastreabilidade: NBR 5410:2004 — 6.3.3.
final class PoliticaDisjuntor {
  const PoliticaDisjuntor();

  double selecionar({
    required double ib,
    required List<Disjuntor> catalogo,
  }) {
    assert(catalogo.isNotEmpty, 'catálogo não pode ser vazio');
    final disjuntor = catalogo.firstWhere(
      (d) => d.in_ >= ib,
      orElse: () => throw StateError(
        'Ib=${ib.toStringAsFixed(2)}A excede o maior disjuntor do catálogo '
        '(${catalogo.last.in_}A). Subdivida o circuito ou revise a carga.',
      ),
    );
    return disjuntor.in_;
  }
}
