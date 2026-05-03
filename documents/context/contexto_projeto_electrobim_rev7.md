# Contexto do Projeto ElectroBIM
<!-- REV: 7 -->
<!-- CHANGELOG:
[Rev 7] - 01 05 2026
- CHG: dimensionamento_engine renomeado para electrical_engine em todo o documento.
[Rev 6] - 01 05 2026
- MAJOR: Ciclo 3.5 concluído — electrical_engine substituído por monorepo com
  normative_engine + electrical_engine. Arquitetura de packages redefinida.
- ADD: normative_engine (Dart puro) — encapsula NBR 5410 completo.
- ADD: electrical_engine (Dart puro) — algoritmos de carga e circuito.
- CHG: electrical_engine descontinuado — lógica migrada e expandida nos novos packages.
- CHG: monorepo com packages/ e apps/ como estrutura definitiva.
- CHG: limites de queda de tensão corrigidos — alimentador 1% (entrega) / 3% (próprio),
  terminal 4%, total 5% / 7%.
- ADD: 95 testes no normative_engine, 79 testes no electrical_engine.
[Rev 5] - 29 04 2026
- Sprint 3 do canvas_engine concluído — geometria base [1.3.0].
-->

> Data: 01 05 2026
> Versão do projeto: **0.3.5**
> Estado: Ciclo 3.5 concluído — normative_engine e electrical_engine implementados.
> **Próximo: canvas_engine [1.4.0] Sistema de Snap real.**

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
| **Projeto global** | `0.3.5` | Pré-MVP, em desenvolvimento |
| `normative_engine` | `1.0.x` | Implementado, em revisão |
| `electrical_engine` | `1.0.x` | Implementado, em revisão |
| `canvas_engine` | `1.3.0` | Sprint 3 concluído |
| `apps/flutter` | — | Scaffold pendente |

> Convenção de versão do projeto: `0.CICLO.SUBCICLO`
> `0.x` = pré-MVP | Minor = ciclo principal | Patch = subciclo ou hotfix

---

## 2. Monorepo — estrutura de packages

```
electrobim/                                      ← raiz do monorepo
├── packages/
│   ├── normative_engine/                        ← Dart puro, sem Flutter
│   │   ├── pubspec.yaml                         ← name: normative_engine
│   │   ├── lib/
│   │   │   ├── normative_engine.dart            ← barrel (API pública)
│   │   │   └── src/
│   │   │       ├── contracts/
│   │   │       ├── enums/
│   │   │       ├── models/
│   │   │       ├── tables/                      ← const Map (sem JSON)
│   │   │       ├── specification/               ← Normas de Especificação
│   │   │       ├── procedure/                   ← Normas de Procedimento
│   │   │       └── orchestrator/
│   │   ├── test/
│   │   └── doc/
│   │       ├── ARCHITECTURE.md
│   │       └── nbr5410/                         ← MDs normativos de referência
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
│   └── canvas_engine/                           ← Flutter, motor gráfico
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── canvas_engine.dart               ← barrel v1.3.0
│       │   ├── domain/
│       │   │   ├── value_objects/
│       │   │   ├── entities/
│       │   │   └── geometry/
│       │   ├── engine/
│       │   ├── viewport/
│       │   ├── render/
│       │   ├── controllers/
│       │   ├── models/
│       │   └── services/snap/                   ← stub, próximo [1.4.0]
│       └── test/
│           └── domain/geometry/
│               └── geometry_test.dart           ← 30 testes
│
├── apps/
│   └── flutter/                                 ← app Flutter integrador
│       ├── pubspec.yaml
│       └── lib/
│
└── docs/
    ├── changelog_global_rev1.md
    ├── changelog_normative_engine_rev1.md
    └── changelog_electrical_engine_rev1.md
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

### normative_engine — v1.0.x

```
lib/src/
  contracts/
    normative_engine.dart        ← interface NormativeEngine
    i_specification.dart
    i_procedure.dart
  enums/                         ← 10 enums
    isolacao, arquitetura, metodo_instalacao, arranjo_condutores,
    material, tag_circuito, tensao, numero_fases,
    contexto_instalacao, origem_alimentacao
  models/                        ← 7 value objects
    entrada_normativa, resultado_normativo, dados_normativos,
    violacao, fatores_correcao, linha_ampacidade, parametros_queda
  tables/                        ← 9 arquivos, const Map Dart
    tabela_35 a tabela_48 (NBR 5410)
  specification/                 ← 5 specs
    spec_combinacoes, spec_aluminio, spec_secao_minima,
    spec_neutro, spec_queda_tensao
  procedure/                     ← 2 procedures
    proc_ampacidade, proc_queda_tensao
  orchestrator/
    normative_service.dart       ← orquestrador mestre
    specification_service.dart
    procedure_service.dart

test/                            ← 95 testes
doc/
  ARCHITECTURE.md
  nbr5410/                       ← 21 MDs normativos (6.1 a 6.2.11)
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

### Curto prazo

1. **Upload dos packages ao Drive** — normative_engine e electrical_engine
2. **canvas_engine [1.4.0]** — Sistema de Snap real (baseado em geometria [1.3.0])
3. **Ciclo 4.1** — `secaoNeutro` real no `RelatorioDimensionamento`

### Médio prazo

4. **canvas_engine [1.5.0]** — Seleção e hit test
5. **canvas_engine [1.6.0]** — Operações geométricas (trim, extend)
6. **apps/flutter** — Scaffold e integração canvas ↔ dimensionamento

### Pendências técnicas

- [ ] Upload normative_engine e electrical_engine ao Drive
- [ ] Registrar IDs das novas pastas no Drive (seção 9)
- [ ] Implementar `secaoNeutro` real — ciclo 4.1
- [ ] Adicionar tabela de reatâncias (Xi) ao normative_engine
- [ ] Executar `geometry_test.dart` localmente — confirmar 30/30
- [ ] Catálogo de disjuntores comerciais como asset em `apps/flutter`
- [ ] Definir estrutura do `apps/flutter` (state management, navegação)
