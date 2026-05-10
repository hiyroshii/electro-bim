// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: sub-orquestrador de classificação normativa (Fase 2).

import '../domain/instalacao/escopo_projeto.dart';
import '../domain/instalacao/perfil_instalacao.dart';
import '../classification/instalacao/class_perfil_padrao_por_escopo.dart';
import '../classification/influencias_externas/class_competencia_ba.dart';
import '../classification/influencias_externas/class_fuga_emergencia_bd.dart';

/// Sub-orquestrador de classificação normativa.
///
/// Monta o [PerfilInstalacao] a partir de dados de entrada brutos,
/// executando todas as [IClassification] relevantes e acumulando
/// os [CodigoInfluencia] resultantes.
///
/// Rastreabilidade: ARCHITECTURE.md — Seção 4.
final class ClassificationService {
  const ClassificationService();

  /// Resolve o [PerfilInstalacao] para o [escopo] indicado.
  ///
  /// Quando nenhuma influência é fornecida, retorna o perfil padrão do escopo.
  PerfilInstalacao resolverPerfil({
    required final EscopoProjeto escopo,
    final DadosCompetenciaBa? competencia,
    final DadosMaterialBd? material,
  }) {
    final influencias = <CodigoInfluencia>{};

    if (competencia != null) {
      final ba = const ClassCompetenciaBa().classificar(competencia);
      if (ba != null) influencias.add(ba);
    }

    if (material != null) {
      final bd = const ClassFugaEmergenciaBd().classificar(material);
      if (bd != null) influencias.add(bd);
    }

    if (influencias.isEmpty) {
      return const ClassPerfilPadraoPorEscopo().resolver(escopo);
    }

    return PerfilInstalacao(escopo: escopo, influencias: influencias);
  }
}
