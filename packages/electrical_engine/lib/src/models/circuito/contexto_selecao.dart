// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-05
// - FIX: construtor movido antes dos campos.
// [1.0.1] - 2026-04
// - ADD: reatanciaXi e fatorHarmonico.
// [1.0.0] - 2026-04
// - ADD: scaffold de ContextoSelecao.

import 'package:normative_engine/normative_engine.dart';

/// Agrega todos os parâmetros necessários para o [SelecionadorCondutor].
///
/// Construído pelo [DimensionamentoCircuitoService] após obter:
/// - Ib via [CalcCorrenteProjeto]
/// - In via [PoliticaDisjuntor]
/// - DadosNormativos via [NormativeEngine.resolverDadosNormativos]
final class ContextoSelecao {
  const ContextoSelecao({
    required this.material,
    required this.isolacao,
    required this.arquitetura,
    required this.metodoInstalacao,
    required this.numeroFases,
    required this.condutoresAtivos,
    required this.ib,
    required this.inDisjuntor,
    required this.secaoMinima,
    required this.limiteQueda,
    required this.fatores,
    required this.tabelaIz,
    required this.tensao,
    required this.distancia,
    required this.fatorPotencia,
    this.reatanciaXi = 0.0,
    this.fatorHarmonico = 1.0,
    this.arranjo,
  });

  final Material material;
  final Isolacao isolacao;
  final Arquitetura arquitetura;
  final MetodoInstalacao metodoInstalacao;
  final ArranjoCondutores? arranjo;
  final NumeroFases numeroFases;
  final int condutoresAtivos;
  final double ib;
  final double inDisjuntor;
  final double secaoMinima;
  final double limiteQueda;
  final FatoresCorrecao fatores;
  final List<LinhaAmpacidade> tabelaIz;
  final double tensao;
  final double distancia;
  final double fatorPotencia;

  /// Reatância do condutor (Ω/m). Zero quando não disponível.
  final double reatanciaXi;

  /// Fator 0,86 quando 4 condutores carregados (harm > 15%), 1,0 caso contrário.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.6.1.
  final double fatorHarmonico;

  /// Resistividade do condutor (Ω.mm²/m) derivada do material × isolação.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 50.
  double get resistividade {
    final isPvc = isolacao.isPvc;
    return switch (material) {
      Material.cobre    => isPvc ? 0.02308 : 0.02538,
      Material.aluminio => isPvc ? 0.03775 : 0.04150,
    };
  }
}
