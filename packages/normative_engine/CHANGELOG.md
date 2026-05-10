# Changelog — normative_engine

Segue [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versões semânticas conforme [SemVer](https://semver.org/lang/pt-BR/).

---

## [0.5.0] — 2026-05 — Fase 2: Reestruturação dos 4 contratos

### Added
- `IClassification<I>` — contrato de classificação contextual; `classificar(I dados) → CodigoInfluencia?`
- `IVerification<M, P, R>` — contrato de verificação de campo; `ensaiar(M medicao, P projeto) → R` (skeleton)
- `CodigoInfluencia` enum — códigos de influência externa NBR: ba3, ba4, ba5, bd1, bd2, bd3, bd4
- `PerfilInstalacao` — VO imutável: `EscopoProjeto escopo` + `Set<CodigoInfluencia> influencias`
- `ClassCompetenciaBa` — `IClassification<DadosCompetenciaBa>` (BA: competência dos usuários)
- `ClassFugaEmergenciaBd` — `IClassification<DadosMaterialBd>` (BD: natureza dos materiais processados)
- `ClassPerfilPadraoPorEscopo` — resolve `PerfilInstalacao` padrão a partir de `EscopoProjeto`
- `ClassificationService` — sub-orquestrador que agrega BA + BD em `PerfilInstalacao`
- `VerificationService` — skeleton para verificações de campo (Fase 3+)

### Changed
- `ISpecification<T>` — adicionado `bool aplicavelA(PerfilInstalacao perfil)` (abstract); cada spec declara explicitamente sua aplicabilidade
- `EscopoProjeto` — adicionados `comercial` e `industrial` (era só `residencial`)
- `SpecAluminio` — migrada de `ContextoInstalacao` para `PerfilInstalacao`; suporta industrial (≥ 16mm²) e comercial BD1 (≥ 50mm²)
- `SpecificationService` — recebe `PerfilInstalacao` e filtra specs via `aplicavelA(perfil)` antes de verificar
- `NormativeService` — construtor atualizado: `ContextoInstalacao` → `PerfilInstalacao`
- Reorganização de `specification/` em subdirectórios: `condutor/`, `protecao/`, `instalacao/`
- Reorganização de `procedure/` em subdirectórios: `condutor/`, `tensao/`

### Removed
- `ContextoInstalacao` enum — substituído por `PerfilInstalacao` VO

---

## [0.4.0] — 2026-05 — Fase 1: Consolidação

### Added
- `SpecSobrecarga` (S-3) — IB ≤ In ≤ Iz conforme NBR 5410:2004 §5.3.4.1
  - `SOBRE_001`: disjuntor subdimensionado (IB > In)
  - `SOBRE_002`: disjuntor superdimensionado (In > Iz)
- `Violacao.disjuntorSubdimensionado` e `Violacao.disjuntorSuperdimensionado` — factories S-3
- `ResultadoNormativo` estendido: campos `ib`, `inDisjuntor`, `izFinal` para auditoria S-3
- `SpecificationService.auditar()` inclui `SpecSobrecarga` como primeiro verificador
- `analysis_options.yaml` reestruturado: `strict-casts`, `strict-inference`, `strict-raw-types`, `prefer_final_parameters`, `prefer_const_constructors`, `prefer_const_declarations`, `cascade_invocations`, `avoid_catches_without_on_clauses`, `parameter_assignments`
- Testes: `spec_sobrecarga_test.dart` (14 casos), `normative_service_test.dart` +2 casos S-3

### Fixed
- `spec_neutro_test.dart`: caso "Fase 95mm², neutro 35mm²" corrigido — mínimo Tab. 48 é 50mm²
- `normative_engine_test.dart`: substituído scaffold vazio por smoke tests reais
- `procedure_service.dart`: `prefer_final_parameters` + import desnecessário removido
- `tensao.dart`: `sort_constructors_first` — construtor movido antes dos campos

---

## [0.3.0] — 2026-05 — Ciclo 4.2

### Added
- `COMB_007` (6.2.9.5) — proibição de circuitos Faixa I e II no mesmo conduto
- `COMB_008` (6.2.10.1) — proibição de circuitos distintos em cabo multipolar compartilhado
- `FaixaTensao` enum (Anexo A — Faixa I: SELV/PELV, Faixa II: convencional)
- `EntradaNormativa` estendida: `faixaTensao`, `outrasCircuitosNoConduto`, `compartilhaCaboMultipolar`

---

## [0.2.0] — 2026-05 — Ciclo 4.1

### Added
- `ProcSecaoNeutro` — cálculo do condutor neutro conforme 6.2.6.2
- `SpecDispositivoMultipolar` — corte simultâneo conforme 9.5.4
- `EscopoProjeto` enum — residencial, comercial, industrial
- `NormativeEngine.calcularSecaoNeutro()` + implementação em `NormativeService`
- `EntradaNormativa.dispositivoMultipolar` (bool, default true)

---

## [0.1.0] — 2026-04 — Fundação

### Added
- Contratos: `ISpecification<T>`, `IProcedure<I,O>`, `NormativeEngine`
- Orchestrators: `NormativeService`, `SpecificationService`, `ProcedureService`
- Specifications: `SpecCombinacoes` (S-1), `SpecAluminio` (S-2), `SpecSecaoMinima` (S-4), `SpecNeutro`, `SpecQuedaTensao` (S-5)
- Procedures: `ProcAmpacidade` (P-1), `ProcQuedaTensao` (P-2)
- Tabelas: 36–42/45 (ampacidade + correção), Tab. 47/48 (neutro), Tab. Xi (reatância)
- Modelos: `EntradaNormativa`, `DadosNormativos`, `ResultadoNormativo`, `Violacao`
- Enums: `Isolacao`, `Arquitetura`, `MetodoInstalacao`, `ArranjoCondutores`, `Material`, `TagCircuito`, `Tensao`, `NumeroFases`, `OrigemAlimentacao`, `ContextoInstalacao`
- Suíte de testes inicial — espelho de `lib/src/`
