// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: construtores movidos antes dos campos em PontoUtilizacao e Comodo.
// [1.0.0] - 2026-04
// - ADD: scaffold de Comodo.

import 'package:normative_engine/normative_engine.dart';

/// Ponto de utilização dentro de um cômodo.
final class PontoUtilizacao {
  const PontoUtilizacao({
    required this.idCircuito,
    required this.tag,
    required this.potenciaVA,
  });

  final String idCircuito;
  final TagCircuito tag;
  final double potenciaVA;
}

/// Ambiente da instalação com pontos de utilização agrupados por circuito.
final class Comodo {
  const Comodo({
    required this.id,
    required this.idTipo,
    required this.label,
    required this.regraTomadasComodo,
    required this.areaM2,
    required this.perimetroM,
    this.pontosTug = const [],
    this.pontosIl = const [],
  });

  factory Comodo.criar({
    required String id,
    required String idTipo,
    required String label,
    required RegraTomadasComodo regraTomadasComodo,
    required double areaM2,
    required double perimetroM,
  }) =>
      Comodo(
        id: id,
        idTipo: idTipo,
        label: label,
        regraTomadasComodo: regraTomadasComodo,
        areaM2: areaM2,
        perimetroM: perimetroM,
      );

  final String id;
  final String idTipo;
  final String label;
  final RegraTomadasComodo regraTomadasComodo;
  final double areaM2;
  final double perimetroM;
  final List<PontoUtilizacao> pontosTug;
  final List<PontoUtilizacao> pontosIl;

  Comodo copyWith({
    List<PontoUtilizacao>? pontosTug,
    List<PontoUtilizacao>? pontosIl,
  }) =>
      Comodo(
        id: id,
        idTipo: idTipo,
        label: label,
        regraTomadasComodo: regraTomadasComodo,
        areaM2: areaM2,
        perimetroM: perimetroM,
        pontosTug: pontosTug ?? this.pontosTug,
        pontosIl: pontosIl ?? this.pontosIl,
      );
}

/// Regra normativa de tomadas aplicável ao cômodo.
/// Rastreabilidade: NBR 5410:2004 — Seção 9.
enum RegraTomadasComodo {
  porPerimetro,
  minimoFixo,
  custom,
}
