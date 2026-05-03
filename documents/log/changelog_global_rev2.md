# Changelog Global — ElectroBIM
<!-- REV: 2 -->
<!-- CHANGELOG:
[Rev 2] - 01 05 2026
- CHG: dimensionamento_engine renomeado para electrical_engine em todo o documento.
[Rev 1] - 01 05 2026
- ADD: criação do changelog global do projeto.
-->

> Convenção de versão: `0.CICLO.SUBCICLO`
> `0.x` = pré-MVP | Minor = ciclo principal | Patch = subciclo ou hotfix
> Referência cruzada com changelogs específicos de cada engine.

---

## [0.3.5] — 01 05 2026 — Ciclo 3.5 concluído

### MAJOR — Refatoração arquitetural completa

**Contexto:** O `electrical_engine` foi descontinuado e substituído por um
monorepo com dois packages independentes, separando responsabilidades de norma
e de algoritmo de forma definitiva.

### normative_engine — criado

- ADD: Package Dart puro que encapsula a ABNT NBR 5410:2004.
- ADD: 10 enums de domínio normativo (Isolacao, Arquitetura, MetodoInstalacao,
  ArranjoCondutores, Material, TagCircuito, Tensao, NumeroFases,
  ContextoInstalacao, OrigemAlimentacao).
- ADD: 9 tabelas normativas como `const Map` Dart (Tab. 35–48 da NBR 5410).
- ADD: 5 specs de conformidade (combinações, alumínio, seção mínima, neutro, queda).
- ADD: 2 procedures de cálculo (ampacidade com FCT/FCA, queda com parâmetros normativos).
- ADD: NormativeService com fluxo verificarConformidade → resolverDadosNormativos → auditar.
- ADD: 81 testes unitários.
- ADD: ARCHITECTURE.md e 21 MDs normativos (NBR 5410 — 6.1 a 6.2.11).
- FIX: Limites de queda de tensão corrigidos:
  - Terminal (TUG, TUE, IL): 4% fixo.
  - Alimentador via concessionária: 1% (total 5%).
  - Alimentador via trafo/gerador próprio: 3% (total 7%).

### electrical_engine — criado

- ADD: Package Dart puro com algoritmos de dimensionamento de cargas e circuitos.
- ADD: Três cálculos matemáticos puros: `CalcCorrenteProjeto`, `CalcAmpacidadeCabo`,
  `CalcQuedaTensao` (com reatância Xi e cosφ).
- ADD: `SelecionadorCondutor` — algoritmo iterativo com memória de resultado
  teórico (por corrente) e final (por corrente + queda).
- ADD: `PoliticaDisjuntor` — seleciona In >= Ib no catálogo injetado.
- ADD: `DimensionamentoCircuitoService` — orquestra o fluxo completo de circuito.
- ADD: `GeradorPontosComodo`, `ValidadorComodo`, `AgregadorCircuitos`.
- ADD: `DimensionamentoCargaService` — cria cômodos e processa projetos de carga.
- ADD: `DimensionamentoService` — orquestrador mestre (carga + circuito).
- ADD: `StatusDimensionamento` (aprovado, reprovadoDisjuntor, reprovadoAmpacidade, reprovadoQueda).
- ADD: 79 testes.

### Monorepo

- ADD: Estrutura `packages/` e `apps/` como layout definitivo.
- CHG: `electrical_engine` descontinuado — lógica migrada e expandida.

---

## [0.3.0] — 29 04 2026 — canvas_engine [1.3.0] — Sprint 3

- ADD: canvas_engine — módulo de geometria base completo.
- ADD: `Tolerance`, `Vector2`, `Segment`, `AABB`.
- ADD: `distancePointToSegment`, `closestPointOnSegment`, `isPointOnSegment`.
- ADD: `intersectSegments` (fórmula de Gavin, `IntersectionResult` tipado).
- ADD: `projectPointOntoSegment`, `projectPointOntoLine`.
- ADD: 30 testes de geometria.

---

## [0.2.x] — Ciclos 1–3 — electrical_engine (descontinuado)

Histórico preservado no `changelog_electrical_engine.md` (referência apenas).
O código foi substituído pelo normative_engine + electrical_engine no Ciclo 3.5.

---

## Pendências de registro

- [ ] Versões intermediárias do canvas_engine [1.0.0]–[1.2.0] a detalhar
- [ ] IDs das novas pastas do Drive a registrar após upload
