# Contexto do Projeto ElectroBIM

> Documento de contexto para anexar aos arquivos do projeto no Claude.
> Data: 29 04 2026
> Rev: 4
> Estado: Sprint 3 do canvas_engine concluído ([1.3.0] Geometria Base).
> **Próximo: [1.4.0] Sistema de Snap real (baseado em geometria).**

---

## 1. Visão geral

App Flutter de projetos elétricos chamado **electro_bim**.
Foco do MVP: dimensionamento de circuitos e cargas conforme **NBR 5410**,
com motor canvas BIM como interface principal.

Pretensão comercial futura. Hoje em ritmo de hobby, sem prazo.

Conversa em **português**. Tom técnico, direto, sem floreios.

### Packages

| Package | Linguagem | Responsabilidade |
|---|---|---|
| `electrical_engine` | Dart puro | Lógica NBR 5410, dimensionamento elétrico |
| `canvas_engine` | Flutter | Motor gráfico 2D, geometria, ferramentas CAD |
| `app_flutter` | Flutter | App integrador — conecta os dois packages |

### Features planejadas

| Feature | Status |
|---|---|
| `dimensionamento_circuito` | Domínio + algoritmo prontos. Refatoração no MAJOR (Ciclo 3.5) |
| `dimensionamento_carga` | Domínio + algoritmo prontos (Ciclo 3) |
| Motor canvas | Em andamento — Sprint 3 concluído |
| Orquestrador mestre | Após MAJOR do electrical_engine |
| Aterramento | Não definido |

---

## 2. Arquitetura

### Estrutura de packages

```
electro_bim/                                    ← workspace raiz
├── electro_bim.code-workspace
├── packages/
│   ├── electrical_engine/                      ← Dart puro, zero Flutter
│   │   ├── pubspec.yaml
│   │   ├── lib/
│   │   │   ├── electrical_engine.dart          ← barrel
│   │   │   ├── core/
│   │   │   │   ├── domain/
│   │   │   │   │   ├── enums.dart
│   │   │   │   │   └── dominio_regra_tomada.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── modelos_tabela.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── repositorio_tabelas.dart
│   │   │   │       ├── repositorio_comodos.dart
│   │   │   │       └── repositorio_config_comodo_json.dart
│   │   │   └── features/
│   │   │       ├── dimensionamento_circuito/
│   │   │       │   └── domain/
│   │   │       │       ├── policies/
│   │   │       │       ├── calculations/
│   │   │       │       ├── algorithms/
│   │   │       │       ├── services/
│   │   │       │       └── models/
│   │   │       └── dimensionamento_carga/
│   │   │           └── (subpastas espelhando circuito)
│   │   └── test/
│   │
│   ├── canvas_engine/                          ← Flutter, motor gráfico
│   │   ├── pubspec.yaml
│   │   ├── lib/
│   │   │   ├── canvas_engine.dart              ← barrel v1.2.0
│   │   │   ├── domain/
│   │   │   │   ├── value_objects/
│   │   │   │   │   └── vector2.dart            ← v1.1.0
│   │   │   │   ├── entities/
│   │   │   │   │   ├── shape.dart              ← v1.1.0
│   │   │   │   │   └── line_shape.dart         ← v1.1.0
│   │   │   │   └── geometry/
│   │   │   │       ├── tolerance.dart          ← v1.0.0
│   │   │   │       ├── primitives/
│   │   │   │       │   ├── segment.dart        ← v1.0.0
│   │   │   │       │   └── aabb.dart           ← v1.0.0
│   │   │   │       └── operations/
│   │   │   │           ├── distance.dart       ← v1.0.0
│   │   │   │           ├── intersection.dart   ← v1.0.0
│   │   │   │           └── projection.dart     ← v1.0.0
│   │   │   ├── engine/
│   │   │   │   ├── canvas_engine.dart
│   │   │   │   └── scene.dart
│   │   │   ├── viewport/
│   │   │   │   └── viewport.dart
│   │   │   ├── render/
│   │   │   │   ├── render_adapter.dart
│   │   │   │   └── viewport_render_adapter.dart
│   │   │   ├── controllers/
│   │   │   │   ├── input_controller.dart       ← v2.0.0
│   │   │   │   └── tools/
│   │   │   │       ├── tool.dart               ← v1.0.0
│   │   │   │       └── draw_line_controller.dart ← v1.1.0
│   │   │   ├── models/
│   │   │   │   ├── canvas_mode.dart            ← v1.0.0
│   │   │   │   └── cursor_state.dart
│   │   │   └── services/
│   │   │       └── snap/
│   │   │           ├── snap_service.dart       (stub)
│   │   │           ├── snap_result.dart
│   │   │           └── snap_type.dart
│   │   └── test/
│   │       └── domain/geometry/
│   │           └── geometry_test.dart          ← 30 testes
│   │
│   └── app_flutter/                            ← app Flutter integrador
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── main.dart
│       │   ├── adapters/
│       │   │   └── flutter_render_adapter.dart
│       │   └── features/
│       │       └── canvas/
│       │           ├── painter/
│       │           │   └── canvas_painter.dart ← v1.1.0
│       │           └── view/
│       │               └── canvas_view.dart    ← v2.0.0
│       └── assets/
│
├── docs/
│   ├── changelog_global.md                     ← NOVO
│   └── changelog_canvas_engine.md              ← NOVO
│
└── rules_nbr5410/                              ← referência documental NBR
    └── (subpastas por capítulo)
```

### Princípios arquiteturais

**electrical_engine:**
- Imports absolutos: `package:electrical_engine/...`
- Repositório como fonte única — nada acessa JSON cru
- Service orquestra, nunca calcula
- Sem exceção como fluxo de controle
- Modelos imutáveis: `final`, `const`, factories nomeadas
- Sealed classes para famílias fechadas de regras
- Política normativa vive no core (após MAJOR)

**canvas_engine:**
- Zero dependência de Flutter no core e domain
- Flutter entra apenas em adapters (`FlutterRenderAdapter`)
- Geometria como funções top-level — não OOP
- Tudo nasce em WORLD — view é projeção
- Canvas não tem lógica — apenas renderiza o que o engine manda
- Ferramentas em arquivos separados, implementando interface `Tool`

---

## 3. Domínio — canvas_engine

### Módulo de geometria [1.3.0]

```
Tolerance          constantes nomeadas por contexto (geometric, parallel, hitTestWorld)
Vector2            posição/direção; imutável; ==, hashCode, cross, normalize
Segment            dois Vector2; == não-direcional; isDegenerate
AABB               bounding box; fromPoints, intersects, expand, union

distancePointToSegment()   distância mínima ponto→segmento (com guarda degenerado)
closestPointOnSegment()    ponto mais próximo no segmento
isPointOnSegment()         hit test com tolerância
intersectSegments()        fórmula de Gavin; IntersectionResult tipado
projectPointOntoSegment()  projeção clampada [0,1]
projectPointOntoLine()     projeção em linha infinita
```

### Sistema de coordenadas

- **WORLD**: coordenadas absolutas do projeto (metros, eventual escala)
- **SCREEN**: pixels de tela
- **Conversão**: `viewport.worldToScreen()` / `viewport.screenToWorld()`
- Hit test: sempre em WORLD com `Tolerance.hitTestWorld(viewport.scale)`

### Modos de interação

```dart
enum CanvasMode { draw, navigate }
```

- `draw`: gestos alimentam a ferramenta ativa
- `navigate`: gestos movem o viewport (pan + zoom)

### Interface Tool

```dart
abstract class Tool {
  void onTap(Vector2 point, Scene scene);
  void onMove(Vector2 point);
  void reset();
  void drawPreview(RenderAdapter adapter);
}
```

Ferramentas: uma por arquivo em `controllers/tools/`.
`InputController.setTool()` chama `reset()` automaticamente.

---

## 4. Domínio — electrical_engine

### Enums (`enums.dart` v1.0.1)

| Enum | Valores | Getters |
|---|---|---|
| `TagCircuito` | TUG, TUE, IL, MED, QDG, QD | `isTerminal` |
| `Tensao` | V127, V220, V380 | `valor` |
| `NumeroFases` | MONOFASICO, BIFASICO, TRIFASICO | `isTrifasico` |
| `Material` | COBRE, ALUMINIO | `chaveArquivo` |
| `TipoConstrutivo` ⚠️ | ISOLADO_PVC, UNIPOLAR_PVC… | `isolacaoOriginal`, etc |
| `MetodoInstalacao` ⚠️ | A1..G | `isSolo` |

⚠️ Bugs conceituais — corrigidos no MAJOR (Ciclo 3.5).

### Regras NBR implementadas

**Dimensionamento de circuito:**
- Queda de tensão: terminais 4%, alimentadores 1%
- Seção mínima: IL 1.5 mm², demais 2.5 mm²
- Disjuntor: menor `In ≥ Ib`; excesso → REPROVADO_DISJUNTOR

**Dimensionamento de carga:**
- Iluminação: 100 VA até 6m², +60 VA por 4m² inteiros
- TUG: sealed class RegraTomada com 4 subclasses (NBR 9.5.2.2)
- TUE: armazena somente VA
- Circuito misto: TUG é sempre base; TUE isolado

---

## 5. Fluxos principais

### Canvas — pipeline de input

```
GestureDetector / Listener
  ↓ coords screen
InputController.onTapDown / onPanUpdate / onZoom
  ↓ screenToWorld
SnapService.snap()           ← stub agora, real em [1.4.0]
  ↓ snapped world coord
Tool.onTap / onMove          ← DrawLineController, etc
  ↓ adiciona Shape à Scene
CanvasPainter (repaint)
  ↓ CanvasEngine.render(scene)
  ↓ Tool.drawPreview(adapter)
  ↓ _drawCursor(adapter)
ViewportRenderAdapter        ← aplica worldToScreen
FlutterRenderAdapter         ← Flutter Canvas
```

### electrical_engine — dimensionamento de circuito

```
EntradaDimensionamento
  → CalculoCorrenteProjeto (Ib)
  → PoliticaQuedaTensao (limite)
  → PoliticaDisjuntor (In)
  → PoliticaSecaoTransversal (seção mínima)
  → RepositorioTabelas (FCT, FCA)
  → SelecionadorCondutor (loop ampacidade + queda)
  → RelatorioDimensionamento
```

---

## 6. Convenções do projeto

### 6.1 Versionamento

- **Semver MAJOR.MINOR.PATCH** em todo arquivo Dart
- Cabeçalho changelog inline no topo
- Categorias: `ADD`, `CHG`, `FIX`, `DEL`, `DEP`
- Data: `DD MM AAAA`
- Versões mais recentes no topo

```dart
/// REV: 2.0.0
/// CHANGELOG:
/// [2.0.0] - 29 04 2026
/// - ADD: ...
///
/// [1.0.0] - 25 04 2026
/// - ADD: ...
```

### 6.2 Contexto do projeto

- Sufixo `rev*` no nome do arquivo: `contexto_projeto_electrobim-4.md`
- Rev atual: **4**
- Atualizar a cada sprint ou decisão arquitetural relevante

### 6.3 Changelogs de documentação

| Arquivo | Escopo |
|---|---|
| `docs/changelog_global.md` | Cross-package: sprints, decisões, mudanças estruturais |
| `docs/changelog_canvas_engine.md` | Package canvas_engine |
| `docs/changelog_electrical_engine.md` | Package electrical_engine (a criar) |

`changelog_global` é índice de alto nível — não substitui os de feature.

### 6.4 Nomenclatura de arquivos

**electrical_engine** — prefixo de pasta:

| Pasta | Prefixo |
|---|---|
| `core/domain/` | `dominio_` |
| `core/domain/nbr5410/` | `politica_` |
| `core/repositories/` | `repositorio_` |
| `features/*/algorithms/` | `algoritmo_` |
| `features/*/models/` | `modelo_` |

**canvas_engine** — inglês, sem prefixo de pasta (pasta já contextualiza).

### 6.5 Imports

- Sempre absolutos: `package:canvas_engine/...`, `package:electrical_engine/...`
- Ordem: dart core → packages externos → próprio package

### 6.6 Modelos imutáveis (electrical_engine)

- Campos `final`, construtores `const`, `List.unmodifiable`
- Factories nomeadas para casos específicos
- `copyWith()` em modelos editáveis pela UI

### 6.7 Geometria (canvas_engine)

- Funções top-level, não métodos — mais testável, mais idiomático
- Tolerância sempre nomeada via `Tolerance.*`, nunca literal numérico solto
- Hit test sempre zoom-aware: `Tolerance.hitTestWorld(viewport.scale)`
- `Segment` como detalhe interno de `LineShape` (Opção B)

### 6.8 Tratamento de falhas

- **Falhas técnicas**: `ArgumentError` / `StateError` na inicialização
- **Falhas de domínio**: status reprovado + violações no relatório
- **Nenhuma exceção propaga até a UI** a partir do serviço

---

## 7. Decisões importantes registradas

**electrical_engine:**

[DECISION] Ordenação das tabelas: repositório ordena por seção crescente na carga.

[DECISION] Sealed class para regras de TUG: type safety + exhaustiveness.

[DECISION] TUE armazena somente VA.

[DECISION] TUG é sempre a base de circuito misto.

[DECISION] vaTotalProjeto = soma simples; fator de demanda no orquestrador.

[DECISION] Feature luminotécnica descartada (27 04 2026).

[DECISION] Motor canvas BIM antes da UI tradicional (28 04 2026).

[DECISION] TipoConstrutivo é arquitetura + isolação misturadas — refatorar no MAJOR.

[DECISION] Tabelas de ampacidade indexam por (material, isolação), não por arquitetura.

[DECISION] Política normativa vive no core, não nas features (após MAJOR).

[DECISION] Tier 1/2/3 de implementação de regras NBR.

**canvas_engine:**

[DECISION] Packages separados: electrical_engine (Dart puro), canvas_engine (Flutter),
app_flutter. canvas_engine nunca importa Flutter no core.

[DECISION] CanvasMode enum para separar gesto de desenho vs navegação.

[DECISION] Tool como interface — ferramentas em arquivos separados.
setTool() chama reset() automaticamente.

[DECISION] Segment como detalhe interno de LineShape (Opção B).
API pública `LineShape(a, b)` não muda; Segment exposto via getter computed.

[DECISION] Tolerance nomeado por contexto: geometric, parallel, hitTestWorld(scale).
Hit test de tela depende do zoom — não usar EPS único global.

[DECISION] Geometria como funções top-level (distance.dart, intersection.dart,
projection.dart). Não OOP — matemática pura é mais testável como funções soltas.

[DECISION] IntersectionResult tipado com IntersectionType enum.
Evita null como sinalização de falha.

[DECISION] Fórmula de Gavin para intersectSegments:
t = (q−p) × s / (r × s), u = (q−p) × r / (r × s).
Comparação de paralelo via `cross.abs() < Tolerance.parallel` (não `cross == 0`).

[DECISION] changelog_global + changelog_feature como convenção de documentação
cross-package e por package. Contexto versionado com sufixo rev*.

---

## 8. Estado atual — canvas_engine

```
canvas_engine/lib/
  canvas_engine.dart                           v1.2.0

  domain/value_objects/
    vector2.dart                               v1.1.0

  domain/entities/
    shape.dart                                 v1.1.0
    line_shape.dart                            v1.1.0

  domain/geometry/
    tolerance.dart                             v1.0.0
    primitives/
      segment.dart                             v1.0.0
      aabb.dart                                v1.0.0
    operations/
      distance.dart                            v1.0.0
      intersection.dart                        v1.0.0
      projection.dart                          v1.0.0

  engine/
    canvas_engine.dart                         v1.0.0
    scene.dart                                 v1.0.0

  viewport/
    viewport.dart                              v1.0.0

  render/
    render_adapter.dart                        v1.0.0
    viewport_render_adapter.dart               v1.0.0

  controllers/
    input_controller.dart                      v2.0.0
    tools/
      tool.dart                                v1.0.0
      draw_line_controller.dart                v1.1.0

  models/
    canvas_mode.dart                           v1.0.0
    cursor_state.dart                          v1.0.0

  services/snap/
    snap_service.dart                          v1.0.0 (stub)
    snap_result.dart                           v1.0.0
    snap_type.dart                             v1.0.0

canvas_engine/test/
  domain/geometry/
    geometry_test.dart                         30 testes
```

## 9. Estado atual — electrical_engine

```
lib/core/dominio/
  enums.dart                                   v1.0.1
  dominio_regra_tomada.dart                    v1.0.0

lib/core/modelos/
  modelos_tabela.dart                          v1.0.2

lib/core/repositorio/
  repositorio_tabelas.dart                     v1.0.3
  repositorio_comodos.dart                     v1.0.0
  repositorio_config_comodo_json.dart          v1.0.0

lib/features/dimensionamento_circuito/domain/
  algorithms/
    selecionador_condutor.dart                 v1.0.0
  calculations/
    calculo_corrente_proj.dart                 v1.1.0
    calculo_ampacidade_cabo.dart               v2.0.0
    calculo_queda_tensao.dart                  v1.0.0
  models/
    entrada_dimensionamento.dart               v1.0.1
    contexto_selecao.dart                      v1.0.0
    resultado_selecao.dart                     v1.0.0
    resultado_ampacidade.dart                  v1.1.0
    relatorio_dimensionamento.dart             v2.1.0
  policies/
    politica_queda_tensao.dart                 v1.0.0
    politica_secao_transversal.dart            v2.0.0
    politica_disjuntor.dart                    v2.0.0
  services/
    servico_dimensionamento_circuito.dart      v3.1.0

lib/features/dimensionamento_carga/
  algorithms/
    algoritmo_gerador_pontos_comodo.dart       v1.0.1
    algoritmo_validador_comodo.dart            v1.0.1
    algoritmo_agregador_circuitos.dart         v1.0.1
  models/
    modelo_comodo.dart                         v1.0.0
    modelo_ponto_carga.dart                    v1.0.0
    modelo_tue.dart                            v1.0.0
    modelo_entrada_carga.dart                  v1.0.0
    modelo_relatorio_carga.dart                v1.0.0
  policies/
    politica_iluminacao.dart                   v1.0.0
  services/
    servico_dimensionamento_carga.dart         v1.0.0
```

---

## 10. Google Drive — IDs das pastas

Drive: **Projeto ElectroBIM** (raiz: `1gQQzbuPOtVVfLMkA2jK7knDQ4eePboCp`)

| Pasta | ID |
|---|---|
| `packages/electrical_engine/` | `1rI0HIDWzqwR-14ej5YAqBpklCCmklA4y` |
| `packages/canvas_engine/` | `1pHB5mrcoToHezKuAPPN21db4nUXP-XVI` |
| `apps/app_flutter/` | `17qgUayYVz9lCSaZ2tZg5ULFC71UdNXiq` |
| `log/` | `1Z70y6y4oz0oVJB892gTq3NpsLKSDw38y` |

> IDs internos de canvas_engine e electrical_engine: a mapear após próximo upload.

---

## 11. Próximos passos

### [1.4.0] Sistema de Snap real

Depende de [1.3.0] (geometria). Snap baseado em geometria real:
- `SnapType`: none, endpoint, midpoint, perpendicular, intersection
- `SnapService` real: itera shapes da scene, calcula candidatos, retorna mais próximo
- Tolerância de snap via `Tolerance.hitTestWorld(viewport.scale)`

### Ciclo 3.5 — MAJOR de domínio (electrical_engine)

Refatoração estrutural do electrical_engine antes de qualquer UI:
- Split TipoConstrutivo → Arquitetura + Isolacao
- Tabelas de ampacidade consolidadas por (material, isolação)
- ConfiguracaoCondutores enum para arranjos F/G
- core/domain/nbr5410/ — políticas centralizadas
- Correções Tier 1 de lacunas NBR

### Sequência após Snap

1. [1.5.0] Seleção e hit test (usa geometria + snap)
2. [1.6.0] Operações geométricas (trim, extend)
3. Ciclo 3.5 — MAJOR electrical_engine
4. Orquestrador mestre
5. Integração canvas ↔ domínio elétrico

---

## 12. Pendências práticas

- [ ] Upload dos arquivos do Sprint 2 e Sprint 3 ao Drive (canvas_engine)
- [ ] Mapear IDs internos das pastas de canvas_engine no Drive (seção 10)
- [ ] Criar `docs/changelog_electrical_engine.md`
- [ ] Executar `geometry_test.dart` localmente e confirmar 30/30 passando
- [ ] Registrar IDs pastas dimensionamento_carga no Drive
- [ ] Upload manual `repositorio_tabelas.dart` v1.0.3 (pendência Ciclo 2)
- [ ] Deletar arquivos obsoletos do alpha de carga e luminotécnica no Drive
