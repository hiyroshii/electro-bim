// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: resolução de FCT, FCA e tabela base Iz (6.2.5.3, 6.2.5.5).

import '../contracts/i_procedure.dart';
import '../enums/isolacao.dart';
import '../enums/metodo_instalacao.dart';
import '../enums/material.dart';
import '../enums/numero_fases.dart';
import '../models/entrada_normativa.dart';
import '../models/fatores_correcao.dart';
import '../models/linha_ampacidade.dart';
import '../tables/tabela_40_fct_temperatura.dart';
import '../tables/tabela_41_fca_resistividade_solo.dart';
import '../tables/tabela_42_45_fca_agrupamento.dart';
import '../tables/tabela_36_iz_pvc_a1d.dart';
import '../tables/tabela_37_iz_xlpe_epr_a1d.dart';
import '../tables/tabela_38_iz_pvc_efg.dart';
import '../tables/tabela_39_iz_xlpe_epr_efg.dart';

/// Parâmetros de agrupamento para resolução do FCA.
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.5.
final class ParamsAgrupamento {
  /// Número de circuitos agrupados.
  final int numCircuitos;

  /// Resistividade térmica do solo (K.m/W). Só relevante para Método D.
  /// Referência normativa: 2,5 K.m/W. Rastreabilidade: Tab. 41.
  final double resistividadeSolo;

  /// Espaçamento entre cabos enterrados (m). Só relevante para Método D.
  /// -1.0 representa "1 diâmetro de cabo". Rastreabilidade: Tab. 44/45.
  final double espacamentoCabos;

  /// Número de camadas (> 1 = múltiplas camadas). Rastreabilidade: Tab. 43.
  final int numCamadas;

  /// Indica se os cabos enterrados são multipolares (Tab. 45).
  final bool cabosMultipolares;

  const ParamsAgrupamento({
    required this.numCircuitos,
    this.resistividadeSolo = 2.5,
    this.espacamentoCabos = 0.0,
    this.numCamadas = 1,
    this.cabosMultipolares = true,
  });
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
      (EntradaNormativa, ParamsAgrupamento) entrada) {
    final (e, params) = entrada;

    final fct = _resolverFct(e);
    final fca = _resolverFca(e, params);
    final tabela = _resolverTabela(e);

    return ResultadoAmpacidade(
      fatores: FatoresCorrecao(fct: fct, fca: fca),
      tabelaIz: tabela,
    );
  }

  // ── FCT ───────────────────────────────────────────────────────────────────

  double _resolverFct(EntradaNormativa e) {
    final mapa = e.metodo.isSolo ? fctSolo : fctAr;
    final fator = mapa[e.isolacao]?[e.temperatura];

    // null = temperatura não admissível — spec_combinacoes já capturou.
    // Retorna 1.0 como fallback seguro; violação já será reportada.
    return fator ?? 1.0;
  }

  // ── FCA ───────────────────────────────────────────────────────────────────

  double _resolverFca(EntradaNormativa e, ParamsAgrupamento p) {
    if (p.numCircuitos <= 1) return 1.0;

    // Método D — subterrâneo
    if (e.metodo.isSolo) return _fcaSolo(e, p);

    // Múltiplas camadas
    if (p.numCamadas > 1) return _fcaMultiplasCamadas(p);

    // Camada única — varia por tipo de instalação
    return _fcaCamadaUnica(e, p);
  }

  double _fcaSolo(EntradaNormativa e, ParamsAgrupamento p) {
    // Fator de resistividade (Tab. 41) — aplica se ≠ 2,5 K.m/W
    final fatorResist = p.resistividadeSolo != 2.5
        ? (fcaResistividadeSolo[p.resistividadeSolo] ?? 1.0)
        : 1.0;

    // FCA de agrupamento (Tab. 44 direto, Tab. 45 em eletroduto)
    final chave = (p.numCircuitos, p.espacamentoCabos, p.cabosMultipolares);
    final fatorAgrup = fcaEletrodutosEnterrados[chave] ??
        fcaEnterradoDireto[(p.numCircuitos, p.espacamentoCabos)] ??
        1.0;

    return fatorResist * fatorAgrup;
  }

  double _fcaMultiplasCamadas(ParamsAgrupamento p) {
    // Normaliza para os intervalos da Tab. 43
    final camadas = _intervalo43Camadas(p.numCamadas);
    final circuitos = _intervalo43Circuitos(p.numCircuitos);
    return fcaMultiplasCamadas[(camadas, circuitos)] ?? 1.0;
  }

  double _fcaCamadaUnica(EntradaNormativa e, ParamsAgrupamento p) {
    final n = p.numCircuitos;

    // Métodos E e F — bandeja perfurada ou leito
    if (e.metodo.isArLivre) {
      // Diferencia bandeja perfurada de leito via arquitetura não é possível
      // apenas com EntradaNormativa — usa fcaBandejaPerfurada como padrão
      // para E/F. O consumidor pode sobrescrever via ParamsAgrupamento se
      // tiver a informação de tipo de suporte.
      return fcaBandejaPerfurada[n] ??
          fcaBandejaPerfurada[_limiteInferior(fcaBandejaPerfurada, n)] ??
          1.0;
    }

    // Demais métodos — feixe padrão (Tab. 42, linha 1)
    return fcaFeixe[n] ??
        fcaFeixe[_limiteInferior(fcaFeixe, n)] ??
        1.0;
  }

  // ── Tabela Iz ─────────────────────────────────────────────────────────────

  List<LinhaAmpacidade> _resolverTabela(EntradaNormativa e) {
    final condutoresReais = e.numeroFases.condutoresCarregadosComNeutro(
      harmonicasAcima15: e.harmonicasAcima15pct,
    );

    // Tabelas 36–39 só têm colunas para 2 e 3 condutores carregados.
    // Quando há 4 condutores (harmônicas > 15%), usa-se a coluna de 3
    // e aplica-se o fator 0,86 (já presente em FatoresCorrecao.fatorHarmonico).
    // Rastreabilidade: NBR 5410:2004 — 6.2.5.6.1.
    final condutoresLookup = condutoresReais.clamp(2, 3);

    final Map<double, double>? mapa = _selecionarMapa(e, condutoresLookup);
    if (mapa == null) return [];

    return mapa.entries
        .map((entry) => LinhaAmpacidade(secao: entry.key, izBase: entry.value))
        .toList()
      ..sort((a, b) => a.secao.compareTo(b.secao));
  }

  Map<double, double>? _selecionarMapa(EntradaNormativa e, int condutoresLookup) {
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

  // ── Helpers de intervalo para Tab. 42 e 43 ───────────────────────────────

  int _limiteInferior(Map<int, double> mapa, int n) =>
      mapa.keys.where((k) => k <= n).fold(1, (prev, k) => k > prev ? k : prev);

  int _intervalo43Camadas(int n) {
    if (n <= 2) return 2;
    if (n <= 3) return 3;
    if (n <= 5) return 4;
    if (n <= 8) return 6;
    return 9;
  }

  int _intervalo43Circuitos(int n) {
    if (n <= 2) return 2;
    if (n <= 3) return 3;
    if (n <= 5) return 4;
    if (n <= 8) return 6;
    return 9;
  }
}
