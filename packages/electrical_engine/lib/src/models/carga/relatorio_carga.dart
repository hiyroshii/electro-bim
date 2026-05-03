// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: construtores movidos antes dos campos em PrevisaoCargaComodo e RelatorioCarga.
// [1.0.0] - 2026-04
// - ADD: scaffold de RelatorioCarga.

import 'comodo.dart';
import 'entrada_carga.dart';

/// Previsão de carga por cômodo — resultado da validação normativa.
final class PrevisaoCargaComodo {
  const PrevisaoCargaComodo({
    required this.comodo,
    required this.tugTotal,
    required this.ilTotal,
    required this.vaTotalComodo,
    required this.status,
  });

  final Comodo comodo;
  final int tugTotal;
  final int ilTotal;
  final double vaTotalComodo;
  final StatusPrevisao status;
}

/// Status da previsão normativa do cômodo.
enum StatusPrevisao {
  aprovado,
  reprovadoNorma,
}

/// Status global do relatório de carga.
enum StatusRelatorio {
  ok,
  reprovado,
}

/// Resultado completo do dimensionamento de cargas do projeto.
final class RelatorioCarga {
  const RelatorioCarga({
    required this.previsoesPorComodo,
    required this.circuitos,
    required this.vaTotalProjeto,
    required this.status,
  });

  final List<PrevisaoCargaComodo> previsoesPorComodo;
  final List<CircuitoAgregado> circuitos;
  final double vaTotalProjeto;
  final StatusRelatorio status;
}
