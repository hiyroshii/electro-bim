// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: resolução de FCT, FCA e tabela base Iz (6.2.5.3, 6.2.5.5).

import '../../contracts/i_procedure.dart';
import '../../enums/material.dart';
import '../../models/entrada_normativa.dart';
import '../../models/fatores_correcao.dart';
import '../../models/linha_ampacidade.dart';
import '../../tables/tabela_40_fct_temperatura.dart';
import '../../tables/tabela_41_fca_resistividade_solo.dart';
import '../../tables/tabela_42_45_fca_agrupamento.dart';
import '../../tables/tabela_36_iz_pvc_a1d.dart';
import '../../tables/tabela_37_iz_xlpe_epr_a1d.dart';
import '../../tables/tabela_38_iz_pvc_efg.dart';
import '../../tables/tabela_39_iz_xlpe_epr_efg.dart';

/// Parâmetros de agrupamento para resolução do FCA.
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.5.
final class ParamsAgrupamento {

  const ParamsAgrupamento({
    required this.numCircuitos,
    this.resistividadeSolo = 2.5,
    this.espacamentoCabos = 0.0,
    this.numCamadas = 1,
    this.cabosMultipolares = true,
  });
  final int numCircuitos;
  final double resistividadeSolo;
  final double espacamentoCabos;
  final int numCamadas;
  final bool cabosMultipolares;
}

/// Resultado intermediário do [ProcAmpacidade].
final class ResultadoAmpacidade {
  const ResultadoAmpacidade({
    required this.fatores,
    required this.tabelaIz,
  });

  final FatoresCorrecao fatores;
  final List<LinhaAmpacidade> tabelaIz;
}

/// Resolve FCT, FCA e tabela base Iz para o contexto da entrada.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.2, 6.2.5.3, 6.2.5.5.
final class ProcAmpacidade
    implements IProcedure<(EntradaNormativa, ParamsAgrupamento), ResultadoAmpacidade> {
  const ProcAmpacidade();

  @override
  ResultadoAmpacidade resolver(
      final (EntradaNormativa, ParamsAgrupamento) entrada,) {
    final (e, params) = entrada;

    final fct = _resolverFct(e);
    final fca = _resolverFca(e, params);
    final tabela = _resolverTabela(e);

    return ResultadoAmpacidade(
      fatores: FatoresCorrecao(fct: fct, fca: fca),
      tabelaIz: tabela,
    );
  }

  double _resolverFct(final EntradaNormativa e) {
    final mapa = e.metodo.isSolo ? fctSolo : fctAr;
    final fator = mapa[e.isolacao]?[e.temperatura];
    return fator ?? 1.0;
  }

  double _resolverFca(final EntradaNormativa e, final ParamsAgrupamento p) {
    if (p.numCircuitos <= 1) return 1.0;
    if (e.metodo.isSolo) return _fcaSolo(e, p);
    if (p.numCamadas > 1) return _fcaMultiplasCamadas(p);
    return _fcaCamadaUnica(e, p);
  }

  double _fcaSolo(final EntradaNormativa e, final ParamsAgrupamento p) {
    final fatorResist = p.resistividadeSolo != 2.5
        ? (fcaResistividadeSolo[p.resistividadeSolo] ?? 1.0)
        : 1.0;

    final chave = (p.numCircuitos, p.espacamentoCabos, p.cabosMultipolares);
    final fatorAgrup = fcaEletrodutosEnterrados[chave] ??
        fcaEnterradoDireto[(p.numCircuitos, p.espacamentoCabos)] ??
        1.0;

    return fatorResist * fatorAgrup;
  }

  double _fcaMultiplasCamadas(final ParamsAgrupamento p) {
    final camadas = _intervalo43Camadas(p.numCamadas);
    final circuitos = _intervalo43Circuitos(p.numCircuitos);
    return fcaMultiplasCamadas[(camadas, circuitos)] ?? 1.0;
  }

  double _fcaCamadaUnica(final EntradaNormativa e, final ParamsAgrupamento p) {
    final n = p.numCircuitos;
    if (e.metodo.isArLivre) {
      return fcaBandejaPerfurada[n] ??
          fcaBandejaPerfurada[_limiteInferior(fcaBandejaPerfurada, n)] ??
          1.0;
    }
    return fcaFeixe[n] ??
        fcaFeixe[_limiteInferior(fcaFeixe, n)] ??
        1.0;
  }

  List<LinhaAmpacidade> _resolverTabela(final EntradaNormativa e) {
    final condutoresReais = e.numeroFases.condutoresCarregadosComNeutro(
      harmonicasAcima15: e.harmonicasAcima15pct,
    );
    final condutoresLookup = condutoresReais.clamp(2, 3);
    final Map<double, double>? mapa = _selecionarMapa(e, condutoresLookup);
    if (mapa == null) return [];

    return mapa.entries
        .map((final entry) => LinhaAmpacidade(secao: entry.key, izBase: entry.value))
        .toList()
      ..sort((final a, final b) => a.secao.compareTo(b.secao));
  }

  Map<double, double>? _selecionarMapa(final EntradaNormativa e, final int condutoresLookup) {
    final isPvc = e.isolacao.isPvc;
    final isCobre = e.material == Material.cobre;
    final isEfg = e.metodo.usaTabelaEfg;

    if (isEfg) {
      if (isPvc) {
        return isCobre
            ? tabelaIzCobrePvcEFG[(e.metodo, condutoresLookup, e.arranjo)]
            : tabelaIzAluminioPvcEFG[(e.metodo, condutoresLookup, e.arranjo)];
      } else {
        return isCobre
            ? tabelaIzCobreXlpeEprEFG[(e.metodo, condutoresLookup, e.arranjo)]
            : tabelaIzAluminioXlpeEprEFG[(e.metodo, condutoresLookup, e.arranjo)];
      }
    } else {
      if (isPvc) {
        return isCobre
            ? tabelaIzCobrePvcA1D[(e.metodo, condutoresLookup)]
            : tabelaIzAluminioPvcA1D[(e.metodo, condutoresLookup)];
      } else {
        return isCobre
            ? tabelaIzCobreXlpeEprA1D[(e.metodo, condutoresLookup)]
            : tabelaIzAluminioXlpeEprA1D[(e.metodo, condutoresLookup)];
      }
    }
  }

  int _limiteInferior(final Map<int, double> mapa, final int n) =>
      mapa.keys.where((final k) => k <= n).fold(1, (final prev, final k) => k > prev ? k : prev);

  int _intervalo43Camadas(final int n) {
    if (n <= 2) return 2;
    if (n <= 3) return 3;
    if (n <= 5) return 4;
    if (n <= 8) return 6;
    return 9;
  }

  int _intervalo43Circuitos(final int n) {
    if (n <= 2) return 2;
    if (n <= 3) return 3;
    if (n <= 5) return 4;
    if (n <= 8) return 6;
    return 9;
  }
}
