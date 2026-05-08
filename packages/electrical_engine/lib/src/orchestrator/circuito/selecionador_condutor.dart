// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - CHG: Xi resolvido por seção via ctx.tabelaXi — substitui reatanciaXi fixo.
// [1.0.1] - 2026-04
// - ADD: implementação completa do algoritmo de seleção.
// [1.0.0] - 2026-04
// - ADD: scaffold de SelecionadorCondutor com ContextoSelecao.

import '../../models/circuito/contexto_selecao.dart';
import '../../models/circuito/resultado_selecao.dart';
import '../../calculos/calc_ampacidade_cabo.dart';
import '../../calculos/calc_queda_tensao.dart';

/// Itera sobre as seções disponíveis (menor para maior) e seleciona
/// o condutor que satisfaz simultaneamente:
///   1. Iz corrigida (izBase × FCT × FCA × fatorHarmonico) ≥ In
///   2. Queda de tensão percentual ≤ limite normativo
///
/// Algoritmo plugável — recebe números, não sabe que existe NBR 5410.
/// Os dados normativos chegam via [ContextoSelecao] resolvido pelo engine.
final class SelecionadorCondutor {
  const SelecionadorCondutor();

  /// Executa o algoritmo de seleção e retorna [ResultadoSelecao].
  /// Nunca lança exceção — usa o status do resultado para comunicar falhas.
  ResultadoSelecao selecionar(ContextoSelecao ctx) {
    double? secaoTeorica;
    double? izTeorico;
    double? quedaTeorica;

    double ultimaSecao = 0;
    double ultimaIz = 0;
    double ultimaQueda = 0;

    final isTrifasico = ctx.numeroFases.isTrifasico;

    for (final linha in ctx.tabelaIz) {
      // Pula seções abaixo do mínimo normativo
      if (linha.secao < ctx.secaoMinima) continue;

      // 1. Calcular Iz corrigida para esta seção
      final resultadoAmp = CalcAmpacidadeCabo.calcular(
        linha: linha,
        fatores: ctx.fatores,
        fatorHarmonico: ctx.fatorHarmonico,
      );

      // 2. Calcular resistência e queda de tensão
      final resistencia = ctx.resistividade / linha.secao;
      final xi = ctx.tabelaXi[linha.secao] ?? 0.0;
      final quedaPercentual = CalcQuedaTensao.calcularPercentual(
        distancia: ctx.distancia,
        corrente: ctx.ib,
        tensao: ctx.tensao,
        resistencia: resistencia,
        reatancia: xi,
        isTrifasico: isTrifasico,
        cosPhi: ctx.fatorPotencia,
      );

      // Salva o pior caso iterado (para reprovadoQueda)
      ultimaSecao = linha.secao;
      ultimaIz = resultadoAmp.izCabo;
      ultimaQueda = quedaPercentual;

      final atendeAmpacidade = resultadoAmp.izCabo >= ctx.inDisjuntor;

      // Registra o teórico — primeira seção que atende só ampacidade
      if (atendeAmpacidade && secaoTeorica == null) {
        secaoTeorica = linha.secao;
        izTeorico = resultadoAmp.izCabo;
        quedaTeorica = quedaPercentual;
      }

      // Critério final: ampacidade E queda simultâneos
      if (atendeAmpacidade && quedaPercentual <= ctx.limiteQueda) {
        return ResultadoSelecao(
          secaoTeorica: secaoTeorica!,
          izTeorico: izTeorico!,
          quedaTeorica: quedaTeorica!,
          secaoFinal: linha.secao,
          izFinal: resultadoAmp.izCabo,
          quedaFinal: quedaPercentual,
          status: StatusDimensionamento.aprovado,
        );
      }
    }

    // Nenhuma seção atendeu a corrente
    if (secaoTeorica == null) {
      return ResultadoSelecao.reprovadoAmpacidade();
    }

    // Seção teórica encontrada mas queda excedida em todas
    return ResultadoSelecao.reprovadoQueda(
      secaoTeorica: secaoTeorica!,
      izTeorico: izTeorico!,
      quedaTeorica: quedaTeorica!,
      secaoMaior: ultimaSecao,
      izMaior: ultimaIz,
      quedaMaior: ultimaQueda,
    );
  }
}
