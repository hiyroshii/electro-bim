// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 2026-05
// - ADD: faixaTensao, outrasCircuitosNoConduto, compartilhaCaboMultipolar — repassa para EntradaNormativa.
// [1.1.0] - 2026-05
// - ADD: dispositivoMultipolar:bool (default true) — repassa para EntradaNormativa.
// [1.0.1] - 2026-05
// - FIX: construtores movidos antes dos campos em EntradaDimensionamento e EntradaInvalidaException.
// [1.0.0] - 2026-04
// - ADD: scaffold de EntradaDimensionamento.

import 'package:normative_engine/normative_engine.dart';

/// Dados de entrada para o dimensionamento de um circuito elétrico.
final class EntradaDimensionamento {
  const EntradaDimensionamento({
    required this.idCircuito,
    required this.tagCircuito,
    required this.potenciaVA,
    required this.fatorPotencia,
    required this.tensao,
    required this.numeroFases,
    required this.isolacao,
    required this.arquitetura,
    required this.metodo,
    required this.material,
    required this.temperatura,
    required this.distancia,
    required this.origemAlimentacao,
    required this.contextoInstalacao,
    required this.paramsAgrupamento,
    this.arranjo,
    this.harmonicasAcima15pct = false,
    this.dispositivoMultipolar = true,
    this.faixaTensao = FaixaTensao.faixaII,
    this.outrasCircuitosNoConduto = const [],
    this.compartilhaCaboMultipolar = false,
  });

  final String idCircuito;
  final TagCircuito tagCircuito;
  final double potenciaVA;
  final double fatorPotencia;
  final Tensao tensao;
  final NumeroFases numeroFases;
  final Isolacao isolacao;
  final Arquitetura arquitetura;
  final MetodoInstalacao metodo;
  final ArranjoCondutores? arranjo;
  final Material material;
  final int temperatura;
  final double distancia;
  final bool harmonicasAcima15pct;
  final bool dispositivoMultipolar;
  final FaixaTensao faixaTensao;
  final List<FaixaTensao> outrasCircuitosNoConduto;
  final bool compartilhaCaboMultipolar;
  final OrigemAlimentacao origemAlimentacao;
  final ContextoInstalacao contextoInstalacao;
  final ParamsAgrupamento paramsAgrupamento;

  /// Converte para [EntradaNormativa] para uso no [NormativeEngine].
  EntradaNormativa toEntradaNormativa() => EntradaNormativa(
        tagCircuito: tagCircuito,
        tensao: tensao,
        numeroFases: numeroFases,
        isolacao: isolacao,
        arquitetura: arquitetura,
        metodo: metodo,
        arranjo: arranjo,
        material: material,
        temperatura: temperatura,
        harmonicasAcima15pct: harmonicasAcima15pct,
        dispositivoMultipolar: dispositivoMultipolar,
        faixaTensao: faixaTensao,
        outrasCircuitosNoConduto: outrasCircuitosNoConduto,
        compartilhaCaboMultipolar: compartilhaCaboMultipolar,
      );

  /// 3 para trifásico, 2 para mono/bifásico.
  int get condutoresAtivos => numeroFases.isTrifasico ? 3 : 2;
}

/// Exceção lançada quando a entrada não passa na verificação normativa.
final class EntradaInvalidaException implements Exception {
  const EntradaInvalidaException(this.violacoes);

  final List<Violacao> violacoes;

  @override
  String toString() => 'EntradaInvalidaException: '
      '${violacoes.length} violação(ões):\n'
      '${violacoes.map((v) => '  - $v').join('\n')}';
}
