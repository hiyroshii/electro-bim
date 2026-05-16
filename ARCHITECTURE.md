# ElectroBIM — Arquitetura do Monorepo
<!-- REV: 1 -->
<!-- CHANGELOG:
[Rev 1] - 15 05 2026
- ADD: documento criado para consolidar decisões arquiteturais do monorepo.
-->

> Data: 15 05 2026
> Estado: MVP residencial em progresso — normative_engine (Fase 3) + electrical_engine (v1.1.0)

---

## 1. Visão Geral

App Flutter de projetos elétricos chamado **ElectroBIM**.
Foco do MVP: dimensionamento de circuitos e cargas conforme **NBR 5410:2004**,
com motor canvas BIM como interface principal.

---

## 2. Estrutura de Packages

```
electrobim/
├── packages/
│   ├── normative_engine/     ✅ Dart puro — regras NBR 5410 como dados/specs/procs
│   ├── electrical_engine/    ✅ Dart puro — cálculos e dimensionamento por circuito
│   ├── canvas_engine/        ✅ Flutter  — motor gráfico BIM
│   │
│   ├── grounding_engine/     🔲 Dart puro — esquemas TN/TT/IT, PE, equipotencialização
│   ├── panel_engine/         🔲 Dart puro — quadro de distribuição (QD)
│   ├── motor_engine/         🔲 Dart puro — circuitos de motor (industrial)
│   └── report_engine/        🔲 Dart/Flutter — memorial descritivo + diagrama unifilar
│
├── apps/
│   └── flutter/              ✅ App Flutter integrador
│
└── documents/
    ├── context/              — contexto de design e roadmap por package
    ├── log/                  — changelog global e histórico de sprints
    └── nbr5410/              — extratos normativos por seção (referência)
```

---

## 3. Grafo de Dependências

```
normative_engine ←──────────────────────────────────────────┐
      ↑                                                       │
electrical_engine ←── grounding_engine                       │
      ↑                     ↑                                │
      └──────── panel_engine ┘                               │
                    ↑                                        │
              motor_engine ──────────────────────────────────┘
                                                             ↑
                                                      report_engine
                                                             ↑
                                                      apps/flutter
                                                      (+ canvas_engine)
```

**Regra de acamadas:** cada package só conhece seus dependentes diretos.
`panel_engine` não importa `electrical_engine` e `grounding_engine` ao mesmo tempo —
recebe seus outputs via modelos intermediários.

---

## 4. Descrição dos Packages

### Implementados

| Package | Responsabilidade | Depende de |
|---|---|---|
| `normative_engine` | Encapsula a NBR 5410:2004 — tabelas, specs, procs, classifications, verifications | — |
| `electrical_engine` | Dimensionamento de carga e circuito — seleciona condutor e disjuntor | `normative_engine` |
| `canvas_engine` | Motor gráfico BIM — geometria, viewport, ferramentas, snap | — |

### Planejados

| Package | Responsabilidade | Depende de | Camada |
|---|---|---|---|
| `grounding_engine` | Esquemas TN/TT/IT, condutor PE/PEN, BEP, equipotencialização | `normative_engine` | 2 |
| `panel_engine` | Composição física do QD: barramento, balanceamento de fases, grupos DR, DPS, seletividade, reserva | `electrical_engine`, `grounding_engine`, `normative_engine` | 2 |
| `motor_engine` | Corrente nominal e de partida, proteção de sobrecarga (relé térmico), proteção de curto-circuito, condutor de alimentação de motor | `normative_engine` | 1 |
| `report_engine` | Memorial descritivo, diagrama unifilar gerado | `panel_engine`, `electrical_engine` | 3 |

---

## 5. Critério: Package Separado vs Módulo Interno

| Critério | Package separado | Módulo interno |
|---|---|---|
| Vocabulário próprio (≠ circuito/carga) | ✅ | ❌ |
| Substituível por outra implementação | ✅ | ❌ |
| Reutilizável fora do ElectroBIM | ✅ | ❌ |
| Volume > ~10 arquivos | ✅ | ❌ |

### Módulos que ficam DENTRO do `electrical_engine`

| Módulo | Justificativa |
|---|---|
| `alimentador/` | Mesma matemática do circuito (Ib, Iz, ΔV) — apenas escala diferente |
| `curto_circuito/` | Cálculo elétrico puro, mesma família de `calculos/` |
| `eletroduto/` | Lookup em tabelas acoplado ao circuito |

### Packages separados justificados

| Package | Justificativa |
|---|---|
| `grounding_engine` | Vocabulário próprio (aterramento, malha, BEP), auditável isoladamente sem o engine de circuito |
| `panel_engine` | Vocabulário próprio (barramento, grupo DR, seletividade), opera sobre **conjuntos** de circuitos — não circuitos individuais |
| `motor_engine` | Vocabulário próprio (conjugado, escorregamento, categoria AC3/AC4, relé térmico), domínio distinto |
| `report_engine` | Saída/apresentação — princípio de separação domínio/UI |

---

## 6. Impacto por Escopo

### Núcleo invariante (nunca muda)

`calc_corrente_projeto`, `calc_queda_tensao`, `calc_ampacidade_cabo` — 100% agnósticos ao escopo.
O delta entre escopos está exclusivamente nas camadas de **entrada de carga** e **specs normativas**.

### Residencial (estado atual)

Implementado em `normative_engine` (Fase 3) + `electrical_engine` (v1.1.0).

### Comercial — delta moderado (sem package novo)

| O que muda | Onde |
|---|---|
| Modelo `ZonaUso` (área m² × tipo de uso) como alternativa a `Comodo` | `electrical_engine` |
| Specs de carga por VA/m², fator de demanda comercial, alimentação coletiva | `normative_engine` |
| Regras DR em tomadas até 32 A (5.1.3.2) | `normative_engine` |

### Industrial — um package novo

| O que muda | Onde |
|---|---|
| `motor_engine` (package): corrente nominal/partida, proteção, condutor de motor | package novo |
| `calc_protecao_motor` interno | `electrical_engine` |
| Tabelas FCT 40°C+, harmônicas VFD (Fh) | `normative_engine` |
| Esquema IT (continuidade de serviço) | `grounding_engine` |

---

## 7. Roadmap por Camadas

```
CAMADA 1 — Dimensionamento de elemento
  ├── normative_engine  🔄 Fase 3 em progresso (residencial ~60%)
  ├── electrical_engine ✅ v1.1.0 — carga + circuito residencial
  ├── alimentador       🔲 Sprint 5
  ├── curto_circuito    🔲 Sprint 6
  └── motor_engine      🔲 Sprint industrial

CAMADA 2 — Sistemas
  ├── grounding_engine  🔲 Sprint 7-8 (pré-requisito para panel)
  └── panel_engine      🔲 Sprint 9-11 (requer camada 1 estável)

CAMADA 3 — Documentação
  ├── memorial          🔲 Sprint 12
  └── unifilar          🔲 Sprint 13-14
```

**Restrição:** `panel_engine` não começa antes de `alimentador` e `curto_circuito`
estarem completos no `electrical_engine` — o QD depende desses dados.

---

## 8. Princípios Transversais

- **Dart puro** em todos os packages de domínio — Flutter só em `apps/flutter`, `canvas_engine` e `report_engine`
- **Imports absolutos** via `package:nome_engine/...` — sem imports relativos entre packages
- **`src/` privado** — nenhum package acessa `src/` de outro (`implementation_imports: error`)
- **Modelos imutáveis** — `final class`, campos `final`, `const` onde possível
- **Specs nunca lançam exceção** — acumulam violações, retornam lista vazia se conforme
- **Procedures assumem entrada válida** — a spec valida antes
- **Tabelas como `const Map` Dart** — sem JSON em runtime, type-safe, zero parsing
- **Changelogs dentro de cada package** — `packages/*/CHANGELOG.md` é a fonte autoritativa
- **Cobertura ≥ 90%** por arquivo de produção entregue

---

## 9. Convenção de Versionamento

```
Projeto global:  0.CICLO.SUBCICLO    (0.x = pré-MVP)
Packages:        SemVer estrito a partir de v1.0.0
```

---

## 10. Documentação por Package

| Documento | Localização | Propósito |
|---|---|---|
| Arquitetura do monorepo | `ARCHITECTURE.md` (este arquivo) | Estrutura global, dependências, critérios |
| Contexto do projeto | `documents/context/contexto_projeto_electrobim_revN.md` | Visão geral, decisões de design, estado atual |
| Contexto normative_engine | `documents/context/contexto_normative_engine_revN.md` | Detalhes internos, contratos, decisões |
| Contexto electrical_engine | `documents/context/contexto_electrical_engine_revN.md` | Algoritmos, fluxo, pendências |
| Roadmap normative_engine | `documents/context/roadmap_normative_engine_revN.md` | Fases v0.x → v1.0.0 |
| Manual normativo | `documents/context/manual_normativo_electrobim_rev1.md` | Catálogo D/T/C/P/S/V por fase |
| ARCHITECTURE por package | `packages/*/ARCHITECTURE.md` | Arquitetura interna, contratos, estrutura de pastas |
| CHANGELOG por package | `packages/*/CHANGELOG.md` | Histórico versionado — fonte autoritativa |
