# ElectroBIM — Análise do Package `electrical_engine`
<!-- REV: 1 -->
<!-- CHANGELOG:
[Rev 1] - 13 05 2026
- ADD: Análise inicial do package electrical_engine v1.0.x cruzada com:
  - contexto_projeto_electrobim_rev8.md (princípios arquiteturais do monorepo)
  - regras_nbr5410_classificadas_rev1.md (delimitação de escopo normative ↔ electrical)
- Critério de severidade: 🔴 Crítico → 🟡 Médio → 🔵 Baixo → 🟢 Observação
-->

> **Data:** 13 05 2026
> **Base do projeto:** ElectroBIM v0.3.5 — contexto rev7
> **Package analisado:** `electrical_engine` v1.0.x
> **Arquivos:** 18 `.dart` em 3 camadas (`models`, `calculos`, `orchestrator`)
> **Cobertura de testes (declarada):** 79 testes

---

## 1. Visão Geral

### 1.1 Arquitetura inspecionada

```
electrical_engine/lib/
├── electrical_engine.dart          ← barrel (contrato público)
└── src/
    ├── calculos/                   ← matemática pura (sem conhecimento de norma)
    │   ├── calc_corrente_projeto.dart      Ib = P / (k · V · FP)
    │   ├── calc_ampacidade_cabo.dart       Iz = Iz_base · FCT · FCA · Fh
    │   ├── calc_queda_tensao.dart          ΔV% = k · Ib · L · (R·cosφ + X·senφ) / V
    │   └── calc_potencia_tue.dart          VA = W / FP
    │
    ├── models/                     ← POJOs imutáveis (final/const)
    │   ├── carga/                  Comodo, EntradaCarga, RelatorioCarga
    │   └── circuito/               EntradaDimensionamento, ContextoSelecao,
    │                               ResultadoSelecao, RelatorioDimensionamento
    │
    └── orchestrator/               ← services com dependências injetadas
        ├── dimensionamento_engine.dart       ← interface pública
        ├── dimensionamento_service.dart      ← entry point único do app
        ├── carga/
        │   ├── dimensionamento_carga_service.dart
        │   ├── gerador_pontos_comodo.dart
        │   ├── validador_comodo.dart
        │   └── agregador_circuitos.dart
        └── circuito/
            ├── dimensionamento_circuito_service.dart
            ├── selecionador_condutor.dart
            └── politica_disjuntor.dart
```

### 1.2 Fluxo de dimensionamento de circuito

```
EntradaDimensionamento
        │
        ▼
[1] NormativeEngine.verificarConformidade()      ← pré-validação (lança Exception)
        │
        ▼
[2] CalcCorrenteProjeto.calcular()               ← Ib
        │
        ▼
[3] NormativeEngine.resolverDadosNormativos()    ← FCT, FCA, tabelaIz, tabelaXi, secaoMinima, limiteQueda
        │
        ▼
[4] PoliticaDisjuntor.selecionar(ib, catalogo)   ← In (StateError → status reprovadoDisjuntor)
        │
        ▼
[5] SelecionadorCondutor.selecionar(ContextoSelecao)   ← itera Iz × queda → seção
        │
        ▼
[6] NormativeEngine.calcularSecaoNeutro()        ← Ciclo 4.1
        │
        ▼
RelatorioDimensionamento (status + traceability)
```

---

## 2. Aderência aos Princípios do Projeto

Cruzamento com `contexto_projeto_electrobim_rev8.md` § 4 "Princípios arquiteturais":

| Princípio | Estado | Evidência |
|---|---|---|
| Dart puro, zero Flutter | ✅ | `pubspec.yaml`: deps são `normative_engine`, `uuid`, `test`, `lints` |
| Service orquestra, nunca calcula | ✅ | Services delegam para classes em `calculos/` |
| Modelos imutáveis (`final`, `const`, factories) | ✅ | Todos os modelos seguem o padrão |
| Sem exceção como fluxo de controle | ⚠️ Parcial | OK para falhas de dimensionamento (status no resultado); **mas** `EntradaInvalidaException` para violação normativa pré-cálculo é defensável |
| Política normativa no core | ⚠️ Vazamento | Ver § 4 — constantes normativas hardcoded em 3 arquivos |
| Imports absolutos `package:electrical_engine/...` | ❌ | Imports internos são relativos (`'../models/...'`) |
| Repositório como fonte única | ✅ | `normative_engine` é a única fonte de regras/tabelas |
| Barrel só com exports | ✅ | `electrical_engine.dart` sem lógica |

---

## 3. Pontos Fortes

1. **Contrato público bem desenhado** — `DimensionamentoEngine` (interface abstrata) é o único símbolo que o app precisa importar. Implementação concreta (`DimensionamentoService`) instancia internamente os serviços de carga e circuito.

2. **Separação produto vs norma bem feita** — Catálogo de disjuntores injetado pelo app (`List<Disjuntor>`), não pelo `normative_engine`. Reflete a distinção correta: produtos comerciais (catálogo) ≠ regras normativas (tabelas).

3. **Status como retorno em vez de exceção propagada** — `dimensionamento_circuito_service.dart` captura `StateError` da política de disjuntor e retorna `RelatorioDimensionamento` com `status: reprovadoDisjuntor`. Falhas de dimensionamento viram dados, não fluxo de controle.

4. **Rastreabilidade NBR em comentários** — Todo arquivo crítico tem `// Rastreabilidade: NBR 5410:2004 — X.Y.Z`. Facilita auditoria.

5. **`ContextoSelecao` como Parameter Object** — Em vez de passar 15+ argumentos para o `SelecionadorCondutor`, um único objeto consolidado. Aderente ao princípio.

6. **Migração `tabelaXi` para Map dinâmico** (Rev 1.1.0 de `contexto_selecao.dart`) — Substituiu reatância fixa por lookup por seção. Correção técnica importante já incorporada.

7. **Cálculo de queda de tensão completo** — `calc_queda_tensao.dart` inclui componente reativa (`X·senφ`), não apenas resistiva. Aderente a NBR 6.2.7.4.

8. **Changelogs versionados por arquivo** — Cada `.dart` mantém `// CHANGELOG:` no topo. Facilita revisão histórica.

---

## 4. Achados — Por Severidade

### 🔴 4.1 Crítico

#### **C1. Fallback silencioso na tabela de reatância**
**Arquivo:** `orchestrator/circuito/selecionador_condutor.dart:48`

```dart
final xi = ctx.tabelaXi[linha.secao] ?? 0.0;
```

**Problema:** Se a seção não estiver na `tabelaXi`, o cálculo prossegue com reatância zero. Para cabos grandes (≥ 35 mm²) e cargas com cosφ baixo, isso **subestima a queda de tensão**, podendo aprovar circuitos que reprovariam com dados completos.

**Impacto:** Resultado de dimensionamento incorreto sem qualquer aviso ao usuário.

**Correção sugerida:**
- Opção A (estrita): lançar `StateError` → status `dadosNormativosIncompletos`.
- Opção B (defensiva): emitir warning no relatório + usar valor conservador (Xi do maior cabo conhecido).
- Opção C (preventiva): `normative_engine.resolverDadosNormativos()` garante que toda `linha.secao` de `tabelaIz` tem entrada correspondente em `tabelaXi`.

---

#### **C2. Vazamento de regras normativas para o `electrical_engine`**

Três arquivos contêm **constantes normativas hardcoded**, violando o princípio "regras NBR vivem no normative_engine":

| Arquivo | Constante | Origem normativa | Severidade |
|---|---|---|---|
| `gerador_pontos_comodo.dart` | `_potenciaTugVa = 100.0` | NBR 9.5.2.2.1 (varia por tipo de cômodo) | 🔴 |
| `gerador_pontos_comodo.dart` | `_potenciaIlVa = 100.0` | NBR 9.5.2.1.2 (varia por área) | 🔴 |
| `validador_comodo.dart` | `_tugMinPorPerimetro = 5.0` | NBR 9.5.2.2.1 (3,5 m para áreas molhadas) | 🟡 |
| `validador_comodo.dart` | `_tugMinimoFixo = 2`, `_ilMinimo = 1` | NBR 9.5.2.2.1.a | 🟡 |
| `agregador_circuitos.dart` | `_maxVaTug = 1500.0`, `_maxVaIl = 600.0` | Convenção sobre 9.5.4 | 🟡 |

**Diagnóstico arquitetural:** Esses valores são **regras de especificação NBR**, não números mágicos do electrical. Deveriam estar em `normative_engine/src/specification/spec_pontos_minimos.dart` (ou similar) e serem consultados pelo electrical via contrato.

**Impacto duplo:**
- **Arquitetural:** Quebra do contrato "uma fonte única de norma".
- **Normativo:** Os valores estão **simplificados** ou **incompletos** em relação à NBR 5410 Seção 9 (ver § 5).

**Correção sugerida (refactor):**
```
normative_engine → adicionar:
  - spec_pontos_minimos_il.dart    (potência IL por área)
  - spec_pontos_minimos_tug.dart   (potência TUG por tipo cômodo)
  - spec_circuitos_terminais.dart  (limites VA por tipo de circuito)

electrical_engine → consumir:
  - gerador_pontos_comodo recebe SpecPontosMinimos via construtor
  - validador_comodo recebe SpecValidacaoComodo
  - agregador_circuitos recebe SpecLimitesCircuito
```

---

### 🟡 4.2 Médio

#### **M1. Catálogo de disjuntores assumido ordenado**
**Arquivo:** `orchestrator/circuito/politica_disjuntor.dart`

```dart
final disjuntor = catalogo.firstWhere((d) => d.in_ >= ib, orElse: ...);
```

`firstWhere` em lista não ordenada retorna o primeiro encontrado, **não o menor que satisfaz** Ib ≤ In. A NBR 5410 6.3.3 exige In mínimo (menor disjuntor que satisfaz).

**Correção sugerida:**
- Documentar contrato (catálogo ordenado crescente) e adicionar `assert` em modo debug;
- ou ordenar internamente: `catalogo.sortedBy((d) => d.in_).firstWhere(...)`.

---

#### **M2. Fator de demanda ausente no `dimensionamento_carga_service`**
**Arquivo:** `orchestrator/carga/dimensionamento_carga_service.dart:73`

```dart
// 3. VA total do projeto
final vaTotal = previsoes.fold(0.0, (s, p) => s + p.vaTotalComodo);
```

Comentado no service: "soma simples, sem fator de demanda". A NBR 5410 6.1.5.1 + Tabela 8 estabelece fatores de demanda por tipo de uso (TUG, IL, TUE) para o dimensionamento do alimentador geral.

**Status:** Não é defeito de implementação atual, mas **gap explícito** para o cálculo do alimentador (QDG/entrada). Roadmap: G3-G4 da classificação NBR rev1.

**Recomendação:** Marcar como `// TODO(ciclo-futuro)` referenciando a seção 6.1.5.

---

#### **M3. Factory `Comodo.criar` é redundante**
**Arquivo:** `models/carga/comodo.dart`

```dart
factory Comodo.criar({...}) => Comodo(...);  // só repassa, sem lógica
```

A factory apenas repassa argumentos ao construtor `const`, sem lógica adicional. O `DimensionamentoCargaService` a usa para criar cômodos com `id` gerado por UUID — mas a geração de UUID acontece no service, não na factory.

**Correção sugerida:** Remover a factory ou mover a geração de ID para dentro dela:
```dart
factory Comodo.criar({...required Uuid uuid, ...}) => Comodo(id: uuid.v4(), ...);
```

---

### 🔵 4.3 Baixo

#### **B1. Imports relativos em vez de absolutos**
Princípio rev7: "imports absolutos `package:electrical_engine/...`". Os imports internos são `'../models/...'`.

**Impacto:** Estilístico/refactor. Dart aceita ambos.

---

#### **B2. README é placeholder do Dart create**
`README.md` tem o conteúdo padrão do `dart create` (TODOs do Dart team). Não documenta o contrato `DimensionamentoEngine` nem o fluxo.

---

#### **B3. CHANGELOG.md do package separado dos changelogs por arquivo**
O `CHANGELOG.md` na raiz está em `## 0.0.1` (template), enquanto cada arquivo tem changelogs internos com versões reais (`[1.2.0]`, `[1.1.0]` etc).

**Recomendação:** Consolidar versões em `packages/electrical_engine/CHANGELOG.md` como fonte autoritativa.

---

#### **B4. Múltiplos enums de status com semântica próxima**

Existem quatro enums de status próximos:
- `StatusCircuito` (aprovado/reprovado) → agregação por circuito
- `StatusPrevisao` (aprovado/reprovadoNorma) → validação de cômodo
- `StatusRelatorio` (ok/reprovado) → status global
- `StatusDimensionamento` (aprovado, reprovadoDisjuntor, reprovadoAmpacidade, reprovadoQueda) → seleção de condutor

Não há erro, mas a sobreposição semântica gera carga cognitiva. **Sugestão:** unificar nomes ou documentar a diferença numa convenção.

---

### 🟢 4.4 Observações

#### **O1. `RegraTomadasComodo.custom`** está implementada como "usuário define, sem validação". Coerente com o vocabulário do projeto (usuário-tipo: engenheiro que pode pular regras normativas). OK.

#### **O2. `dimensionamento_engine.dart` (contrato)** concentra 4 métodos:
- `criarComodoComSugestoes`
- `criarComodoCustom`
- `processarCarga`
- `dimensionarCircuito`

Não é falha — é entry point único intencional para o app. Mas se o app crescer, separar em `EngineCarga` e `EngineCircuito` daria coesão maior.

---

## 5. Cruzamento com a Classificação NBR rev1

| Seção NBR | Onde mora | Status no electrical_engine |
|---|---|---|
| **6.1.3.1.2** — Corrente de projeto (Ib) | `electrical/calculos/calc_corrente_projeto.dart` | ✅ Correto |
| **6.2.5** — Capacidade de condução (Iz) | `normative` (tabelas + FCT/FCA) + `electrical` (cálculo) | ✅ Correto |
| **6.2.7** — Queda de tensão (ΔV%) | `normative` (limites por tipo) + `electrical` (cálculo) | ✅ Correto |
| **6.3.3** — Coordenação Ib ≤ In ≤ Iz | Distribuído entre `politica_disjuntor` e `selecionador_condutor` | ⚠️ Sem verificação central |
| **6.2.6** — Seção do neutro | Delegado ao `normative_engine` | ✅ Ciclo 4.1 |
| **6.2.3 / Tab. 33** — Combinações isolação×método | `normative_engine/spec_combinacoes` | ✅ G1 |
| **6.2.3.8** — Restrições ao alumínio | `normative_engine/spec_aluminio` | ✅ G1 |
| **5.3.4** — Proteção sobrecarga | Via `politica_disjuntor` + `spec_secao_minima` | ✅ G1 |
| **9.1.2.2** — Pontos mínimos por cômodo | ❌ Hardcoded em `electrical` (deveria ser `normative`) | 🔴 C2 |
| **9.5.2.1.2** — IL por área | ❌ Hardcoded em `electrical` (100 VA fixo) | 🔴 C2 |
| **9.5.2.2.1** — TUG por tipo cômodo | ❌ Hardcoded em `electrical` (100 VA fixo) | 🔴 C2 |
| **9.5.4** — Separação de circuitos | Implícito via `TagCircuito` (TUG/IL/TUE) | ⚠️ Sem regra explícita |
| **5.1.3.2** — DR ≤ 30 mA | Não implementado | ⏳ G3 (Ciclo 4.x) |
| **6.1.5 / Tab. 8** — Fator de demanda | Não implementado | ⏳ G3 |

**Observação chave:** O electrical_engine cumpre seu papel para **dimensionamento de circuito** (cálculos puros + orquestração). O gap está em **dimensionamento de cargas/cômodos**, onde regras normativas vazaram para fora do `normative_engine`.

---

## 6. Recomendações Priorizadas

### 6.1 Curto prazo (Ciclo 4.1 — em andamento)

1. **[C1] Fechar fallback silencioso de Xi** em `selecionador_condutor.dart`.
   Esforço: ~1h. Risco se não fizer: alto (cálculo silenciosamente errado).

2. **[M1] Documentar/garantir ordenação do catálogo de disjuntores** em `politica_disjuntor.dart`.
   Esforço: ~30 min. Risco se não fizer: médio (depende do app passar lista ordenada).

3. **[C2 — fase 1] Mover constantes de `agregador_circuitos.dart` para o `normative_engine`** (`spec_limites_circuito.dart`).
   Esforço: ~2h. Inclui criação de spec, refactor do agregador, atualização de testes.

### 6.2 Médio prazo (Ciclo 4.2–4.3)

4. **[C2 — fase 2] Mover regras de pontos mínimos (TUG/IL) para o `normative_engine`** + adicionar variação por tipo de cômodo.
   Esforço: ~4-6h. Inclui:
   - `spec_pontos_minimos_tug.dart` (cozinha/copa/lavanderia: 3,5 m, 600 VA primeiras 3)
   - `spec_pontos_minimos_il.dart` (100 VA até 6 m² + 60 VA cada 4 m² adicionais)
   - Refactor de `gerador_pontos_comodo` e `validador_comodo` para consumir specs

5. **[M3] Simplificar/remover factory redundante** `Comodo.criar`.
   Esforço: ~30 min.

6. **[B1] Padronizar imports absolutos** em todo o package.
   Esforço: ~1h (linter + sed).

### 6.3 Longo prazo (Ciclo 5.x+)

7. **[M2] Implementar fator de demanda** (NBR 6.1.5 + Tabela 8) para o dimensionamento do alimentador. Mapeado em G3 da classificação NBR.

8. **[B2/B3] Documentação do package**: README real + CHANGELOG.md consolidado.

9. Avaliar separação do contrato `DimensionamentoEngine` em `EngineCarga` + `EngineCircuito` se o app crescer.

---

## 7. Síntese

O `electrical_engine` está **bem estruturado nos cálculos e na orquestração de circuito**, com excelente separação de responsabilidades (cálculos puros, modelos imutáveis, status como retorno). A camada de **dimensionamento de carga (cômodos)**, porém, tem **vazamento sistemático de regras normativas** que deveriam viver no `normative_engine` — esse é o principal débito arquitetural identificado.

Há um **bug crítico de cálculo** (fallback silencioso de Xi) que merece correção imediata, dado que produz resultados incorretos sem aviso.

A aderência aos princípios do projeto é **alta** em quase todos os eixos, com exceção do princípio "política normativa vive no core" (§ 4.2 da rev7), que é violado nos três arquivos identificados em C2.

---

## Referências Internas

- `contexto_projeto_electrobim_rev8.md` — Estado atual do projeto
- `regras_nbr5410_classificadas_rev1.md` — Classificação das regras NBR
- `packages/electrical_engine/CHANGELOG.md` — histórico do package
- `ABNT NBR 5410:2004` — Versão corrigida 17.03.2008
