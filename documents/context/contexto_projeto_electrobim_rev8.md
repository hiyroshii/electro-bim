# Contexto do Projeto ElectroBIM
<!-- REV: 8 -->
<!-- CHANGELOG:
[Rev 8] - 15 05 2026
- CHG: normative_engine atualizado para Fase 3.6 (363 testes, estrutura domain/).
- ADD: packages planejados: grounding_engine, panel_engine, motor_engine, report_engine.
- CHG: próximos passos atualizados — canvas snap concluído, foco em normative Fase 3 final.
- CHG: estrutura de packages no monorepo atualizada (domain/ substitui enums/).
- CHG: referências cruzadas atualizadas (ARCHITECTURE.md raiz criado).
[Rev 7] - 01 05 2026
- CHG: dimensionamento_engine renomeado para electrical_engine em todo o documento.
[Rev 6] - 01 05 2026
- MAJOR: Ciclo 3.5 concluído — monorepo com normative_engine + electrical_engine.
-->

> Data: 15 05 2026
> Versão do projeto: **0.4.x**
> Estado: normative_engine Fase 3.6 (363 testes) — electrical_engine v1.1.0
> **Próximo: normative_engine Fase 3 final (S-20, influências externas) ou canvas [1.4.0]**

---

## 1. Visão geral

App Flutter de projetos elétricos chamado **ElectroBIM**.
Foco do MVP: dimensionamento de circuitos e cargas conforme **NBR 5410**,
com motor canvas BIM como interface principal.

Pretensão comercial futura. Hoje em ritmo de hobby, sem prazo.

Conversa em **português**. Tom técnico, direto, sem floreios.

### Versão do projeto

| Componente | Versão | Estado |
|---|---|---|
| **Projeto global** | `0.4.x` | Pré-MVP, em desenvolvimento |
| `normative_engine` | Fase 3.6 | 363 testes — residencial ~60% |
| `electrical_engine` | `1.1.0` | Carga + circuito residencial |
| `canvas_engine` | `1.3.0` | Sprint 3 concluído |
| `apps/flutter` | — | Scaffold pendente |
| `grounding_engine` | — | 🔲 Planejado (Sprint 7-8) |
| `panel_engine` | — | 🔲 Planejado (Sprint 9-11) |
| `motor_engine` | — | 🔲 Planejado (industrial) |
| `report_engine` | — | 🔲 Planejado (Sprint 12-14) |

> Convenção de versão do projeto: `0.CICLO.SUBCICLO`
> `0.x` = pré-MVP | Minor = ciclo principal | Patch = subciclo ou hotfix

---

## 2. Monorepo — estrutura de packages

```
electrobim/                                      ← raiz do monorepo
├── ARCHITECTURE.md                              ← arquitetura global do monorepo
├── packages/
│   ├── normative_engine/                        ← Dart puro, sem Flutter
│   │   ├── ARCHITECTURE.md                      ← arquitetura interna do package
│   │   ├── CHANGELOG.md                         ← histórico versionado (fonte autoritativa)
│   │   ├── lib/
│   │   │   ├── normative_engine.dart            ← barrel (API pública)
│   │   │   └── src/
│   │   │       ├── contracts/
│   │   │       ├── domain/                      ← tipos do domínio (condutor, instalacao, locais…)
│   │   │       ├── models/
│   │   │       ├── tables/                      ← const Map (sem JSON)
│   │   │       ├── classification/              ← IClassification
│   │   │       ├── specification/               ← ISpecification
│   │   │       ├── procedure/                   ← IProcedure
│   │   │       └── orchestrator/
│   │   └── test/
│   │
│   ├── electrical_engine/                  ← Dart puro, sem Flutter
│   │   ├── pubspec.yaml                         ← name: electrical_engine
│   │   │                                           depende de normative_engine
│   │   ├── lib/
│   │   │   ├── electrical_engine.dart      ← barrel (API pública)
│   │   │   └── src/
│   │   │       ├── calculos/
│   │   │       ├── models/
│   │   │       │   ├── carga/
│   │   │       │   └── circuito/
│   │   │       └── orchestrator/
│   │   │           ├── carga/
│   │   │           └── circuito/
│   │   └── test/
│   │
│   ├── canvas_engine/                           ← Flutter, motor gráfico
│   │   └── lib/src/                            ← domain/, engine/, viewport/, render/,
│   │                                              controllers/, services/snap/
│   │
│   ├── grounding_engine/                       ← 🔲 Dart puro (Sprint 7-8)
│   ├── panel_engine/                           ← 🔲 Dart puro (Sprint 9-11)
│   ├── motor_engine/                           ← 🔲 Dart puro (industrial)
│   └── report_engine/                          ← 🔲 Dart/Flutter (Sprint 12-14)
│
├── apps/
│   └── flutter/                                 ← app Flutter integrador
│       ├── pubspec.yaml
│       └── lib/
│
└── documents/
    ├── context/                                 ← contexto de design por package
    ├── log/                                     ← changelog global + sprints
    └── nbr5410/                                 ← extratos normativos por seção
```

---

## 3. Dependências entre packages

```
canvas_engine              ← sem dependências externas
normative_engine           ← sem dependências externas (Dart puro)
electrical_engine     ← depende de normative_engine
apps/flutter               ← depende dos três packages
```

`apps/flutter/pubspec.yaml`:
```yaml
dependencies:
  normative_engine:
    path: ../../packages/normative_engine
  electrical_engine:
    path: ../../packages/electrical_engine
  canvas_engine:
    path: ../../packages/canvas_engine
```

---

## 4. Princípios arquiteturais

### Vocabulário do projeto

| Termo | Definição |
|---|---|
| **Engine** | Package completo — domínio, regras, dados, contratos |
| **Service** | Orquestrador executável que implementa o contrato do Engine |
| **Specification** | Norma de especificação — define conformidade (o que deve ser) |
| **Procedure** | Norma de procedimento — define como calcular (tabelas, fórmulas) |
| **Barrel** | Arquivo raiz `lib/nome_engine.dart` — só exports, sem lógica |

### Regras transversais

- Dart puro nos packages de domínio — Flutter só em `apps/flutter` e `canvas_engine`
- Imports absolutos via `package:nome_engine/...`
- Nada acessa `src/` diretamente de fora do package (`implementation_imports: error`)
- `src/` = implementação privada | barrel = API pública
- Modelos imutáveis: `final class`, campos `final`, `const` onde possível
- Service delega — não contém lógica normativa nem cálculo
- Calc calcula — não conhece norma nem contexto de negócio
- Spec verifica — retorna `List<Violacao>`, nunca lança exceção
- Dados normativos como `const Map` Dart (sem JSON em runtime)
- Um arquivo por tabela normativa em `tables/`
- Changelog em cabeçalho de cada arquivo: `// REV: x.y.z`

### canvas_engine

- Zero dependência de Flutter no `domain/`
- Flutter entra apenas em adapters (`FlutterRenderAdapter`)
- Geometria como funções top-level — não OOP
- Tudo nasce em WORLD — view é projeção
- Canvas não tem lógica — apenas renderiza o que o engine manda
- Ferramentas em arquivos separados, implementando interface `Tool`

---

## 5. Domínio elétrico — regras normativas consolidadas

### Queda de tensão (NBR 5410 — 6.2.7)

| Circuito | Origem | Limite | Total |
|---|---|---|---|
| Terminal (TUG, TUE, IL) | qualquer | **4%** | — |
| Alimentador (MED, QDG, QD) | Concessionária | **1%** | 5% |
| Alimentador (MED, QDG, QD) | Trafo/Gerador próprio | **3%** | 7% |

### Combinações válidas Isolação × Arquitetura (NBR 5410 — 6.2.3)

| Isolação | Isolado | Unipolar | Multipolar |
|---|---|---|---|
| PVC | ✅ | ✅ | ✅ |
| XLPE | ❌ | ✅ | ✅ |
| EPR | ❌ | ✅ | ✅ |

### Combinações válidas Arquitetura × Método (NBR 5410 — Tab. 33)

| Método | Isolado | Unipolar | Multipolar |
|---|---|---|---|
| A1 | ✅ | ✅ | ✅* |
| A2 | ❌ | ❌ | ✅ |
| B1 | ✅ | ✅ | ✅* |
| B2 | ✅* | ✅* | ✅ |
| C | ❌ | ✅ | ✅ |
| D | ❌ | ✅ | ✅ |
| E | ❌ | ❌ | ✅ |
| F | ❌ | ✅ | ❌ |
| G | ✅ | ✅ | ❌ |

*Exceções documentadas na Tab. 33 (métodos físicos 51, 43, 26, 23/25/27).

### Alumínio (NBR 5410 — 6.2.3.8)

- BD4: **proibido** absolutamente
- Industrial: seção ≥ 16 mm², fonte AT/própria, BA5
- Comercial BD1: seção ≥ 50 mm², BA5

---

## 6. Domínio — canvas_engine [1.3.0]

```
Tolerance          constantes nomeadas por contexto
Vector2            posição/direção; imutável; ==, hashCode, cross, normalize
Segment            dois Vector2; == não-direcional; isDegenerate
AABB               bounding box; fromPoints, intersects, expand, union

distancePointToSegment()   distância mínima ponto→segmento
closestPointOnSegment()    ponto mais próximo no segmento
isPointOnSegment()         hit test com tolerância
intersectSegments()        fórmula de Gavin; IntersectionResult tipado
projectPointOntoSegment()  projeção clampada [0,1]
projectPointOntoLine()     projeção em linha infinita
```

### Sistema de coordenadas

- **WORLD**: coordenadas absolutas do projeto
- **SCREEN**: pixels de tela
- **Conversão**: `viewport.worldToScreen()` / `viewport.screenToWorld()`
- Hit test: sempre em WORLD com `Tolerance.hitTestWorld(viewport.scale)`

---

## 7. Decisões de design registradas

**Projeto:**

[DECISION] Monorepo com `packages/` e `apps/` como estrutura definitiva.
Packages publicáveis no pub.dev independentemente.

[DECISION] `electrical_engine` descontinuado no Ciclo 3.5. Lógica migrada para
`normative_engine` (regras NBR) e `electrical_engine` (algoritmos).

[DECISION] Tabelas normativas como `const Map` Dart — não JSON em runtime.
Type-safe, sem parsing, funciona em Dart puro.

[DECISION] `OrigemAlimentacao` relevante para limites de alimentadores:
entrega = 1%, próprio = 3%. Terminal sempre 4%.

[DECISION] Catálogo de disjuntores é asset do `apps/flutter` — dado de produto,
não regra normativa. `electrical_engine` recebe a lista injetada.

[DECISION] `secaoNeutro` real (via `spec_neutro` + política) é TODO do ciclo 4.1.
Atualmente `RelatorioDimensionamento.toResultadoNormativo()` usa `secaoFase` como proxy.

[DECISION] Automação residencial entra no Ciclo 11+ (ano 2-3 do projeto).
Hooks preservados: campo `controlavel` planejado em `PontoCarga`.

**canvas_engine:**

[DECISION] Packages separados: normative_engine e electrical_engine (Dart puro),
canvas_engine (Flutter), apps/flutter.

[DECISION] CanvasMode enum para separar gesto de desenho vs navegação.

[DECISION] Tool como interface — ferramentas em arquivos separados.
`setTool()` chama `reset()` automaticamente.

[DECISION] Geometria como funções top-level (distance, intersection, projection).
Matemática pura é mais testável como funções soltas.

[DECISION] IntersectionResult tipado com IntersectionType enum.
Evita null como sinalização de falha.

---

## 8. Estado atual dos packages

### normative_engine — Fase 3.6

```
lib/src/
  contracts/                     ← NormativeEngine, ISpecification, IProcedure,
                                    IClassification, IVerification
  domain/                        ← condutor/, instalacao/, influencias/, locais/
                                    (PerfilInstalacao, CodigoInfluencia, TipoComodo,
                                     VolumeBanheiro — sem ContextoInstalacao)
  models/                        ← 7 value objects + Violacao (16 factories)
  tables/                        ← 11 arquivos const Map + habitacao/ (T-13, T-14)
  classification/                ← ClassCompetenciaBa, ClassFugaEmergenciaBd,
                                    ClassPerfilPadraoPorEscopo
  specification/
    condutor/                    ← S-1 combinacoes, S-2 aluminio, S-4 secao_minima, neutro
    protecao/                    ← S-3 sobrecarga, S-6 multipolar, S-8 dr_obrigatorio
    instalacao/                  ← S-5 queda_tensao
    carga/                       ← S-9..S-11 circuitos, S-12 minimo_il, S-13 minimo_tug
    locais_especificos/          ← S-15 banheiro (V0/V1/V2/V3, BANH_001..004)
  procedure/
    condutor/                    ← P-1 ampacidade, P-3 secao_neutro
    tensao/                      ← P-2 queda_tensao
    carga/                       ← P-6 carga_residencial
  orchestrator/                  ← NormativeService, ClassificationService,
                                    SpecificationService, ProcedureService,
                                    VerificationService (skeleton)

test/                            ← 363 testes
ARCHITECTURE.md                  ← arquitetura interna detalhada
```

### electrical_engine — v1.0.x

```
lib/src/
  calculos/
    calc_corrente_projeto.dart   ← implementado
    calc_ampacidade_cabo.dart    ← implementado
    calc_queda_tensao.dart       ← implementado (com reatância + cosφ)
  models/
    carga/
      comodo, entrada_carga, relatorio_carga
    circuito/
      entrada_dimensionamento, contexto_selecao,
      resultado_selecao, relatorio_dimensionamento
  orchestrator/
    carga/
      gerador_pontos_comodo      ← implementado
      validador_comodo           ← implementado
      agregador_circuitos        ← implementado
      dimensionamento_carga_service ← implementado
    circuito/
      politica_disjuntor         ← implementado
      selecionador_condutor      ← implementado
      dimensionamento_circuito_service ← implementado
    dimensionamento_service.dart ← orquestrador mestre, implementado
    electrical_engine.dart  ← contrato público

test/                            ← 79 testes
```

### canvas_engine — v1.3.0

```
lib/
  domain/geometry/               ← primitivos + operações (v1.0.0)
  domain/value_objects/          ← Vector2 (v1.1.0)
  domain/entities/               ← Shape, LineShape (v1.1.0)
  engine/                        ← CanvasEngine, Scene (v1.0.0)
  viewport/                      ← Viewport (v1.0.0)
  render/                        ← adapters (v1.0.0)
  controllers/                   ← InputController v2.0.0, DrawLine v1.1.0
  services/snap/                 ← stub (v1.0.0)

test/domain/geometry/            ← 30 testes
```

---

## 9. Google Drive — IDs das pastas

| Pasta | ID |
|---|---|
| Projeto ElectroBIM (raiz) | `1gQQzbuPOtVVfLMkA2jK7knDQ4eePboCp` |
| `packages/electrical_engine/` | `1rI0HIDWzqwR-14ej5YAqBpklCCmklA4y` |
| `packages/canvas_engine/` | `1pHB5mrcoToHezKuAPPN21db4nUXP-XVI` |
| `apps/app_flutter/` | `17qgUayYVz9lCSaZ2tZg5ULFC71UdNXiq` |
| `log/` | `1Z70y6y4oz0oVJB892gTq3NpsLKSDw38y` |

> normative_engine e electrical_engine: IDs a registrar após upload ao Drive.

---

## 10. Próximos passos

### normative_engine — Fase 3 final

1. Candidatos imediatos: `SpecSecaoPE` (S-20) + `ProcSecaoPE` (P-4), classificações de
   influências externas (AA, AD, BB, BC, BE, CA, CB)
2. S-7 (seccionamento automático) e S-16 (DPS) — aguardam `grounding_engine`
3. S-21/S-22 (equipotencialização) — aguardam `grounding_engine`

### electrical_engine — bugs conhecidos

- **C1** `selecionador_condutor.dart:48` — `xi ?? 0.0` subestima queda em cabos ≥ 35mm²
- **C2** — constantes normativas hardcoded devem migrar para `normative_engine`

### packages novos (camadas)

4. **Camada 1:** `alimentador/` e `curto_circuito/` dentro do `electrical_engine`
5. **Camada 2:** `grounding_engine` (pré-requisito para panel) → `panel_engine`
6. **Camada 3:** `report_engine`

### canvas_engine

7. **[1.4.0]** — Sistema de Snap real (geometria [1.3.0] como base)

### Pendências técnicas

- [ ] Registrar IDs das novas pastas no Drive (seção 9)
- [ ] Corrigir C1 — `xi ?? 0.0` em `selecionador_condutor.dart`
- [ ] Catálogo de disjuntores comerciais como asset em `apps/flutter`
- [ ] Definir estrutura do `apps/flutter` (state management, navegação)
