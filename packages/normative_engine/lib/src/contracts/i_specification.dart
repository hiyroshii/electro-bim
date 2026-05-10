// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - ADD: aplicavelA(PerfilInstalacao) — filtragem contextual de specs (Fase 2).
// [1.0.0] - 2026-04
// - ADD: contrato abstrato ISpecification.

import '../models/violacao.dart';
import '../domain/instalacao/perfil_instalacao.dart';

export '../domain/instalacao/perfil_instalacao.dart';

/// Contrato de uma regra de verificação normativa.
///
/// Cada implementação verifica um conjunto específico de regras
/// da NBR 5410 e retorna todas as violações — sem parar na primeira.
///
/// O [SpecificationService] filtra specs por [aplicavelA] antes de executar
/// [verificar], garantindo que regras de escopo ou contexto específico
/// não sejam avaliadas fora do seu domínio.
///
/// Implementações:
/// - [SpecCombinacoes]          — combinações válidas iso × arq × método
/// - [SpecAluminio]             — restrições de uso do alumínio
/// - [SpecSecaoMinima]          — pisos normativos de seção
/// - [SpecNeutro]               — regras do condutor neutro
/// - [SpecQuedaTensao]          — limites de queda de tensão por tag
/// - [SpecSobrecarga]           — IB ≤ In ≤ Iz
/// - [SpecDispositivoMultipolar] — corte simultâneo em circuitos especiais
abstract interface class ISpecification<T> {
  /// Retorna true se esta spec se aplica ao [perfil] da instalação.
  ///
  /// Specs universais devem declarar `=> true`.
  /// Specs restritas por escopo, influência ou contexto devem filtrar aqui,
  /// evitando que [verificar] seja chamado fora do domínio da regra.
  bool aplicavelA(final PerfilInstalacao perfil);

  /// Verifica a conformidade de [entrada] com as regras desta specification.
  ///
  /// Pré-condição: [aplicavelA] retornou true para o perfil atual.
  /// Retorna lista vazia se conforme.
  /// Retorna todas as violações encontradas — nunca lança exceção.
  List<Violacao> verificar(final T entrada);
}
