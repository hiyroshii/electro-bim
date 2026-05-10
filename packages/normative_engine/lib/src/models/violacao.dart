// REV: 1.3.0
// CHANGELOG:
// [1.3.0] - 2026-05
// - ADD: Violacao.disjuntorSubdimensionado (SOBRE_001) — 5.3.4.1.
// - ADD: Violacao.disjuntorSuperdimensionado (SOBRE_002) — 5.3.4.1.
// [1.2.0] - 2026-05
// - ADD: Violacao.faixasTensaoMistasNoConduto (COMB_007) — 6.2.9.5.
// - ADD: Violacao.multipolarComMultiplosCircuitos (COMB_008) — 6.2.10.1.
// [1.1.0] - 2026-05
// - ADD: Violacao.dispositivoDeveSerMultipolar (DISP_001) — 9.5.4.
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
    required final String isolacao,
    required final String arquitetura,
  }) =>
      Violacao(
        codigo: 'COMB_001',
        descricao: 'Isolação $isolacao não é compatível com arquitetura '
            '$arquitetura. Verifique as combinações válidas em 6.2.3.',
        referencia: 'NBR 5410:2004 — 6.2.3',
      );

  factory Violacao.combinacaoArquiteturaMetodo({
    required final String arquitetura,
    required final String metodo,
  }) =>
      Violacao(
        codigo: 'COMB_002',
        descricao: 'Arquitetura $arquitetura não é compatível com método '
            '$metodo. Verifique as combinações válidas na Tabela 33.',
        referencia: 'NBR 5410:2004 — Tabela 33',
      );

  factory Violacao.arranjoObrigatorio({required final String metodo}) => Violacao(
        codigo: 'COMB_003',
        descricao: 'Método $metodo requer ArranjoCondutores definido '
            '(não pode ser null).',
        referencia: 'NBR 5410:2004 — Tabelas 38 e 39',
      );

  factory Violacao.arranjoDeveSerNulo({required final String metodo}) => Violacao(
        codigo: 'COMB_004',
        descricao: 'Método $metodo não utiliza ArranjoCondutores — '
            'o campo deve ser null.',
        referencia: 'NBR 5410:2004 — Tabelas 36 e 37',
      );

  factory Violacao.arranjoIncompativelComMetodo({
    required final String arranjo,
    required final String metodo,
  }) =>
      Violacao(
        codigo: 'COMB_005',
        descricao: 'Arranjo $arranjo não é compatível com método $metodo.',
        referencia: 'NBR 5410:2004 — Tabelas 38 e 39',
      );

  factory Violacao.combinacaoTensaoFases({
    required final String tensao,
    required final String fases,
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
    required final double secaoMinima,
    required final String contexto,
  }) =>
      Violacao(
        codigo: 'ALU_002',
        descricao: 'Alumínio requer seção mínima de $secaoMinima mm² '
            'em contexto $contexto.',
        referencia: 'NBR 5410:2004 — 6.2.3.8',
      );

  factory Violacao.temperaturaInadmissivel({
    required final int temperatura,
    required final String isolacao,
  }) =>
      Violacao(
        codigo: 'TEMP_001',
        descricao: 'Temperatura $temperatura°C não é admissível para '
            'isolação $isolacao. Verifique Tabela 40.',
        referencia: 'NBR 5410:2004 — Tabela 40',
      );

  factory Violacao.dispositivoDeveSerMultipolar({
    required final String numeroFases,
  }) =>
      Violacao(
        codigo: 'DISP_001',
        descricao: 'Circuito $numeroFases exige dispositivo de proteção '
            'multipolar (corte simultâneo de todos os polos ativos).',
        referencia: 'NBR 5410:2004 — 9.5.4',
      );

  factory Violacao.faixasTensaoMistasNoConduto({
    required final String faixaCircuito,
    required final String faixaOutro,
  }) =>
      Violacao(
        codigo: 'COMB_007',
        descricao: 'Circuito de Faixa $faixaCircuito compartilha conduto com '
            'circuito de Faixa $faixaOutro. Faixas de tensão distintas não '
            'podem estar no mesmo conduto sem isolação para a maior tensão '
            'presente.',
        referencia: 'NBR 5410:2004 — 6.2.9.5',
      );

  factory Violacao.multipolarComMultiplosCircuitos() => const Violacao(
        codigo: 'COMB_008',
        descricao: 'Cabo multipolar contém condutores de mais de um circuito. '
            'Cabos multipolares são exclusivos de um único circuito.',
        referencia: 'NBR 5410:2004 — 6.2.10.1',
      );

  factory Violacao.disjuntorSubdimensionado({
    required final double ib,
    required final double inDisjuntor,
  }) =>
      Violacao(
        codigo: 'SOBRE_001',
        descricao: 'Corrente de projeto Ib=${ib.toStringAsFixed(1)} A '
            'excede a nominal do disjuntor In=${inDisjuntor.toStringAsFixed(1)} A. '
            'Exigido: Ib ≤ In.',
        referencia: 'NBR 5410:2004 — 5.3.4.1',
      );

  factory Violacao.disjuntorSuperdimensionado({
    required final double inDisjuntor,
    required final double izFinal,
  }) =>
      Violacao(
        codigo: 'SOBRE_002',
        descricao: 'Corrente nominal do disjuntor In=${inDisjuntor.toStringAsFixed(1)} A '
            'excede a ampacidade do condutor Iz=${izFinal.toStringAsFixed(1)} A. '
            'Exigido: In ≤ Iz.',
        referencia: 'NBR 5410:2004 — 5.3.4.1',
      );

  factory Violacao.secaoAbaixoMinimo({
    required final double secaoCalculada,
    required final double secaoMinima,
    required final String tag,
  }) =>
      Violacao(
        codigo: 'SEC_001',
        descricao: 'Seção calculada $secaoCalculada mm² é inferior ao '
            'mínimo normativo de $secaoMinima mm² para circuito $tag.',
        referencia: 'NBR 5410:2004 — Tabela 47',
      );

  factory Violacao.quedaTensaoExcedida({
    required final double quedaCalculada,
    required final double limite,
    required final String tag,
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
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is Violacao &&
          runtimeType == other.runtimeType &&
          codigo == other.codigo &&
          descricao == other.descricao;

  @override
  int get hashCode => Object.hash(codigo, descricao);
}
