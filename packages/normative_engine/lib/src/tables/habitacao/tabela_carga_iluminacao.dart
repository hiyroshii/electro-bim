// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: T-13 — carga mínima por ponto de iluminação por tipo de cômodo.

import '../../domain/locais/tipo_comodo.dart';

/// T-13 — Carga mínima por ponto de iluminação (VA).
///
/// Rastreabilidade: NBR 5410:2004 — Seção 9.5.
/// Piso: 100 VA por ponto para todos os cômodos residenciais.
const Map<TipoComodo, double> tabelaCargaIlPorPonto = {
  TipoComodo.sala: 100.0,
  TipoComodo.quarto: 100.0,
  TipoComodo.cozinha: 100.0,
  TipoComodo.banheiro: 100.0,
  TipoComodo.areaServico: 100.0,
  TipoComodo.corredor: 100.0,
  TipoComodo.garagem: 100.0,
  TipoComodo.varanda: 100.0,
};

/// Retorna a carga mínima (VA) por ponto de iluminação para o [comodo].
double cargaIlPorPonto(final TipoComodo comodo) =>
    tabelaCargaIlPorPonto[comodo]!;
