# 📄 Documento Técnico — Snap System (Canvas Engine)

## 📅 Data
02/05/2026

---

# 1. Contexto do Sistema

Este documento descreve a arquitetura, evolução e estado final do sistema de snapping do Canvas Engine, incluindo sua refatoração para um modelo modular e escalável.

O sistema evoluiu de um Snap básico para uma arquitetura tipo CAD com:

- múltiplos providers
- priorização por tipo
- candidatos concorrentes
- pipeline de decisão de snap

---

# 2. Arquitetura Atual

## 2.1 Fluxo principal

CanvasView → InputController → SnapService → Providers → SnapCandidate → SnapResult

---

## 2.2 Camadas

### 🟢 API Pública
- SnapService
- SnapResult
- SnapCandidate
- SnapType

### 🔵 Engine Interno
- SnapService (lógica de decisão)
- Scene
- Viewport
- InputController

### 🔴 Infra Interna
- SnapProvider
- GlobalSnapProvider
- LineSnapProvider
- IntersectionSnapProvider

---

# 3. Problema Original

## 3.1 Conflitos identificados

- duplicação de SnapProvider no graph de imports
- export excessivo no canvas_engine.dart
- UI instanciando providers diretamente
- imports ambíguos (barrel + direto)

---

## 3.2 Impacto

- erro undefined_method
- conflito de símbolos no analyzer
- quebra de build em múltiplos pontos
- acoplamento UI ↔ engine interno

---

# 4. Solução Aplicada

## 4.1 Sub-barrel do Snap

Criação de:

services/snap/snap.dart

Responsável por expor apenas API pública do Snap.

---

## 4.2 Encapsulamento de Providers

Providers movidos para camada interna não exportada.

---

## 4.3 Factory Pattern

SnapService.createDefault() introduzido para:

- eliminar montagem manual na UI
- centralizar configuração do snap
- manter encapsulamento

---

## 4.4 Correção da UI

CanvasView passou a depender apenas de:

SnapService.createDefault()

---

## 4.5 Otimização de algoritmo

- remoção de sort()
- avaliação incremental de candidatos
- complexidade reduzida para O(n)
- desempate determinístico

---

# 5. Estado Final do Sistema

## ✔ Características

- arquitetura modular limpa
- Snap isolado da UI
- providers encapsulados
- API pública controlada
- performance otimizada

---

# 6. Benefícios Técnicos

## 6.1 Escalabilidade

Sistema preparado para:

- SnapPipeline
- múltiplos modos de snap
- snapping contextual por ferramenta

---

## 6.2 Manutenibilidade

- redução de acoplamento
- isolamento de dependências internas
- API estável para UI

---

## 6.3 Performance

- O(n) ao invés de O(n log n)
- menor alocação de memória
- menos recomputação

---

# 7. Evoluções Futuras

- SnapPipeline (CAD-like)
- Snap por ferramenta (Line / Pline / Move)
- Snap preview múltiplo (ghost snapping)
- Spatial indexing (quadtree / BVH)
- Cache de frame

---

# 8. Conclusão

O sistema foi transformado de um snap simples para uma arquitetura robusta, modular e escalável, pronta para evolução para nível CAD/Figma.
