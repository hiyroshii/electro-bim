# Changelog — electrical_engine
<!-- REV: 2 -->
<!-- CHANGELOG:
[Rev 1] - 01 05 2026
- ADD: criação do changelog do electrical_engine.
-->

---

## [1.0.1] — 01 05 2026

### Revisão pós-scaffold

- CHG `dimensionamento_service`: removidos parâmetros `origemAlimentacao` e
  `contextoInstalacao` do construtor — são responsabilidade da `EntradaDimensionamento`
  por circuito.
- CHG `dimensionamento_service`: removidos imports não usados
  (gerador, validador, agregador, selecionador — internos ao sub-serviço).
- ADD `contexto_selecao`: campos `reatanciaXi` (default 0.0) e `fatorHarmonico`
  (default 1.0) — necessários para `CalcQuedaTensao` e `CalcAmpacidadeCabo`.
- CHG `selecionador_condutor`: algoritmo usa `ctx.reatanciaXi` e `ctx.fatorHarmonico`.
- CHG `electrical_engine` (contrato): `criarComodoCustom` — `regraTomadasComodo`
  sem `required` (tem default `custom` na implementação).

---

## [1.0.0] — 01 05 2026

### Criação do package

#### Cálculos (matemática pura)

- ADD `calc_corrente_projeto`: `Ib = P / (V × FP)` (mono) e `P / (√3 × V × FP)` (tri).
- ADD `calc_ampacidade_cabo`: `Iz = izBase × FCT × FCA × fatorHarmonico`.
- ADD `calc_queda_tensao`: `ΔV% = k × I × L × (R×cosφ + Xi×sinφ) / V × 100`
  com reatância e cosφ. `k = 2` (mono) ou `√3` (tri).

#### Models — carga

- ADD `comodo`: `Comodo`, `PontoUtilizacao`, `RegraTomadasComodo`.
- ADD `entrada_carga`: `EntradaCarga`, `CircuitoAgregado`, `StatusCircuito`.
- ADD `relatorio_carga`: `RelatorioCarga`, `PrevisaoCargaComodo`, `StatusPrevisao`,
  `StatusRelatorio`.

#### Models — circuito

- ADD `entrada_dimensionamento`: `EntradaDimensionamento` com `toEntradaNormativa()`
  e `EntradaInvalidaException`.
- ADD `contexto_selecao`: agregador de parâmetros do `SelecionadorCondutor`
  com `resistividade` derivada de material × isolação.
- ADD `resultado_selecao`: campos teórico + final + `StatusDimensionamento`.
- ADD `relatorio_dimensionamento`: saída completa com `toResultadoNormativo()`.

#### Orquestradores — carga

- ADD `gerador_pontos_comodo`: gera TUGs/ILs por `RegraTomadasComodo`
  (`porPerimetro`, `minimoFixo`, `custom`). IDs via UUID.
- ADD `validador_comodo`: valida mínimos normativos por cômodo.
- ADD `agregador_circuitos`: agrupa pontos por `idCircuito`, limites TUG 1500VA / IL 600VA.
- ADD `dimensionamento_carga_service`: `criarComodoComSugestoes`, `criarComodoCustom`,
  `processar` — status global OK somente se todos os cômodos e circuitos aprovados.

#### Orquestradores — circuito

- ADD `politica_disjuntor`: `firstWhere(d.in_ >= ib)` — `StateError` se excede catálogo.
- ADD `selecionador_condutor`: algoritmo iterativo com registro de resultado
  teórico (ampacidade) e final (ampacidade + queda).
- ADD `dimensionamento_circuito_service`: fluxo completo em 8 passos.
  Reprovações via `StatusDimensionamento`, não por exceção.

#### Orquestrador mestre

- ADD `electrical_engine` (interface): 4 métodos públicos.
- ADD `dimensionamento_service`: delega para `DimensionamentoCargaService` e
  `DimensionamentoCircuitoService`. Catálogo de disjuntores injetado.

#### Infraestrutura

- ADD `pubspec.yaml` (Dart ≥3.0, depende de `normative_engine` e `uuid`).
- ADD `analysis_options.yaml`.
- ADD 79 testes.
