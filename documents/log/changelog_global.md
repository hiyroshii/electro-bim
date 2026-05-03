# CHANGELOG GLOBAL — ElectroBIM

Registro cross-package: sprints, decisões arquiteturais, mudanças estruturais.
Não substitui os changelogs de feature — é o índice de alto nível.

Formato de data: DD MM AAAA (sem barras).
Categorias: ADD, CHG, FIX, DEL, DECISION, ARCH.

---

## Sprint 3 — Geometria Base — 29 04 2026

### Packages afetados
- `canvas_engine`

### ADD
- Módulo completo de geometria [1.3.0]: Tolerance, Segment, AABB, distance,
  intersection, projection
- 30 testes unitários cobrindo todo o módulo

### CHG
- `Vector2` v1.1.0: == / hashCode / equalsApprox / cross / normalize / distanceTo
- `Shape` v1.1.0: hitTest recebe tolerance (zoom-aware)
- `LineShape` v1.1.0: hitTest real + getter segment interno

### DECISION
- Segmento como detalhe interno de LineShape (Opção B): API pública `LineShape(a, b)`
  não muda; `segment` exposto como getter computed. Evita impacto nos arquivos existentes.
- Tolerance nomeado por contexto (geometric, parallel, hitTestWorld) em vez de EPS único.
  Hit test de tela depende do zoom — Tolerance.hitTestWorld(scale) torna isso explícito.
- Geometria como funções top-level, não métodos OOP. Dart suporta funções soltas;
  mais testável e idiomático para matemática pura.
- IntersectionResult tipado com IntersectionType enum: evita null como sinalização,
  deixa o tipo de falha explícito para quem consome.

---

## Sprint 2 — Navegação e Interface de Ferramentas — 29 04 2026

### Packages afetados
- `canvas_engine`, `app_flutter`

### ADD
- CanvasMode enum (draw / navigate)
- Interface Tool abstrata com drawPreview
- Pan de viewport conectado ao GestureDetector no modo navigate
- Zoom via scroll do mouse (Listener + PointerScrollEvent)
- FAB de troca de modo no CanvasView

### CHG
- InputController: tool genérico (Tool interface), suporte a CanvasMode, onZoom
- DrawLineController: implements Tool, drawPreview corrigido (estava sem render)
- CanvasPainter: recebe Tool e chama drawPreview — preview de linha funcionando
- CanvasView: Listener para scroll, modo de gesto contextual

### DECISION
- CanvasMode enum para separar gesto de desenho vs navegação. Sem isso, pan de
  câmera e pan de ferramenta conflitam no mesmo GestureDetector.
- Tool como interface abstrata — cada ferramenta em arquivo separado em
  controllers/tools/. Nunca todas num único arquivo.
- setTool() chama reset() automaticamente — ferramenta nunca fica em estado
  sujo ao ser trocada.

---

## Sprint 1 — Motor Gráfico Base — 29 04 2026

### Packages afetados
- `canvas_engine`, `app_flutter` (criação)

### ARCH
- Separação em 3 packages: electrical_engine (Dart puro), canvas_engine (Flutter),
  app_flutter (app integrador)
- canvas_engine sem dependência de Flutter no core — apenas em adapters
- app_flutter conecta os dois via FlutterRenderAdapter

### ADD
- Motor de renderização completo: CanvasEngine, Scene, Shape, RenderAdapter
- Viewport com worldToScreen / screenToWorld / zoom / pan
- ViewportRenderAdapter: transformação de coordenadas transparente ao engine
- Pipeline de input: Screen → World → Snap → Tool
- CursorState: raw vs snapped
- DrawLineController: ferramenta de linha dois-cliques
- SnapService stub (sem geometria real ainda)
- FlutterRenderAdapter no app_flutter

### DECISION
- RenderAdapter definido no canvas_engine, implementado no app_flutter.
  canvas_engine nunca importa Flutter.
- zoom com focal point: worldToScreen antes e depois do scale, compensa offset.
  Garante que o ponto sob o cursor não se move ao aplicar zoom.
- shouldRepaint = true por enquanto. Otimizar quando canvas ficar complexo.

---

## Ciclo 3 — Feature dimensionamento_carga — 27 04 2026

### Packages afetados
- `electrical_engine`

### ADD
- Feature dimensionamento_carga completa (13 arquivos)
- dominio_regra_tomada.dart: sealed class RegraTomada com 4 subclasses (NBR 9.5.2.2)
- repositorio_comodos.dart, repositorio_config_comodo_json.dart
- modelos: Comodo, PontoCarga, Tue, EntradaCarga, RelatorioCarga
- algoritmos: GeradorPontosComodo, ValidadorComodo, AgregadorCircuitos
- servico_dimensionamento_carga.dart
- politica_iluminacao.dart (NBR 9.5.2.1.2)

### DECISION
- Sealed class para regras de TUG em vez de Strategy + Registry de strings
- TUE armazena somente VA; entrada W+FP normalizada e descartada
- TUG é sempre base de circuito misto (NBR 9.5.3.3)
- vaTotalProjeto = soma simples; fator de demanda fica no orquestrador mestre

---

## Ciclo 2 — Algoritmo e Orquestração — 26 04 2026

### Packages afetados
- `electrical_engine`

### ADD
- SelecionadorCondutor com critério duplo (ampacidade + queda)
- PoliticaQuedaTensao (4% terminal / 1% alimentador)
- ContextoSelecao, ResultadoSelecao

### CHG
- Calculo, Politica e Relatorio: tipagem forte (enums, modelos tipados)

---

## Ciclo 1 — Fundação — 25 04 2026

### Packages afetados
- `electrical_engine` (criação)

### ADD
- enums.dart: 6 enums de domínio elétrico
- modelos_tabela.dart: 6 modelos tipados com fromJson
- repositorio_tabelas.dart: carga eager de 18 JSONs
- entrada_dimensionamento.dart: modelo imutável com 9 validações
