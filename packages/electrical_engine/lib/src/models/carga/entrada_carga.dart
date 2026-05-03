// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: construtores movidos antes dos campos em EntradaCarga e CircuitoAgregado.
// [1.0.0] - 2026-04
// - ADD: scaffold de EntradaCarga e CircuitoAgregado.

import 'package:normative_engine/normative_engine.dart';

import 'comodo.dart';

/// Entrada para o dimensionamento de cargas do projeto.
final class EntradaCarga {
  const EntradaCarga({required this.comodos});

  final List<Comodo> comodos;
}

/// Circuito resultante da agregação de pontos de utilização.
final class CircuitoAgregado {
  const CircuitoAgregado({
    required this.idCircuito,
    required this.tag,
    required this.potenciaVA,
    required this.status,
  });

  final String idCircuito;
  final TagCircuito tag;
  final double potenciaVA;
  final StatusCircuito status;
}

/// Status da agregação de circuitos.
enum StatusCircuito {
  aprovado,
  reprovado,
}
