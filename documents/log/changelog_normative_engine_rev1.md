# Changelog — normative_engine
<!-- REV: 3 -->
<!-- CHANGELOG:
[Rev 3] - 09 05 2026
- ADD: entrada do ciclo 4.1 — proc_secao_neutro, spec_dispositivo_multipolar, EscopoProjeto, calc_potencia_tue.
[Rev 2] - 08 05 2026
- ADD: entrada do ciclo 4.0 — temperatura inadmissível e tabela Xi.
[Rev 1] - 01 05 2026
- ADD: criação do changelog do normative_engine.
-->

---

## [1.2.0] — 09 05 2026

### Ciclo 4.1 — Fase 1 → v0.4.0 (itens restantes)

#### normative_engine

- ADD `proc_secao_neutro.dart`: cálculo da seção mínima do condutor neutro (mm²).
  Regras: monofásico → neutro = fase; harm>15% → neutro = fase;
  trifásico harm≤15% fase>25mm² → Tabela 48; demais → neutro = fase.
  Rastreabilidade: NBR 5410:2004 — 6.2.6.2.
- ADD `calcularSecaoNeutro()` em `NormativeEngine` (interface + barrel + `NormativeService`).
  Substitui o proxy `secaoFase` usado em `RelatorioDimensionamento.toResultadoNormativo()`.
- ADD `spec_dispositivo_multipolar.dart`: circuitos bifásicos/trifásicos exigem dispositivo multipolar.
  Emite `Violacao.dispositivoDeveSerMultipolar()` (DISP_001) quando `!dispositivoMultipolar`.
  Rastreabilidade: NBR 5410:2004 — 9.5.4.
- ADD `Violacao.dispositivoDeveSerMultipolar()` — código DISP_001.
- CHG `entrada_normativa.dart`: campo `dispositivoMultipolar: bool = true` (default não-breaking).
- CHG `specification_service.dart`: `SpecDispositivoMultipolar` em `verificarConformidade()`.
- ADD `escopo_projeto.dart`: enum `EscopoProjeto { residencial }` — preparação Fase 6+.
  Rastreabilidade: NBR 5410:2004 — Seção 9.
- ADD: 8 novos testes em `proc_secao_neutro_test.dart`.
- ADD: 9 novos testes em `spec_dispositivo_multipolar_test.dart`.
- ADD: 6 novos testes em `normative_service_test.dart` (calcularSecaoNeutro + DISP_001).

#### electrical_engine

- ADD `calc_potencia_tue.dart`: conversão de potência de plaqueta (W) para aparente (VA).
  Separação explícita: TUG = estimativa (100 VA × pontos); TUE = plaqueta / FP.
  Rastreabilidade: NBR 5410:2004 — 9.1.2.3.
- CHG `relatorio_dimensionamento.dart`: campo `secaoNeutro: double` — substitui proxy `secaoFase`.
  `toResultadoNormativo()` usa o valor calculado.
- CHG `dimensionamento_circuito_service.dart`: calcula `secaoNeutro` via `NormativeEngine.calcularSecaoNeutro()` após seleção do condutor de fase.
- CHG `entrada_dimensionamento.dart`: campo `dispositivoMultipolar: bool = true` repassado para `EntradaNormativa`.
- ADD: 4 novos testes em `calculos_test.dart` (CalcPotenciaTue).
- ADD: 4 novos testes em `dimensionamento_circuito_service_test.dart` (secaoNeutro + DISP_001).

---

## [1.1.0] — 08 05 2026

### Ciclo 4.0 — Temperatura inadmissível + Tabela Xi

#### normative_engine

- ADD `spec_combinacoes`: verificação de temperatura admissível por isolação (TEMP_001).
  Emite `Violacao.temperaturaInadmissivel()` quando `fctAr`/`fctSolo[isolacao][temperatura] == null`.
  Cobre: temperaturas inadmissíveis (PVC ≥ 65°C) e faixas fora da Tabela 40.
  Rastreabilidade: NBR 5410:2004 — Tabela 40.
- ADD `tabela_xi_reatancia.dart`: reatâncias Xi (Ω/m a 50 Hz) por seção e material.
  Cobre e alumínio para todas as seções normativas (0,5–1000 mm² Cu; 16–1000 mm² Al).
  Rastreabilidade: NBR 5410:2004 — 6.2.7.4; IEC 60364-5-52 Tab. B.52.16.
- ADD `dados_normativos.dart`: campo `tabelaXi: Map<double, double>` — seção → Xi (Ω/m).
  Populado por material, filtrado pelo `ProcedureService`.
- CHG `procedure_service.dart`: popula `tabelaXi` no `DadosNormativos`.
- ADD: 9 novos testes em `spec_combinacoes_test.dart` (temperatura admissível — TEMP_001).
- ADD: 2 novos testes em `normative_service_test.dart` (`tabelaXi` por material).

#### electrical_engine

- CHG `contexto_selecao.dart`: `reatanciaXi: double` → `tabelaXi: Map<double, double>`.
- CHG `selecionador_condutor.dart`: Xi por seção via `ctx.tabelaXi[linha.secao]` na iteração.
- CHG `dimensionamento_circuito_service.dart`: `tabelaXi` de `DadosNormativos` → `ContextoSelecao`.
- CHG `dimensionamento_circuito_test.dart`: `_ctx()` — `reatanciaXi` removido, `tabelaXi` adicionado.

---

## [1.0.3] — 01 05 2026

### FIX: Limites de queda de tensão (segunda correção)

- FIX `tag_circuito`: restaurada distinção `OrigemAlimentacao` com valores corretos.
  - `limiteQuedaAlimentadorEntrega = 1.0` (anterior: 5.0 → errado → 1.0 fixo → 1.0 com distinção)
  - `limiteQuedaAlimentadorProprio = 3.0` (anterior: 7.0 → errado → removido → 3.0 correto)
  - `limiteQuedaTotalEntrega = 5.0` — novo
  - `limiteQuedaTotalProprio = 7.0` — novo
- FIX `spec_queda_tensao`: `_resolverLimite` restaurado com switch de origem.
- FIX `proc_queda_tensao`: mesma correção.
- FIX `parametros_queda`: comentário corrigido.

---

## [1.0.2] — 01 05 2026

### FIX: Limites de queda de tensão (primeira correção — parcialmente incorreta)

> Esta versão foi imediatamente sucedida pela 1.0.3 após esclarecimento normativo.

- FIX `tag_circuito`: limites de alimentador corrigidos de 5%/7% para 1%.
- Incorreto: removida distinção `OrigemAlimentacao` (revertido em 1.0.3).

---

## [1.0.1] — 01 05 2026

### Revisão pós-implementação

- FIX `proc_queda_tensao`: `_resolverCondutores` retornava `double` em vez de `int` — corrigido.
- FIX `proc_ampacidade`: lookup limitado a `min(condutores, 3)` para harmônicas > 15%
  (4 condutores usa coluna 3c + fator 0,86).
- CHG `normative_service`: `paramsAgrupamento` movido para parâmetro de
  `resolverDadosNormativos()` — era por instância (inviabilizava múltiplos circuitos).
- CHG `entrada_normativa`: removido `numCircuitosAgrupados` — campo morto.
- CHG `spec_aluminio` + `spec_queda_tensao`: `ContextoInstalacao` e `OrigemAlimentacao`
  movidos para `src/enums/` — eram definidos dentro de specs (implementação interna).
- FIX `violacao`: `operator ==` incluí `descricao` — dois `ALU_002` com seções
  diferentes não colidiam corretamente.
- FIX `spec_combinacoes_test`: teste com nome errado (`MULTIPOLAR não aceita E`
  testava F). Corrigido + adicionado caso `(MULTIPOLAR, E)`.
- CHG `procedure_service`: imports não usados removidos.
- CHG `tensao`: linhas em branco no final do arquivo removidas.

---

## [1.0.0] — 01 05 2026

### Criação do package

- ADD: 10 enums — `Isolacao`, `Arquitetura`, `MetodoInstalacao`, `ArranjoCondutores`,
  `Material`, `TagCircuito`, `Tensao`, `NumeroFases`, `ContextoInstalacao`,
  `OrigemAlimentacao`.
- ADD: 9 tabelas normativas como `const Map` Dart:
  Tabelas 35 (temp serviço), 36 (Iz PVC A1–D), 37 (Iz XLPE/EPR A1–D),
  38 (Iz PVC E/F/G), 39 (Iz XLPE/EPR E/F/G), 40 (FCT temperatura),
  41 (FCA resistividade solo), 42–45 (FCA agrupamento), 47–48 (seção mínima e neutro).
- ADD: 5 specs — `spec_combinacoes`, `spec_aluminio`, `spec_secao_minima`,
  `spec_neutro`, `spec_queda_tensao`.
- ADD: 2 procedures — `proc_ampacidade` (FCT/FCA/tabela Iz), `proc_queda_tensao`.
- ADD: 7 models — `EntradaNormativa`, `ResultadoNormativo`, `DadosNormativos`,
  `Violacao`, `FatoresCorrecao`, `LinhaAmpacidade`, `ParametrosQueda`.
- ADD: Contratos — `NormativeEngine`, `ISpecification<T>`, `IProcedure<I, O>`.
- ADD: Orquestradores — `NormativeService`, `SpecificationService`, `ProcedureService`.
- ADD: `pubspec.yaml` (Dart ≥3.0, zero dependências externas).
- ADD: `analysis_options.yaml` (`implementation_imports: error`).
- ADD: 81 testes unitários.
- ADD: `ARCHITECTURE.md` e 21 MDs normativos em `doc/nbr5410/`.
