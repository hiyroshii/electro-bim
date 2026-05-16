# ElectroBIM — Classificação das Regras NBR 5410 Aplicáveis
<!-- REV: 1 -->
<!-- CHANGELOG:
[Rev 1] - 06 05 2026
- ADD: Classificação inicial gerada a partir da NBR 5410:2004 (2ª ed., versão corrigida 2008)
         cruzada com o contexto do projeto v0.3.5 (contexto_projeto_electrobim_rev7.md).
- Critério de prioridade: MVP → Ciclo futuro próximo → Ciclo futuro distante → Fora de escopo atual.
-->

> Data: 06 05 2026
> Base normativa: **ABNT NBR 5410:2004** (2ª edição, versão corrigida 17.03.2008)
> Base do projeto: **ElectroBIM** — ver `contexto_projeto_electrobim_rev8.md` para estado atual
> Packages impactados: `normative_engine`, `electrical_engine`, `canvas_engine` (indiretamente)

---

## Critério de Classificação

As regras foram organizadas em **4 grupos de prioridade**, derivados diretamente do roadmap do projeto:

| Grupo | Prioridade | Descrição |
|---|---|---|
| **G1** | MVP — Implementado | Regras já presentes no `normative_engine` e `electrical_engine` |
| **G2** | MVP — Em revisão / pendente | Regras mapeadas mas com TODOs ou revisão aberta |
| **G3** | Ciclo próximo (4.x–6.x) | Regras necessárias para os próximos ciclos de desenvolvimento |
| **G4** | Ciclo distante (7.x+) | Regras relevantes mas fora do horizonte imediato |

---

## G1 — MVP: Já Implementado

### 6.2.7 — Queda de Tensão

**Localização no projeto:** `normative_engine/src/specification/spec_queda_tensao.dart`, `procedure/proc_queda_tensao.dart`

| Circuito | Origem da alimentação | Limite próprio | Limite total |
|---|---|---|---|
| Terminal (TUG, TUE, IL) | qualquer | **4 %** | — |
| Alimentador (MED, QDG, QD) | Concessionária (entrega) | **1 %** | **5 %** |
| Alimentador (MED, QDG, QD) | Trafo/gerador próprio | **3 %** | **7 %** |

**Fórmula (com reatância e cos φ):**
```
ΔU = √3 · I · L · (R·cos φ + X·sin φ)   [trifásico]
ΔU = 2 · I · L · (R·cos φ + X·sin φ)    [monofásico]
```

> DECISION registrada: `OrigemAlimentacao` como enum — `ENTREGA` (1 %) vs `PROPRIO` (3 %).

---

### 6.2.3 / Tabela 33 — Combinações Válidas: Isolação × Arquitetura × Método

**Localização:** `normative_engine/src/specification/spec_combinacoes.dart`

#### Isolação × Arquitetura (6.2.3.2–6.2.3.3)

| Isolação | Condutor isolado | Cabo unipolar | Cabo multipolar |
|---|---|---|---|
| PVC | ✅ | ✅ | ✅ |
| XLPE | ❌ | ✅ | ✅ |
| EPR | ❌ | ✅ | ✅ |

> PVC isolado admitido via NBR 7288/8661; XLPE isolado sem cobertura equivale a unipolar (6.2.3.3).

#### Arquitetura × Método (Tabela 33)

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

> `*` = exceções documentadas na Tabela 33 (métodos físicos 51, 43, 26, 23/25/27 da IEC 60364-5-52).

---

### 6.2.3.8 — Restrições ao Alumínio

**Localização:** `normative_engine/src/specification/spec_aluminio.dart`

| Contexto | Regra |
|---|---|
| BD4 (alta densidade, fuga longa) | **Proibido absolutamente** (6.2.3.8.3) |
| Industrial (BA5, alimentação AT/própria) | Seção ≥ 16 mm² obrigatória (6.2.3.8.1) |
| Comercial BD1 (baixa densidade, BA5) | Seção ≥ 50 mm² obrigatória (6.2.3.8.2) |

---

### 6.2.5 — Capacidade de Condução de Corrente (Ampacidade)

**Localização:** `normative_engine/src/procedure/proc_ampacidade.dart`, `src/tables/tabela_35` a `tabela_48`

**Métodos de referência (6.2.5.1.2):**

| Método | Descrição |
|---|---|
| A1 | Condutor isolado em eletroduto embutido em parede termicamente isolante |
| A2 | Cabo multipolar em eletroduto embutido em parede termicamente isolante |
| B1 | Condutor isolado em eletroduto sobre parede de madeira |
| B2 | Cabo multipolar em eletroduto sobre parede de madeira |
| C | Cabo unipolar ou multipolar sobre parede (distância < 0,3×Ø do cabo) |
| D | Cabo multipolar em eletroduto enterrado (ρ = 2,5 K·m/W, prof. = 0,7 m) |
| E | Cabo multipolar ao ar livre |
| F | Cabos unipolares justapostos ao ar livre |
| G | Cabos unipolares espaçados ao ar livre |

**Fatores de correção aplicáveis (Tabelas 40–48):**
- Temperatura ambiente ≠ 30 °C (Tabela 40)
- Agrupamento de circuitos (Tabelas 42–44)
- Solo com resistividade ≠ 2,5 K·m/W (método D, Tabela 45)
- Profundidade de enterramento ≠ 0,7 m (método D, Tabelas 46–47)

> Todos os fatores implementados como `const Map<>` Dart em `tables/`.

---

### 5.3.4 — Coordenação Condutor–Disjuntor (Proteção contra Sobrecarga)

**Localização:** `normative_engine/src/specification/spec_secao_minima.dart`, `electrical_engine/src/orchestrator/circuito/politica_disjuntor.dart`

**Condição de proteção contra sobrecarga:**
```
IB ≤ In ≤ Iz    (5.3.4.1-a)
I2 ≤ 1,45 × Iz  (5.3.4.1-b)
```

Onde:
- `IB` = corrente de projeto do circuito
- `In` = corrente nominal do disjuntor
- `Iz` = ampacidade do condutor nas condições de instalação
- `I2` = corrente convencional de atuação (disjuntor: `I2 = 1,45 × In`)

> Logo, para disjuntores: `In ≥ IB` e `In ≤ Iz` (condição suficiente).

---

### 9.5.2 — Previsão de Carga em Habitações (Cômodos)

**Localização:** `electrical_engine/src/orchestrator/carga/gerador_pontos_comodo.dart`, `normative_engine/src/specification/spec_combinacoes.dart`

#### 9.5.2.1 — Iluminação (IL)

- Mínimo **1 ponto de luz fixo no teto** por cômodo, com interruptor (9.5.2.1.1)
- Carga mínima por cômodo (alternativa à NBR 5413):

| Área do cômodo | Carga mínima |
|---|---|
| ≤ 6 m² | 100 VA |
| > 6 m² | 100 VA + 60 VA por 4 m² inteiros acima dos primeiros 6 m² |

#### 9.5.2.2 — Tomadas de Uso Geral (TUG)

**Número mínimo de pontos:**

| Local | Critério |
|---|---|
| Banheiro | ≥ 1 ponto próximo ao lavatório |
| Cozinha / copa / lavanderia / área de serviço | ≥ 1 ponto a cada 3,5 m (ou fração) de perímetro; ≥ 2 acima da bancada da pia |
| Varandas | ≥ 1 ponto |
| Salas e dormitórios | ≥ 1 ponto a cada 5 m (ou fração) de perímetro |
| Demais cômodos ≤ 2,25 m² | ≥ 1 ponto (admite externo até 0,80 m da porta) |
| Demais cômodos > 2,25 m² e ≤ 6 m² | ≥ 1 ponto |
| Demais cômodos > 6 m² | ≥ 1 ponto a cada 5 m (ou fração) de perímetro |

**Potência mínima por ponto:**

| Local | Até 3 pontos | Excedentes |
|---|---|---|
| Banheiro, cozinha, lavanderia, área de serviço | 600 VA/ponto | 100 VA/ponto |
| Demais cômodos e dependências | 100 VA/ponto | — |

> Quando o total nos locais "molhados" superar 6 pontos, admite-se 600 VA até 2 pontos e 100 VA para os demais.

---

### 9.5.3 — Divisão da Instalação (Circuitos)

**Localização:** `electrical_engine/src/orchestrator/carga/agregador_circuitos.dart`

- Equipamento com `In > 10 A` → **circuito independente** obrigatório (9.5.3.1)
- Tomadas de cozinha, copa, lavanderia, área de serviço → **circuito exclusivo** para tomadas desses locais (9.5.3.2)
- Circuito misto (IL + TUG) admitido quando (9.5.3.3):
  - `IB ≤ 16 A`
  - Iluminação não atendida integralmente por um único circuito misto
  - Tomadas (excl. 9.5.3.2) não atendidas integralmente por um único circuito misto

---

## G2 — MVP: Em Revisão / Pendência Aberta

### 6.2.6 — Seção do Condutor Neutro

**Pendência:** `secaoNeutro` real — ciclo 4.1 (TODO registrado no contexto rev7)

**Regras normativas:**

| Situação | Seção do neutro |
|---|---|
| Circuito monofásico (2 fios) | Igual à fase |
| Circuito bifásico ou trifásico com neutro, seção de fase ≤ 16 mm² (Cu) ou ≤ 25 mm² (Al) | Igual à fase |
| Circuito trifásico, seção de fase > 16 mm² (Cu) ou > 25 mm² (Al) | ≥ 16 mm² (Cu) / ≥ 25 mm² (Al), calculado para corrente de desequilíbrio |
| Circuito trifásico com cargas desequilibradas ou harmônicas significativas (3ª e múltiplas de 3) | Neutro reforçado — pode exceder a fase |

> Atualmente `RelatorioDimensionamento.toResultadoNormativo()` usa `secaoFase` como proxy (DECISION registrada).

---

### Tabela de Reatâncias (Xi)

**Pendência:** `electrical_engine/src/calculos/calc_queda_tensao.dart` implementado com `cos φ + reatância`, mas tabela de Xi para cabos ainda não incorporada ao `normative_engine`.

**Contexto normativo:** Os valores de reatância (Ω/km) são dados pelos fabricantes conforme ABNT NBR 7286/7287/7288. A Tabela 9 da IEC 60364-5-52 fornece valores de referência para cálculo de queda de tensão.

**Impacto:** Sem Xi, o cálculo usa apenas resistência (R·cos φ), o que é conservador para cabos de seção ≥ 35 mm². Para seções menores (residencial padrão), o erro é desprezível.

---

### 9.5.4 — Proteção contra Sobrecorrentes em Circuitos Terminais

**Regra:** Dispositivo de proteção deve seccionar simultaneamente **todos os condutores de fase** (multipolar se > 1 fase).

> Dispositivos unipolares acoplados mecanicamente não equivalem a multipolar.

---

## G3 — Ciclo Próximo (Ciclos 4.x–6.x)

### 5.1.3.2 — DR de Alta Sensibilidade (≤ 30 mA) — Proteção Adicional

**Obrigatório em (5.1.3.2.2):**

| Local / Condição |
|---|
| Circuitos com pontos de utilização em banheiros com chuveiro ou banheira (9.1) |
| Circuitos de tomadas em áreas externas à edificação |
| Circuitos de tomadas internas que possam alimentar equipamentos no exterior |
| Cozinhas, copas, lavanderias, áreas de serviço, garagens e dependências internas molhadas (habitação) |
| Mesmos locais em edificações não-residenciais |

> Aplica-se a tomadas com `In ≤ 32 A`.

**Impacto no projeto:** Os cômodos já têm classificação no domínio. A flag `requerDR` deve ser adicionada ao modelo de `Comodo` ou ao `ResultadoNormativo`. Feature candidata para o ciclo de integração `canvas ↔ dimensionamento`.

---

### 5.3.4.1 — Temperatura de Isolação (Tabela 35)

**Temperatura máxima admissível por tipo de isolação:**

| Isolação | Temperatura máxima — serviço contínuo | Temperatura — curto-circuito |
|---|---|---|
| PVC | 70 °C | 160 °C (seção ≤ 300 mm²) / 140 °C (seção > 300 mm²) |
| XLPE / EPR | 90 °C | 250 °C |

> Relevante para `k²S²` no cálculo de proteção contra curto-circuito (Tabela 30, 5.3.5.5.2).

---

### 6.2.6.2 — Seção Mínima Absoluta por Tipo de Circuito

| Tipo de circuito | Material | Seção mínima |
|---|---|---|
| Circuitos fixos em geral | Cobre | 1,5 mm² |
| Circuitos de tomada | Cobre | 2,5 mm² |
| Circuitos de chuveiro elétrico | Cobre | 2,5 mm² (recomendado ≥ 4 mm²) |
| Iluminação, sinalização | Cobre | 1,5 mm² |

> Já parcialmente implementado em `spec_secao_minima`. Verificar completude para todos os `TagCircuito`.

---

### 4.2.2 — Esquemas de Aterramento (TT, TN, IT)

**Impacto futuro no `normative_engine`:**

| Esquema | Características | Uso típico BR |
|---|---|---|
| TT | Aterramento independente da concessionária; exige DR | Instalações residenciais típicas |
| TN-S | Condutor PE separado do neutro | Predial moderno |
| TN-C | Condutor PEN único (obsoleto, proibido após ponto de entrada) | Alimentação da concessionária |
| TN-C-S | PEN separado a partir da edificação | Transição típica |
| IT | Neutro isolado, máxima continuidade | Industrial / hospitalar |

> O esquema impacta as condições de seccionamento automático (Tabela 25/26), cálculo de `Ia` e uso de DR.

---

## G4 — Ciclo Distante (7.x+)

### 5.3.5 — Proteção contra Curtos-Circuitos

- Capacidade de interrupção do disjuntor ≥ Icc presumida no ponto de instalação (5.3.5.5.1)
- Integral de Joule: `I²t ≤ k²S²` (5.3.5.5.2, Tabela 30)
- Cálculo de `Icc` max (barramento) e `Icc` min (extremidade do circuito)

### 9.1 — Locais com Chuveiro ou Banheira (Volumes 0–3)

- Prescrições de volumes e distâncias (IPX4, IPX5 por volume)
- Equipotencialização suplementar obrigatória
- DR ≤ 30 mA obrigatório

### 4.2.6 — Classificação de Influências Externas

- Tabela 32 completa (AA a CB): temperatura, umidade, presença de água (AD), corpos sólidos (AE), etc.
- Relevante para seleção do grau de proteção (IP) e validação de instalação por ambiente.

### 5.4 — Proteção contra Sobretensões e Perturbações Eletromagnéticas

- DPS (dispositivo de proteção contra surtos) em instalações com linha aérea ou AQ2/AQ3
- Tabela 31: suportabilidade a impulso (categorias I a IV)

---

## Mapeamento Resumido: Regra → Package → Feature

| Seção NBR 5410 | Descrição | Package | Feature / Arquivo |
|---|---|---|---|
| 6.2.7 | Queda de tensão | `normative_engine` | `spec_queda_tensao`, `proc_queda_tensao` |
| 6.2.3 + Tab.33 | Isolação × arquitetura × método | `normative_engine` | `spec_combinacoes` |
| 6.2.3.8 | Alumínio | `normative_engine` | `spec_aluminio` |
| 6.2.5 + Tab.35–48 | Ampacidade + fatores de correção | `normative_engine` | `proc_ampacidade`, `tables/tabela_35–48` |
| 5.3.4.1 | IB ≤ In ≤ Iz, I2 ≤ 1,45·Iz | `normative_engine` | `spec_secao_minima` |
| 9.5.2.1 | IL por cômodo (carga mínima) | `electrical_engine` | `gerador_pontos_comodo` |
| 9.5.2.2 | TUG por cômodo (qtd + potência) | `electrical_engine` | `gerador_pontos_comodo` |
| 9.5.3 | Divisão da instalação | `electrical_engine` | `agregador_circuitos` |
| 9.5.4 | Dispositivo multipolar | `electrical_engine` | `politica_disjuntor` |
| 6.2.6 | Seção do neutro | `normative_engine` | `spec_neutro` — **ciclo 4.1** |
| 5.1.3.2 | DR ≤ 30 mA (obrigatório) | `normative_engine` | a criar — **ciclo 4.x** |
| 6.2.6.2 | Seção mínima absoluta | `normative_engine` | `spec_secao_minima` — revisar |
| 4.2.2 | Esquema de aterramento | `normative_engine` | a criar — **ciclo futuro** |
| 5.3.5 | Proteção contra curto-circuito | `normative_engine` | a criar — **ciclo distante** |
| 9.1 | Volumes em banheiros | `normative_engine` | a criar — **ciclo distante** |
| 4.2.6 | Influências externas | `normative_engine` | a criar — **ciclo distante** |

---

## Referências Internas

- `contexto_projeto_electrobim_rev8.md` — Estado atual do projeto
- `ARCHITECTURE.md` (raiz do repo) — estrutura de packages e camadas
- `packages/normative_engine/CHANGELOG.md` — histórico do normative_engine
- `packages/electrical_engine/CHANGELOG.md` — histórico do electrical_engine
- `ABNT NBR 5410:2004` — Versão corrigida 17.03.2008 (exemplar CONNECTCOM, 209 p.)
