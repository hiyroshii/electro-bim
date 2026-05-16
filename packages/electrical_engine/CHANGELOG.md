# Changelog — electrical_engine

All notable changes to this package are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

---

## [1.1.0] — 2026-05

### Removed
- Todos os arquivos normativos duplicados (~54 arquivos, −4 000 linhas):
  `lib/normative_engine.dart` (barrel local), contratos, enums, models normativos,
  tabelas NBR, orchestrators normativos, procedures e specifications.
  Substituídos pela dependência `normative_engine` via `path: ../normative_engine`.
- `ContextoInstalacao` removido de `EntradaDimensionamento` — enum foi extinto no
  `normative_engine` na Fase 2 (substituído por `PerfilInstalacao`).
- Testes do normative que viviam em `electrical_engine/test/` (movidos ao package correto).

### Changed
- `EntradaDimensionamento`: campo `contextoInstalacao` removido do construtor e da classe.
- `RelatorioDimensionamento.toResultadoNormativo()`: atualizado para os campos obrigatórios
  da versão 1.1.0 de `ResultadoNormativo` (`ib`, `inDisjuntor`, `izFinal`).
- Todos os testes e helpers atualizados para a API atual do `NormativeService`:
  construtor com `origemAlimentacao` + `perfil: PerfilInstalacao(escopo: ...)`.

---

## [1.0.1] — 2026-05-01

### Fixed
- Imports de `normative_engine` corrigidos após reestruturação de barrel.
- `pubspec.yaml`: dependência path para `normative_engine` adicionada corretamente.

---

## [1.0.0] — 2026-05-01

### Added
- `DimensionamentoEngine` — contrato público do package.
- `DimensionamentoService` — orquestrador mestre: cria cômodos, processa carga,
  dimensiona circuitos.
- `EntradaDimensionamento` / `RelatorioDimensionamento` — modelos de I/O do circuito.
- `EntradaCarga` / `RelatorioCarga` — modelos de I/O do fluxo de carga.
- `Comodo` / `PontoUtilizacao` — representação de cômodo com pontos TUG e IL.
- `CalcCorrenteProjeto`, `SelecionadorCondutor`, `PoliticaDisjuntor` — cálculos puros.
- Testes de integração: `dimensionamento_service_test.dart`,
  `dimensionamento_circuito_service_test.dart`.
