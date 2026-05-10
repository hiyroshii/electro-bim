// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 2026-05
// - ADD: parâmetros faixaTensao, outrasCircuitosNoConduto, compartilhaCaboMultipolar.
// [1.1.0] - 2026-05
// - ADD: parâmetro dispositivoMultipolar em entradaPadrao().
// [1.0.0] - 2026-04
// - ADD: helpers compartilhados entre os testes do normative_engine.

import 'package:normative_engine/normative_engine.dart';

/// Cria uma [EntradaNormativa] válida com valores padrão.
/// Substitua apenas os campos relevantes para cada teste.
EntradaNormativa entradaPadrao({
  final TagCircuito tagCircuito = TagCircuito.tug,
  final Tensao tensao = Tensao.v220,
  final NumeroFases numeroFases = NumeroFases.monofasico,
  final Isolacao isolacao = Isolacao.pvc,
  final Arquitetura arquitetura = Arquitetura.multipolar,
  final MetodoInstalacao metodo = MetodoInstalacao.b1,
  final ArranjoCondutores? arranjo,
  final Material material = Material.cobre,
  final int temperatura = 30,
  final bool harmonicasAcima15pct = false,
  final bool dispositivoMultipolar = true,
  final FaixaTensao faixaTensao = FaixaTensao.faixaII,
  final List<FaixaTensao> outrasCircuitosNoConduto = const [],
  final bool compartilhaCaboMultipolar = false,
}) =>
    EntradaNormativa(
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
