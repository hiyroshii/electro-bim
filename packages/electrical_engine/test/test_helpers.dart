// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: helpers compartilhados entre os testes do normative_engine.

import 'package:normative_engine/normative_engine.dart';

/// Cria uma [EntradaNormativa] válida com valores padrão.
/// Substitua apenas os campos relevantes para cada teste.
EntradaNormativa entradaPadrao({
  TagCircuito tagCircuito = TagCircuito.tug,
  Tensao tensao = Tensao.v220,
  NumeroFases numeroFases = NumeroFases.monofasico,
  Isolacao isolacao = Isolacao.pvc,
  Arquitetura arquitetura = Arquitetura.multipolar,
  MetodoInstalacao metodo = MetodoInstalacao.b1,
  ArranjoCondutores? arranjo,
  Material material = Material.cobre,
  int temperatura = 30,
  bool harmonicasAcima15pct = false,
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
    );
