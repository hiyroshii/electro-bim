// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: contrato abstrato SpecificationService.

import '../models/violacao.dart';

/// Contrato de um serviço de verificação de conformidade normativa.
///
/// Cada implementação verifica um conjunto específico de regras
/// da NBR 5410 (Normas de Especificação) e retorna todas as violações
/// encontradas — sem parar na primeira.
///
/// O [SpecificationService] (orquestrador) agrega os resultados
/// de todas as implementações.
///
/// Implementações:
/// - [SpecCombinacoes] — combinações válidas iso × arq × método
/// - [SpecAluminio]    — restrições de uso do alumínio
/// - [SpecSecaoMinima] — pisos normativos de seção
/// - [SpecNeutro]      — regras do condutor neutro
/// - [SpecQuedaTensao] — limites de queda de tensão por tag
abstract interface class ISpecification<T> {
  /// Verifica a conformidade de [entrada] com as regras desta specification.
  ///
  /// Retorna lista vazia se conforme.
  /// Retorna todas as violações encontradas — nunca lança exceção.
  List<Violacao> verificar(T entrada);
}
