// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: construtor movido antes dos campos.
// [1.0.0] - 2026-04
// - ADD: criação do model Violacao.

/// Representa uma violação normativa identificada pelo [SpecificationService].
final class Violacao {
  const Violacao({
    required this.codigo,
    required this.descricao,
    required this.referencia,
  });

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

  factory Violacao.arranjoObrigatorio({required String metodo}) => Violacao(
        codigo: 'COMB_003',
        descricao: 'Método $metodo requer ArranjoCondutores definido '
            '(não pode ser null).',
        referencia: 'NBR 5410:2004 — Tabelas 38 e 39',
      );

  factory Violacao.arranjoDeveSerNulo({required String metodo}) => Violacao(
        codigo: 'COMB_004',
        descricao: 'Método $metodo não utiliza ArranjoCondutores — '
            'o campo deve ser null.',
        referencia: 'NBR 5410:2004 — Tabelas 36 e 37',
      );

  factory Violacao.arranjoIncompativelComMetodo({
    required String arranjo,
    required String metodo,
  }) =>
      Violacao(
        codigo: 'COMB_005',
        descricao: 'Arranjo $arranjo não é compatível com método $metodo.',
        referencia: 'NBR 5410:2004 — Tabelas 38 e 39',
      );

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

  factory Violacao.aluminioProibidoBd4() => const Violacao(
        codigo: 'ALU_001',
        descricao: 'Condutor de alumínio é proibido em instalações BD4.',
        referencia: 'NBR 5410:2004 — 6.2.3.8',
      );

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

  final String codigo;
  final String descricao;
  final String referencia;

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
