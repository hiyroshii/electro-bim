// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: contrato abstrato IProcedure.

/// Contrato de um serviço de procedimento normativo.
///
/// Cada implementação resolve um conjunto de dados normativos
/// (tabelas, fatores, limites) para um contexto de entrada [I]
/// e retorna o resultado tipado [O].
///
/// Não lança exceção — a entrada já foi validada pelo
/// [SpecificationService] antes de chegar aqui.
///
/// Implementações:
/// - [ProcAmpacidade]   → [FatoresCorrecao] + [List<LinhaAmpacidade>]
/// - [ProcQuedaTensao]  → [ParametrosQueda]
abstract interface class IProcedure<I, O> {
  /// Resolve os dados normativos para [entrada].
  O resolver(I entrada);
}
