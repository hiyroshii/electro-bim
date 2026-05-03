// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do model Violacao.

/// Representa uma violação normativa identificada pelo [SpecificationService].
///
/// Imutável — criada uma vez, nunca modificada.
/// Rastreabilidade: cada instância carrega a referência normativa exata.
final class Violacao {
  /// Código único da violação.
  /// Formato: CATEGORIA_NNN (ex: COMB_001, ALU_001, QUEDA_001).
  final String codigo;

  /// Descrição legível da violação — direcionada ao desenvolvedor/usuário.
  final String descricao;

  /// Referência normativa exata que origina a violação.
  /// Exemplo: 'NBR 5410:2004 — Tabela 33', 'NBR 5410:2004 — 6.2.3.8.1'.
  final String referencia;

  const Violacao({
    required this.codigo,
    required this.descricao,
    required this.referencia,
  });

  // ── Factories por categoria ───────────────────────────────────────────────

  /// Combinação inválida de Isolacao × Arquitetura.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.3.
  factory Violacao.combinacaoIsolacaoArquitetura({
    required String isolacao,
    required String arquitetura,
  }) =>
      Violacao(
        codigo: 'COMB_001',
        descricao: 'Isolação $isolacao não é compatível com arquitetura '
            '$arquitetura. Verifique as combinações válidas em 6.2.3.',
        referencia: 'NBR 5410:2004 — 6.2.3',
      );

  /// Combinação inválida de Arquitetura × MetodoInstalacao.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 33.
  factory Violacao.combinacaoArquiteturaMetodo({
    required String arquitetura,
    required String metodo,
  }) =>
      Violacao(
        codigo: 'COMB_002',
        descricao: 'Arquitetura $arquitetura não é compatível com método '
            '$metodo. Verifique as combinações válidas na Tabela 33.',
        referencia: 'NBR 5410:2004 — Tabela 33',
      );

  /// ArranjoCondutores ausente para métodos F ou G.
  /// Rastreabilidade: NBR 5410:2004 — Tabelas 38 e 39.
  factory Violacao.arranjoObrigatorio({required String metodo}) => Violacao(
        codigo: 'COMB_003',
        descricao: 'Método $metodo requer ArranjoCondutores definido '
            '(não pode ser null).',
        referencia: 'NBR 5410:2004 — Tabelas 38 e 39',
      );

  /// ArranjoCondutores presente para métodos A1–E (deve ser null).
  /// Rastreabilidade: NBR 5410:2004 — Tabelas 36 e 37.
  factory Violacao.arranjoDeveSerNulo({required String metodo}) => Violacao(
        codigo: 'COMB_004',
        descricao: 'Método $metodo não utiliza ArranjoCondutores — '
            'o campo deve ser null.',
        referencia: 'NBR 5410:2004 — Tabelas 36 e 37',
      );

  /// ArranjoCondutores incompatível com o método informado.
  /// Rastreabilidade: NBR 5410:2004 — Tabelas 38 e 39.
  factory Violacao.arranjoIncompativelComMetodo({
    required String arranjo,
    required String metodo,
  }) =>
      Violacao(
        codigo: 'COMB_005',
        descricao: 'Arranjo $arranjo não é compatível com método $metodo.',
        referencia: 'NBR 5410:2004 — Tabelas 38 e 39',
      );

  /// Combinação inválida de Tensao × NumeroFases.
  /// Rastreabilidade: NBR 5410:2004 — 6.1.3.1.1.
  factory Violacao.combinacaoTensaoFases({
    required String tensao,
    required String fases,
  }) =>
      Violacao(
        codigo: 'COMB_006',
        descricao: 'Tensão $tensao não suporta $fases. '
            'Verifique as combinações válidas em 6.1.3.1.1.',
        referencia: 'NBR 5410:2004 — 6.1.3.1.1',
      );

  /// Alumínio proibido em BD4.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.3.8.
  factory Violacao.aluminioProibidoBd4() => const Violacao(
        codigo: 'ALU_001',
        descricao: 'Condutor de alumínio é proibido em instalações BD4.',
        referencia: 'NBR 5410:2004 — 6.2.3.8',
      );

  /// Alumínio abaixo da seção mínima para o contexto.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.3.8.1 / 6.2.3.8.2.
  factory Violacao.aluminioSecaoInsuficiente({
    required double secaoMinima,
    required String contexto,
  }) =>
      Violacao(
        codigo: 'ALU_002',
        descricao: 'Alumínio requer seção mínima de $secaoMinima mm² '
            'em contexto $contexto.',
        referencia: 'NBR 5410:2004 — 6.2.3.8',
      );

  /// Temperatura não admissível para a isolação informada.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 40.
  factory Violacao.temperaturaInadmissivel({
    required int temperatura,
    required String isolacao,
  }) =>
      Violacao(
        codigo: 'TEMP_001',
        descricao: 'Temperatura ${temperatura}°C não é admissível para '
            'isolação $isolacao. Verifique Tabela 40.',
        referencia: 'NBR 5410:2004 — Tabela 40',
      );

  /// Seção calculada abaixo do mínimo normativo da Tabela 47.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 47.
  factory Violacao.secaoAbaixoMinimo({
    required double secaoCalculada,
    required double secaoMinima,
    required String tag,
  }) =>
      Violacao(
        codigo: 'SEC_001',
        descricao: 'Seção calculada $secaoCalculada mm² é inferior ao '
            'mínimo normativo de $secaoMinima mm² para circuito $tag.',
        referencia: 'NBR 5410:2004 — Tabela 47',
      );

  /// Queda de tensão acima do limite normativo.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.7.
  factory Violacao.quedaTensaoExcedida({
    required double quedaCalculada,
    required double limite,
    required String tag,
  }) =>
      Violacao(
        codigo: 'QUEDA_001',
        descricao: 'Queda de tensão ${quedaCalculada.toStringAsFixed(2)}% '
            'excede o limite de ${limite.toStringAsFixed(1)}% '
            'para circuito $tag.',
        referencia: 'NBR 5410:2004 — 6.2.7',
      );

  @override
  String toString() => '[$codigo] $descricao ($referencia)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Violacao &&
          runtimeType == other.runtimeType &&
          codigo == other.codigo &&
          descricao == other.descricao;

  @override
  int get hashCode => Object.hash(codigo, descricao);
}
