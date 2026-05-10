// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: contrato IClassification — Fase 2.

import '../domain/influencias/codigo_influencia.dart';

/// Contrato de uma classificação normativa de influência externa.
///
/// Cada implementação classifica uma família de influências externas
/// (BA, BD, BC...) a partir de dados de entrada e retorna o código
/// de influência determinado.
///
/// O [ClassificationService] agrega os resultados de todas as implementações
/// para montar o [PerfilInstalacao] completo de uma instalação.
///
/// Implementações (Fase 2):
/// - [ClassCompetenciaBa]      — família BA (competência das pessoas)
/// - [ClassFugaEmergenciaBd]   — família BD (materiais processados)
///
/// Rastreabilidade: ARCHITECTURE.md — Seção 2.
abstract interface class IClassification<I> {
  /// Classifica a entrada [dados] e retorna o código de influência resultante.
  ///
  /// Retorna `null` se a classificação não for determinável a partir da entrada.
  CodigoInfluencia? classificar(final I dados);
}
