// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: T-14 — carga mínima por TUG por tipo de cômodo.

import '../../domain/locais/tipo_comodo.dart';

/// T-14 — Carga mínima por TUG (VA).
///
/// Rastreabilidade: NBR 5410:2004 — Seção 9.5.
/// Ambientes com água (banheiro, cozinha, serviço) e áreas externas
/// (garagem, varanda): 600 VA por tomada — risco de demanda elevada e umidade.
/// Demais cômodos: 100 VA.
const Map<TipoComodo, double> tabelaCargaTugPorPonto = {
  TipoComodo.sala: 100.0,
  TipoComodo.quarto: 100.0,
  TipoComodo.cozinha: 600.0,
  TipoComodo.banheiro: 600.0,
  TipoComodo.areaServico: 600.0,
  TipoComodo.corredor: 100.0,
  TipoComodo.garagem: 600.0,
  TipoComodo.varanda: 600.0,
};

/// Retorna a carga mínima (VA) por tomada de uso geral para o [comodo].
double cargaTugPorPonto(final TipoComodo comodo) =>
    tabelaCargaTugPorPonto[comodo]!;
