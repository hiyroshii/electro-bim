# Contexto — electrical_engine
<!-- REV: 2 -->
<!-- CHANGELOG:
[Rev 2] - 01 05 2026
- CHG: renomeado de dimensionamento_engine para electrical_engine.
[Rev 1] - 01 05 2026
- ADD: criação do documento de contexto específico do electrical_engine.
-->

> Complementa o contexto geral do projeto (`contexto_projeto_electrobim_rev6.md`).
> Foco: decisões, contratos e detalhes internos exclusivos do electrical_engine.

---

## 1. Propósito

Package Dart puro que implementa os algoritmos de dimensionamento de cargas e
circuitos elétricos conforme NBR 5410:2004.

**Não conhece a norma diretamente** — consome o `normative_engine` para regras,
tabelas e fatores. Os `Calc*` são matemática pura.

---

## 2. Fluxo interno do dimensionamento de circuito

```
DimensionamentoCircuitoService.processar(EntradaDimensionamento)
  │
  ├─ 1. toEntradaNormativa()                          conversão de modelos
  ├─ 2. normative.verificarConformidade()             aborta se inválido
  ├─ 3. CalcCorrenteProjeto.calcular()                Ib
  ├─ 4. normative.resolverDadosNormativos()           tabelas, FCT/FCA, limites
  ├─ 5. PoliticaDisjuntor.selecionar()                In — StateError → REPROVADO_DISJUNTOR
  ├─ 6. ContextoSelecao (montagem)                    agrega tudo para o selecionador
  ├─ 7. SelecionadorCondutor.selecionar()             itera seções → ResultadoSelecao
  └─ 8. _montarRelatorio()                            RelatorioDimensionamento
```

---

## 3. Estrutura interna

```
src/
  calculos/
    calc_corrente_projeto.dart   ← Ib = P / (V × FP) ou P / (√3 × V × FP)
    calc_ampacidade_cabo.dart    ← Iz = izBase × FCT × FCA × fatorHarmonico
    calc_queda_tensao.dart       ← ΔV% = k × I × L × (R×cosφ + Xi×sinφ) / V × 100

  models/
    carga/
      comodo.dart                ← Comodo, PontoUtilizacao, RegraTomadasComodo
      entrada_carga.dart         ← EntradaCarga, CircuitoAgregado, StatusCircuito
      relatorio_carga.dart       ← RelatorioCarga, PrevisaoCargaComodo, StatusPrevisao
    circuito/
      entrada_dimensionamento.dart  ← EntradaDimensionamento + toEntradaNormativa()
                                       + EntradaInvalidaException
      contexto_selecao.dart         ← agrega parâmetros do SelecionadorCondutor
                                       + resistividade derivada
      resultado_selecao.dart        ← campos teórico + final + StatusDimensionamento
      relatorio_dimensionamento.dart← saída completa + toResultadoNormativo()

  orchestrator/
    carga/
      gerador_pontos_comodo.dart    ← gera TUGs e ILs por regra normativa
      validador_comodo.dart         ← valida mínimos normativos por cômodo
      agregador_circuitos.dart      ← agrupa pontos por idCircuito, verifica limites
      dimensionamento_carga_service.dart ← orquestra carga
    circuito/
      politica_disjuntor.dart       ← seleciona In >= Ib no catálogo
      selecionador_condutor.dart    ← itera tabela, seleciona seção ótima
      dimensionamento_circuito_service.dart ← orquestra circuito
    electrical_engine.dart     ← interface ElectricalEngine (4 métodos)
    dimensionamento_service.dart    ← orquestrador mestre
```

---

## 4. Contrato público (ElectricalEngine)

```dart
abstract interface class ElectricalEngine {
  Comodo criarComodoComSugestoes({...});
  Comodo criarComodoCustom({...});
  RelatorioCarga processarCarga(EntradaCarga entrada);
  RelatorioDimensionamento dimensionarCircuito(EntradaDimensionamento entrada);
}
```

---

## 5. SelecionadorCondutor — algoritmo

Itera `ContextoSelecao.tabelaIz` (seções ordenadas crescentes):

```
Para cada linha:
  1. Pular se secao < secaoMinima
  2. CalcAmpacidadeCabo → Iz corrigida (com fatorHarmonico)
  3. CalcQuedaTensao → ΔV% (com reatanciaXi e cosPhi)
  4. Iz >= In → registra TEÓRICO (se ainda não registrado)
  5. Iz >= In E ΔV <= limite → retorna APROVADO

Sem teórico → reprovadoAmpacidade()
Com teórico, sem ΔV → reprovadoQueda(secaoMaior = última seção iterada)
```

**Dois momentos registrados no `ResultadoSelecao`:**
- `secaoTeorica/izTeorico/quedaTeorica` — mínimo por corrente
- `secaoFinal/izFinal/quedaFinal` — mínimo por corrente + queda

---

## 6. StatusDimensionamento

```dart
enum StatusDimensionamento {
  aprovado,            // Iz >= In e ΔV <= limite
  reprovadoDisjuntor,  // Ib > maior In do catálogo
  reprovadoAmpacidade, // Iz max < In
  reprovadoQueda,      // Iz >= In mas ΔV excede em todas as seções
}
```

---

## 7. Limites normativos de carga (AgregadorCircuitos)

| Tag | Limite por circuito |
|---|---|
| TUG | 1500 VA |
| IL | 600 VA |

---

## 8. GeradorPontosComodo — regras

| RegraTomadasComodo | TUGs gerados | ILs gerados |
|---|---|---|
| `porPerimetro` | `ceil(perimetro / 5)` mínimo 1 | 1 |
| `minimoFixo` | 2 | 1 |
| `custom` | 0 (usuário define) | 0 |

---

## 9. Decisões de design específicas

**`ContextoSelecao` como agregador de parâmetros**
O selecionador recebe um objeto, não parâmetros soltos. Evita lista crescente
de argumentos. `resistividade` é derivada do material e isolação dentro de `ContextoSelecao`.

**`ResultadoSelecao` com campos teórico + final**
Memória de cálculo essencial para o relatório. O usuário precisa saber qual seção
foi determinada pela corrente e qual pela queda de tensão.

**`PoliticaDisjuntor` lança `StateError`**
`StateError` é capturado pelo `DimensionamentoCircuitoService` e convertido em
`REPROVADO_DISJUNTOR` no relatório — sem propagação ao chamador.

**Catálogo de disjuntores injetado pelo app**
É dado de produto (Siemens, Schneider, WEG), não regra normativa.
`ElectricalService` recebe `List<Disjuntor>` no construtor.

**`reatanciaXi = 0.0` como default**
Tabela de reatâncias por seção/material ainda não implementada.
O campo existe no `ContextoSelecao` para quando a tabela for adicionada.

**`secaoNeutro` como proxy no `toResultadoNormativo()`**
`RelatorioDimensionamento.toResultadoNormativo()` usa `secaoFase` para o neutro.
TODO ciclo 4.1: política real de neutro.

**`OrigemAlimentacao` e `ContextoInstalacao` por circuito**
Cada circuito define seu próprio contexto via `EntradaDimensionamento`.
O `ElectricalService` não guarda esse contexto — é responsabilidade do app.

---

## 10. Cobertura de testes

| Arquivo | Casos |
|---|---|
| `calculos_test` | 16 |
| `dimensionamento_circuito_test` (PoliticaDisjuntor + Selecionador) | 15 |
| `dimensionamento_circuito_service_test` | 12 |
| `dimensionamento_carga_test` | 27 |
| `dimensionamento_service_test` | 9 |
| **Total** | **79** |

---

## 11. Pendências (TODO)

| Item | Ciclo |
|---|---|
| `secaoNeutro` real em `toResultadoNormativo()` | 4.1 |
| Tabela de reatâncias Xi (por seção e material) | 4.0 |
| Catálogo de disjuntores como asset em `apps/flutter` | 4.0 |
| Fator de demanda no `AgregadorCircuitos` | 4.x |
| Campo `controlavel` em `PontoUtilizacao` (hook automação) | 11+ |
