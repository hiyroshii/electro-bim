# Manual Normativo Técnico do ElectroBIM
<!-- REV: 1 -->
<!-- CHANGELOG:
[Rev 1] - 06 05 2026
- ADD: Estrutura do manual com convenções de notação e protocolo de revisão.
- ADD: Domínio compartilhado (D-1 a D-8), tabelas críticas (T-1 a T-15),
        classificações iniciais (C-1 a C-4), procedures (P-1 a P-6),
        specifications (S-1 a S-12) — Fases 1-3 detalhadas.
- ADD: Esqueleto de Fases 4-9 com fórmulas-chave e referências NBR para complemento posterior.
-->

> **Propósito:** catálogo estruturado da NBR 5410:2004 (corrigida 2008) para implementação direta no `normative_engine`, sem necessidade de releitura do PDF a cada ciclo.
> **Estado:** Rev 1 — Fases 1-3 detalhadas; Fases 4-9 com esqueleto
> **Base:** PDF da NBR 5410 (209 p., exemplar CONNECTCOM) + classificação rev1 + roadmap rev1

---

## Como usar

### Notação de IDs

| Prefixo | Tipo | Função |
|---|---|---|
| `D-N` | Domain | Enum / Value Object — vocabulário compartilhado |
| `T-N` | Table | Lookup puro — dado normativo, sem lógica |
| `C-N` | Classification | Input → código (enum). Não valida, não calcula |
| `P-N` | Procedure | Input → valor numérico |
| `S-N` | Specification | Input → `List<Violacao>` |
| `V-N` | Verification | Medição em campo → conformidade |

### Anatomia de uma entrada

```
### S-3 — Sobrecarga (IB ≤ In ≤ Iz)
NBR ref:        5.3.4.1
Aplicabilidade: Todos escopos, todo circuito terminal e alimentador
Inputs:         IB [A], In [A], Iz [A]
Output:         List<Violacao>
Algoritmo:      <fórmula ou árvore de decisão>
Edge cases:     <ressalvas explícitas da norma>
Dependências:   P-1 (ampacidade), T-7 (correntes nominais comerciais)
```

### Convenções de revisão

- **Adicionar entrada:** incrementa `REV` no header, registra no changelog
- **Modificar entrada:** changelog com tag `[BREAKING]` se afeta inputs/outputs públicos
- **IDs nunca são reciclados** — entrada removida vira `[DEPRECATED]` mantendo o ID
- Cada entrada referencia exatamente **uma seção primária** da NBR; cross-refs vão em "Dependências"

---

## Sumário

1. [Domínio compartilhado (D-N)](#1-domínio-compartilhado)
2. [Tabelas normativas (T-N)](#2-tabelas-normativas)
3. [Classificações (C-N)](#3-classificações)
4. [Procedures (P-N)](#4-procedures)
5. [Specifications (S-N)](#5-specifications)
6. [Verifications (V-N)](#6-verifications)
7. [Mapa por fase do roadmap](#7-mapa-por-fase)

---

## 1. Domínio compartilhado

### D-1 — `EscopoProjeto`
**NBR ref:** transversal
**Valores:** `RESIDENCIAL` | `COMERCIAL` | `INDUSTRIAL`
**Notas:** entrada raiz que governa quais Specifications são `aplicaveisA(perfil)` e qual Procedure de carga é despachada via Strategy.

### D-2 — `Isolacao`
**NBR ref:** 6.2.3.2 + Tab. 35
**Valores:** `PVC` (70 °C) | `XLPE` (90 °C) | `EPR` (90 °C)
**Notas:** Temperatura de serviço contínuo determina k em curto-circuito (T-9).

### D-3 — `Arquitetura`
**NBR ref:** 6.2.3.3
**Valores:** `CONDUTOR_ISOLADO` | `CABO_UNIPOLAR` | `CABO_MULTIPOLAR`

### D-4 — `MaterialCondutor`
**NBR ref:** 6.2.3.7 / 6.2.3.8
**Valores:** `COBRE` | `ALUMINIO`
**Restrições:** alumínio sujeito a S-2.

### D-5 — `MetodoInstalacao`
**NBR ref:** Tab. 33 + Anexo NA (referência à IEC 60364-5-52)
**Valores:** `A1` | `A2` | `B1` | `B2` | `C` | `D` | `E` | `F` | `G`
**Notas:** Cada método tem tabela de ampacidade própria (T-2 a T-5).

### D-6 — `EsquemaAterramento`
**NBR ref:** 4.2.2.2
**Valores:** `TN_S` | `TN_C` | `TN_C_S` | `TT` | `IT`
**Notas:** Define tempos máximos de seccionamento (T-10, T-11) e cálculo de Zs.

### D-7 — `OrigemAlimentacao`
**NBR ref:** 6.2.7.1
**Valores:** `ENTREGA` (limite ΔU 5 %) | `PROPRIO` (limite ΔU 7 %)
**Notas:** Trafo/gerador próprio admite 3 % no alimentador vs. 1 % na entrega.

### D-8 — `TagCircuito`
**NBR ref:** transversal (9.5.3, 4.2.5)
**Valores:** `IL` | `TUG` | `TUE` | `MED` | `QDG` | `QD`
**Notas:** Terminais (`IL`, `TUG`, `TUE`) limitam ΔU a 4 %. Alimentadores (`MED`, `QDG`, `QD`) submetidos a regra de origem (D-7).

### D-9 — Resultados

```
Violacao { codigo: string; severidade: ERRO|AVISO; mensagem: string; ref: string }
ResultadoNormativo { ampacidade: double; secaoFase: double; secaoNeutro: double;
                     secaoPe: double; quedaTensaoPercent: double; ... }
ResultadoEnsaio    { valorMedido: double; limite: double; aprovado: bool; ref: string }
PerfilInstalacao   { escopo: D-1; aterramento: D-6; origem: D-7;
                     codigosInfluencia: Map<Familia, Codigo>; ... }
```

---

## 2. Tabelas normativas

### T-1 — Combinações Arquitetura × Método
**NBR ref:** Tab. 33

| Método | Isolado | Unipolar | Multipolar |
|---|:-:|:-:|:-:|
| A1 | ✓ | ✓ | ✓¹ |
| A2 | ✗ | ✗ | ✓ |
| B1 | ✓ | ✓ | ✓¹ |
| B2 | ✓¹ | ✓¹ | ✓ |
| C | ✗ | ✓ | ✓ |
| D | ✗ | ✓ | ✓ |
| E | ✗ | ✗ | ✓ |
| F | ✗ | ✓ | ✗ |
| G | ✓ | ✓ | ✗ |

¹ = exceções com método físico distinto (51, 43, 26, 23/25/27 IEC 60364-5-52). Para implementação inicial, tratar como permitido.

### T-2 — Ampacidade Métodos A1/A2/B1/B2 (Cu, PVC, 30 °C)
**NBR ref:** Tab. 36 (cobre, PVC)
**Estrutura:** `Map<(Metodo, NumCondutoresCarregados), Map<Secao_mm2, Ampacidade_A>>`
**Notas:**
- Já implementado em `tables/tabela_36*.dart`
- Para EPR/XLPE 90 °C, **multiplicar valores** pelo fator da Tab. 36 (correção interna)
- Valores de referência: 1,5 mm² Cu PVC método B1 = 17,5 A; 2,5 mm² = 24 A; 4 mm² = 32 A

### T-3 — Ampacidade Método C (Cu, PVC, 30 °C)
**NBR ref:** Tab. 37 — já implementado

### T-4 — Ampacidade Método D (Cu, enterrado, 30 °C, ρ 2,5 K·m/W, prof. 0,7 m)
**NBR ref:** Tab. 38 — já implementado

### T-5 — Ampacidade Métodos E/F/G (Cu, ar livre, 30 °C)
**NBR ref:** Tab. 39 — já implementado

### T-6 — Fator de correção temperatura ambiente
**NBR ref:** Tab. 40
**Estrutura:** `Map<(IsolacaoBase: PVC|EPR/XLPE, TempAmbiente_C, MetodoCategoria: AR|SOLO), Fator>`
**Valores-chave:**
- PVC, ar, 30 °C → 1,00 (referência)
- PVC, ar, 40 °C → 0,87
- PVC, ar, 50 °C → 0,71
- EPR/XLPE, ar, 30 °C → 1,00
- EPR/XLPE, ar, 50 °C → 0,82
- PVC, solo, 20 °C → 1,00 (referência para método D)
- PVC, solo, 30 °C → 0,89

### T-7 — Fator de correção agrupamento (cabos justapostos, mesma camada)
**NBR ref:** Tab. 42
**Estrutura:** `Map<NumCircuitos, Fator>`
**Valores:** 1→1,00 / 2→0,80 / 3→0,70 / 4→0,65 / 6→0,57 / 9→0,50 / ≥20→0,38

### T-8 — Fator de correção agrupamento (cabos enterrados)
**NBR ref:** Tab. 44 (mesmo eletroduto enterrado) e 45 (em vala, separados)
**Notas:** Estrutura por número de circuitos × espaçamento

### T-9 — Coeficiente k para curto-circuito (k²S²)
**NBR ref:** Tab. 30
**Estrutura:** `Map<(MaterialCondutor, Isolacao), k_value>`

| Material | PVC ≤300mm² | PVC >300mm² | EPR/XLPE |
|---|:-:|:-:|:-:|
| Cobre | 115 | 103 | 143 |
| Alumínio | 76 | 68 | 94 |

**Uso:** I²t do disjuntor ≤ k² × S² (5.3.5.5.2)

### T-10 — Tempos máximos de seccionamento — esquema TN
**NBR ref:** Tab. 25
**Estrutura:** `Map<TensaoNominal_V, TempoMax_s>`

| Uo (V) | Tempo máximo |
|---|---|
| 120 | 0,8 s |
| 230 | 0,4 s |
| 400 | 0,2 s |
| > 400 | 0,1 s |

### T-11 — Tempos máximos de seccionamento — esquemas TT/IT
**NBR ref:** Tab. 26
**Estrutura:** `Map<TensaoNominal_V, TempoMax_s>`

| Uo (V) | TT | IT |
|---|---|---|
| 120 | 0,3 s | 0,8 s |
| 230 | 0,2 s | 0,4 s |
| 400 | 0,07 s | 0,2 s |

### T-12 — Seção do PE proporcional à fase
**NBR ref:** Tab. 54

| Seção fase S (mm²) | Seção PE (mm²) |
|---|---|
| S ≤ 16 | S |
| 16 < S ≤ 35 | 16 |
| S > 35 | S/2 |

### T-13 — Carga mínima iluminação por cômodo
**NBR ref:** 9.5.2.1
**Fórmula:**
```
Se A ≤ 6 m²:           carga = 100 VA
Se A > 6 m²:           carga = 100 + 60 × floor((A - 6) / 4)   [VA]
```

### T-14 — Potência mínima por TUG
**NBR ref:** 9.5.2.2

| Local | Até 3 pontos | Excedentes |
|---|---|---|
| Banheiro/cozinha/copa/lavanderia/área serviço | 600 VA | 100 VA |
| Demais cômodos | 100 VA | 100 VA |

**Edge case:** Quando soma > 6 pontos nos locais "molhados", limitar 600 VA aos 2 primeiros + 100 VA nos demais.

### T-15 — Faixas de tensão
**NBR ref:** Anexo A normativo

| Faixa | CA fase-neutro | CA fase-fase |
|---|---|---|
| Extra-baixa (I) | ≤ 50 V | ≤ 50 V |
| Baixa (II — coberta pela 5410) | 50 < U ≤ 600 V | 50 < U ≤ 1000 V |
| Alta (III — fora) | > 600 V | > 1000 V |

### T-16 — Categorias de sobretensão (placeholder Fase 6)
**NBR ref:** 5.4 + Anexo E informativo

| Categoria | Suportabilidade impulso (1,2/50 µs) | Aplicação |
|---|---|---|
| I | 1,5 kV | equipamento eletrônico sensível |
| II | 2,5 kV | equipamento doméstico |
| III | 4 kV | quadros e fiação fixa |
| IV | 6 kV | medidor, ramal de entrada |

### T-17 — Fator de correção neutro com harmônicas (placeholder Fase 7)
**NBR ref:** Anexo F normativo

| Taxa de 3ª harmônica | Fator neutro fh |
|---|---|
| 0–15 % | 1,0 |
| 15–33 % | 1,15 |
| 33–45 % | 1,45 (limita-se pelo neutro) |
| > 45 % | proteger pelo neutro; fh ≈ 1,4 (S_neutro = 1,45·S_fase) |

### T-18 — Resistência mínima de isolamento (placeholder Fase 8)
**NBR ref:** Tab. 60 (verificação)

| Tensão nominal (V) | Tensão de ensaio (V) | R mínimo (MΩ) |
|---|---|---|
| SELV/PELV | 250 | 0,5 |
| ≤ 500 | 500 | 1,0 |
| > 500 | 1000 | 1,0 |

---

## 3. Classificações

### C-1 — `class_perfil_padrao_por_escopo`
**NBR ref:** transversal — derivada de 4.2.6 (influências externas)
**Aplicabilidade:** Fase 6+
**Inputs:** `EscopoProjeto`
**Output:** `Map<FamiliaInfluencia, CodigoInfluencia>` (perfil padrão)
**Algoritmo:**

| Escopo | BA | BD | BE | CA | IP típico |
|---|---|---|---|---|---|
| RESIDENCIAL | BA1 (leigo) | BD1 (baixa, fuga curta) | BE1 (sem risco) | CA1/CA2 | IP20 interno, IPX4 banheiro |
| COMERCIAL | BA1 (público) | BD2/BD3 | BE1 (geral) | CA1 | IP20/IP44 |
| INDUSTRIAL | BA4/BA5 (advertido/qualificado) | BD1 | BE2/BE3 (depende processo) | CA1 | IP54+ |

**Notas:** Perfil é sobrescrevível pela UI quando o usuário refinar.

### C-2 — `class_esquema_aterramento`
**NBR ref:** 4.2.2.2
**Aplicabilidade:** Fase 3
**Inputs:** descrição da alimentação (origem, condutor neutro vs. PE separados)
**Output:** `EsquemaAterramento` (TN-S, TN-C, TN-C-S, TT, IT)
**Notas:** No Brasil: TT é típico residencial; TN-S em prédios modernos; TN-C-S após o ponto de entrada; IT em hospitalar/industrial sensível.

### C-3 — `class_situacao_choque`
**NBR ref:** Anexo C normativo (combinações BB e BC)
**Aplicabilidade:** Fase 3
**Inputs:** `BB` (resistência elétrica do corpo) × `BC` (contato com potencial de terra)
**Output:** `SituacaoChoque` ∈ {1, 2, 3}
**Algoritmo:**
- Situação 1: BB1+BC1, BB1+BC2, BB2+BC1 → UL = 50 V
- Situação 2: BB1+BC3, BB2+BC2, BB3+BC1 → UL = 25 V
- Situação 3: BB2+BC3, BB3+BC2, BB4+BC1, e mais críticas → UL = 12 V

**Uso:** UL alimenta T-10/T-11 e S-7.

### C-4 — `class_volume_banheiro`
**NBR ref:** 9.1
**Aplicabilidade:** Fase 4
**Inputs:** distância ao chuveiro/banheira (cm), altura (cm)
**Output:** `Volume` ∈ {V0, V1, V2, V3}
**Algoritmo:**
- V0: interior da banheira/box
- V1: até 60 cm do bocal/limite do box, até 225 cm de altura
- V2: 60–60 cm além de V1 (extensão lateral 60 cm)
- V3: 60 cm além de V2

**IP por volume:** V0 IPX7 / V1 IPX4 (IPX5 se chuveiro) / V2 IPX4 / V3 IPX1 (IPX5 se chuveiro coletivo)

### C-5 — `class_categoria_sobretensao` (placeholder Fase 6)
**NBR ref:** 5.4 + Anexo E
**Inputs:** posição na instalação (entrada, distribuição, terminal, sensível)
**Output:** Categoria ∈ {I, II, III, IV}

---

## 4. Procedures

### P-1 — `proc_ampacidade`
**NBR ref:** 6.2.5
**Aplicabilidade:** Fase 1 (já implementado, refinar com fatores T-7/T-8)
**Inputs:** `Metodo`, `Isolacao`, `Material`, `Secao_mm2`, `NumCarregados`, `TempAmbiente`, `NumCircuitosAgrupados`, `EnterradaSimNao`, `ResistividadeSolo`
**Output:** `double` — ampacidade ajustada [A]
**Algoritmo:**
```
Iz_base = lookup(T-2 a T-5)[método, isolação, material, seção, num_carregados]
fT      = lookup(T-6)[isolação, temp_ambiente, ar|solo]
fA      = lookup(T-7 ou T-8)[num_circuitos]
Iz      = Iz_base × fT × fA
return Iz
```
**Edge cases:**
- Cabo enterrado em ρ ≠ 2,5 K·m/W: aplicar fator adicional Tab. 41/45
- Profundidade ≠ 0,7 m: Tab. 46/47
- Misturas de seções: aplicar fator a partir do menor cabo

### P-2 — `proc_queda_tensao`
**NBR ref:** 6.2.7
**Aplicabilidade:** Fase 1 (refinar com Xi)
**Inputs:** `IB [A]`, `L [m]`, `R_Ohm_km`, `X_Ohm_km`, `cos_phi`, `tipoCircuito` (mono/bi/tri), `tensao [V]`
**Output:** `double` — ΔU em percentual
**Fórmula:**
```
Trifásico: ΔU = √3 × IB × (L/1000) × (R × cos_φ + X × sin_φ)
Monofásico/bifásico: ΔU = 2 × IB × (L/1000) × (R × cos_φ + X × sin_φ)
ΔU% = (ΔU / U_nominal) × 100
```
**Edge cases:**
- Sem reatância (Xi = 0): aceitável para S < 35 mm²; conservador para maiores
- cos_φ default: 0,8 indutivo (motor) / 0,92 (residencial misto)

### P-3 — `proc_secao_neutro`
**NBR ref:** 6.2.6
**Aplicabilidade:** Fase 1 (substitui proxy `secaoFase`)
**Inputs:** `tipoCircuito` (mono/bi/tri), `secaoFase`, `materialCondutor`, `taxaHarmonicas` (Fase 7+)
**Output:** `double` — secaoNeutro [mm²]
**Algoritmo:**
```
SE monofásico (2 fios):
   secaoNeutro = secaoFase
SE bifásico OU (trifásico E secaoFase ≤ 16 mm² Cu OU 25 mm² Al):
   secaoNeutro = secaoFase
SE trifásico E secaoFase > 16 mm² Cu OU > 25 mm² Al:
   SE cargas equilibradas E sem harmônicas significativas:
      secaoNeutro = max(16 Cu / 25 Al, calculado_para_corrente_desequilíbrio)
   SE cargas com harmônicas (3ª e múltiplas) > 15 %:
      aplicar T-17 (Anexo F): secaoNeutro = secaoFase × fh
```

### P-4 — `proc_secao_pe`
**NBR ref:** 6.4.3 + Tab. 54
**Aplicabilidade:** Fase 3
**Inputs:** `secaoFase`, `materialCondutor`, `materialPe` (mesmo da fase ou diferente)
**Output:** `double` — secaoPe [mm²]
**Algoritmo (Tab. 54 — quando PE é do mesmo material da fase):**
```
SE secaoFase ≤ 16:   secaoPe = secaoFase
SE 16 < secaoFase ≤ 35: secaoPe = 16
SE secaoFase > 35:   secaoPe = secaoFase / 2
```
**Algoritmo alternativo (fórmula térmica, quando Tab. 54 não se aplica):**
```
secaoPe = √(I² × t) / k        [I = corrente de falta presumida, t = tempo, k = T-9]
```

### P-5 — `proc_corrente_curto_circuito` (Fase 5)
**NBR ref:** Anexo K normativo
**Inputs:** impedância da fonte (Zs trafo + linha), impedância da malha do circuito
**Output:** `Icc_max` (no barramento) e `Icc_min` (na extremidade)
**Fórmula simplificada:**
```
Icc_max = (c × U_n) / (√3 × Z_min)        [c = 1,05 → fonte forte]
Icc_min = (c × U_n) / (√3 × Z_max)        [c = 0,95 → falta no fim do circuito]
Z_circuito = R + jX  com  R = ρ × L/S × 2  (fase + retorno PE)
```

### P-6 — `proc_carga_residencial`
**NBR ref:** 9.5.2
**Aplicabilidade:** Fase 1 (já implementado)
**Inputs:** lista de cômodos com `tipo`, `area_m2`, `perimetro_m`
**Output:** lista de pontos (IL, TUG) com VA atribuído

### P-7 — `proc_carga_comercial` (Fase 6)
**NBR ref:** 4.2.1
**Inputs:** lista de ambientes com função + lista de equipamentos especiais
**Output:** potência instalada × fator demanda → potência demandada
**Notas:** Fatores de demanda dependem do tipo de estabelecimento. ABNT remete a literatura técnica complementar (ex: NTE da concessionária).

### P-8 — `proc_carga_industrial` (Fase 7)
**NBR ref:** 4.2.1 + 6.5.1
**Inputs:** lista nominal de equipamentos com `In_placa`, `regime` (S1–S8), `fator_utilizacao`
**Output:** demanda total + demanda por barramento
**Notas:** Considerar simultaneidade conforme processo.

### P-9 — `proc_corrente_partida_motor` (Fase 7)
**NBR ref:** 6.5.1
**Inputs:** `In_motor`, `classePartida` (B/C/D), método de partida (direta/estrela-triângulo/soft-starter)
**Output:** `Ip` (corrente de partida) e duração estimada
**Valores típicos:**
- Classe B: Ip = 7,5 × In, partida direta 5–10 s
- Classe C: Ip = 7 × In
- Classe D: Ip = 8 × In, partida pesada
- Estrela-triângulo: Ip ≈ Ip_direta / 3

### P-10 — `proc_fator_demanda` (Fase 6)
**NBR ref:** 4.2.1
**Notas:** A NBR não tabela fatores; remete a normas complementares e literatura. Para o engine, expor como **parâmetro de entrada** com defaults sugeridos por tipo de uso.

---

## 5. Specifications

### S-1 — `spec_combinacoes`
**NBR ref:** 6.2.3 + Tab. 33
**Aplicabilidade:** Fase 1 (já implementado)
**Inputs:** `Isolacao`, `Arquitetura`, `MetodoInstalacao`
**Output:** `List<Violacao>`
**Validações:**
1. Combinação Isolação × Arquitetura admitida (PVC/XLPE/EPR × isolado/uni/multi)
2. Combinação Arquitetura × Método admitida (T-1)

### S-2 — `spec_aluminio`
**NBR ref:** 6.2.3.8
**Aplicabilidade:** Fase 1 (já implementado)
**Inputs:** `MaterialCondutor`, `BD` (código de fuga em emergência), `Secao_mm2`, `EscopoProjeto`
**Output:** `List<Violacao>`
**Validações:**
1. SE material == ALUMINIO E BD == BD4 → violação ERRO "alumínio proibido em BD4"
2. SE material == ALUMINIO E escopo == INDUSTRIAL E secao < 16 → violação
3. SE material == ALUMINIO E escopo == COMERCIAL_BD1 E secao < 50 → violação

### S-3 — `spec_sobrecarga`
**NBR ref:** 5.3.4.1
**Aplicabilidade:** Fase 1 (já implementado)
**Inputs:** `IB`, `In`, `Iz`
**Output:** `List<Violacao>`
**Validações:**
1. IB ≤ In (V1) → senão violação ERRO "disjuntor subdimensionado"
2. In ≤ Iz (V2) → senão violação ERRO "disjuntor sobre-dimensionado"
3. I2 ≤ 1,45 × Iz, com I2 = 1,45 × In → automaticamente satisfeito quando V2 vale (NBR 5410, Nota da 5.3.4.1)

### S-4 — `spec_secao_minima_absoluta`
**NBR ref:** 6.2.6.1.1 + Tab. 47
**Aplicabilidade:** Fase 1 / refinar Fase 3
**Validações por `TagCircuito`:**
- IL → S ≥ 1,5 mm² Cu
- TUG → S ≥ 2,5 mm² Cu
- TUE → S ≥ 2,5 mm² Cu
- Sinalização/comando → S ≥ 0,5 mm²
- Alimentadores → conforme cálculo + restrições do alumínio

### S-5 — `spec_queda_tensao`
**NBR ref:** 6.2.7.1
**Aplicabilidade:** Fase 1 (já implementado)
**Inputs:** `tagCircuito`, `origemAlimentacao`, `quedaCalculadaPercent`, `quedaTotalPercent`
**Output:** `List<Violacao>`
**Limites:**
- Terminal: ΔU ≤ 4 %
- Alimentador, origem == ENTREGA: ΔU próprio ≤ 1 %, total ≤ 5 %
- Alimentador, origem == PROPRIO: ΔU próprio ≤ 3 %, total ≤ 7 %

### S-6 — `spec_dispositivo_multipolar`
**NBR ref:** 9.5.4
**Aplicabilidade:** Fase 1
**Inputs:** `numFases` do circuito, tipo do dispositivo de proteção
**Validações:**
- SE numFases > 1 E dispositivo == UNIPOLAR (mesmo "acoplado mecanicamente") → violação

### S-7 — `spec_seccionamento_automatico`
**NBR ref:** 5.1.2.2.4
**Aplicabilidade:** Fase 3
**Inputs:** `EsquemaAterramento`, `Uo`, `Zs` (impedância da malha de falta), `Ia` (corrente de atuação do dispositivo)
**Output:** `List<Violacao>`
**Validação:**
```
Zs × Ia ≤ Uo                    (condição fundamental)
tempoAtuacao ≤ T-10 ou T-11     (conforme esquema e Uo)
```

### S-8 — `spec_dr_obrigatorio`
**NBR ref:** 5.1.3.2.2
**Aplicabilidade:** Fase 3
**Inputs:** `tipoComodo`, `usoCircuito`, `correnteNominalDR`
**Output:** `List<Violacao>`
**Regra:** DR ≤ 30 mA obrigatório quando o circuito atende:
- Banheiro com chuveiro/banheira (9.1)
- Cozinha, copa, lavanderia, área de serviço, garagem
- Tomadas em área externa
- Tomadas internas que possam alimentar equipamento externo
- Aplicação para tomadas com `In ≤ 32 A`

### S-9 — `spec_circuito_independente`
**NBR ref:** 9.5.3.1
**Aplicabilidade:** Fase 1 (já implementado, residencial)
**Regra:** equipamento com `In > 10 A` (≈ 2200 VA em 220 V monofásico) deve ter circuito próprio.

### S-10 — `spec_circuito_exclusivo_molhados`
**NBR ref:** 9.5.3.2
**Regra:** tomadas de cozinha, copa, lavanderia, área de serviço em circuito **exclusivo de tomadas** desses locais.

### S-11 — `spec_circuito_misto`
**NBR ref:** 9.5.3.3
**Regra:** mistura IL+TUG admitida quando:
- IB ≤ 16 A
- IL não é atendida integralmente por um único circuito misto
- TUG (excl. molhados) também não é

### S-12 — `spec_minimo_pontos_il`
**NBR ref:** 9.5.2.1.1 + 9.5.2.1.2
**Regra:** mínimo 1 ponto de luz fixo no teto por cômodo, com interruptor de parede. Carga conforme T-13.

### S-13 — `spec_minimo_pontos_tug`
**NBR ref:** 9.5.2.2.1 + 9.5.2.2.2 + 9.5.2.2.5
**Quantidades mínimas:**

| Local | Critério |
|---|---|
| Banheiro | ≥ 1 próximo ao lavatório (≥ 60 cm do box) |
| Cozinha/copa/lavanderia/área serviço | ≥ 1 a cada 3,5 m perímetro; ≥ 2 acima da pia |
| Varanda | ≥ 1 |
| Salas e dormitórios | ≥ 1 a cada 5 m perímetro |
| Outros ≤ 2,25 m² | ≥ 1 (admite externo até 0,80 m da porta) |
| Outros 2,25–6 m² | ≥ 1 |
| Outros > 6 m² | ≥ 1 a cada 5 m perímetro |

**Potência:** conforme T-14.

### S-14 — `spec_curto_circuito` (Fase 5)
**NBR ref:** 5.3.5.5
**Validações:**
1. Capacidade de interrupção do dispositivo ≥ Icc_max no ponto (5.3.5.5.1)
2. I²t do dispositivo ≤ k² × S² (5.3.5.5.2)
3. Tempo de atuação compatível com curva característica

### S-15 — `spec_volumes_banheiro` (Fase 4)
**NBR ref:** 9.1.4
**Validações:** equipamentos por volume

| Volume | Equipamentos admissíveis |
|---|---|
| V0 | Apenas equipamentos SELV ≤ 12 V especificamente para volume 0 |
| V1 | Aquecedores fixos para esse uso (inclui chuveiro), SELV ≤ 12 V |
| V2 | Tomadas SELV ≤ 12 V; iluminação Classe II; aquecedores fixos |
| V3 | Tomadas comuns protegidas por DR ≤ 30 mA |

### S-16 — `spec_dps_obrigatorio` (Fase 6)
**NBR ref:** 5.4.2
**Regra:** DPS obrigatório quando:
- Linha de alimentação parcialmente aérea, OU
- Edificação com SPDA (NBR 5419), OU
- Atividade implica AQ2 ou AQ3 (frequência alta de descargas)

**Classes:** I (junto à entrada se exposição direta), II (após I, em quadro de distribuição), III (proteção fina junto a equipamento sensível).

### S-17 — `spec_motor` (Fase 7)
**NBR ref:** 6.5.1
**Regra:** dimensionamento considerando:
- Corrente nominal × fator de utilização
- Corrente de partida (P-9) — disjuntor curva D ou MPCB
- Proteção contra falta de fase
- Regime de operação (S1 contínuo permite Iz = In; S2/S3 admitem Iz < In)

### S-18 — `spec_neutro_harmonicas` (Fase 7)
**NBR ref:** Anexo F
**Regra:** trifásico com taxa 3ª harmônica > 15 % → neutro reforçado conforme T-17.

### S-19 — `spec_paralelos` (Fase 7)
**NBR ref:** Anexo D
**Regras:**
- Mesmo material, mesma seção, mesmo comprimento, mesma disposição
- Conexões equivalentes em ambos os extremos
- Ampacidade total = soma das ampacidades individuais com **fator de agrupamento aplicado**

### S-20 — `spec_secao_pe` (Fase 3)
**NBR ref:** 6.4.3
**Regra:** secaoPe = T-12 OU fórmula térmica (P-4), o que for maior.

### S-21 — `spec_equipotencializacao_principal` (Fase 3)
**NBR ref:** 6.4.4
**Regra:** BEP (barramento de equipotencialização principal) deve interconectar:
- PE da entrada
- Tubulações metálicas (água, gás)
- Estrutura metálica do edifício
- Sistema de aterramento principal

### S-22 — `spec_equipotencializacao_suplementar` (Fase 3)
**NBR ref:** 6.4.5
**Regra:** obrigatória em banheiros (9.1.5), cozinhas, áreas BD3/BD4. Conecta partes condutivas expostas + extrínsecas + PE local.

---

## 6. Verifications (Fase 8)

### V-1 — `verify_continuidade_pe`
**NBR ref:** 7.3.2
**Método:** fonte CC ou CA 4–24 V, corrente ≥ 0,2 A. Critério: continuidade verificada (resistência baixa, valores típicos de poucos Ω).

### V-2 — `verify_resistencia_isolamento`
**NBR ref:** 7.3.3 + T-18
**Método:** megôhmetro CC. Tensão e R mínimo conforme T-18.

### V-3 — `verify_seccionamento_automatico`
**NBR ref:** 7.3.5
**Método:** medição de Zs no ponto mais distante; verificar Zs × Ia ≤ Uo (S-7).

### V-4 — `verify_dr`
**NBR ref:** 7.3.7 + Anexo H normativo
**Métodos disponíveis (1, 2, 3 do Anexo H):** todos verificam atuação dentro de 30 ms a IΔn × 5 e dentro de 300 ms a IΔn nominal.

### V-5 — `verify_resistencia_aterramento`
**NBR ref:** Anexo J
**Critério:** RA × IΔn ≤ UL (Tab. 25/26 conforme situação de choque, C-3).

### V-6 — `verify_resistencia_pe`
**NBR ref:** Anexo L

### V-7 — `verify_tensao_aplicada`
**NBR ref:** Anexo M

---

## 7. Mapa por fase

| Fase | Versão | Domínio | Tabelas | Classifications | Procedures | Specifications | Verifications |
|---|---|---|---|---|---|---|---|
| 1 | 0.4.0 | D-1, D-2, D-3, D-4, D-5, D-7, D-8, D-9 | T-1 a T-8 | — | P-1, P-2, P-3, P-6 | S-1, S-2, S-3, S-4, S-5, S-6, S-9, S-10, S-11, S-12, S-13 | — |
| 2 | 0.5.0 | D-1 (extender), D-9 | — | — (formalizar) | — (refactor) | — (refactor + `aplicavelA`) | (interface vazia) |
| 3 | 0.6.0 | D-6 | T-10, T-11, T-12 | C-2, C-3 | P-4 | S-7, S-8, S-20, S-21, S-22 | — |
| 4 | 0.7.0 | — | refinar T-15? | C-4 | — | S-15 + piscina + sauna | — |
| 5 | 0.8.0 | — | T-9 | — | P-5 | S-14 | — |
| 6 | 0.9.0 | — | T-16 | C-1 (RES + COM), C-5 | P-7, P-10 | S-16 + iluminação emergência + alimentação coletiva | — |
| 7 | 0.10.0 | — | T-17 | C-1 (estende IND) | P-8, P-9 | S-17, S-18, S-19 + compartimento condutivo + falta tensão + equipotencialização funcional | — |
| 8 | 0.11.0 | — | T-18 | — | — | — | V-1 a V-7 |
| 9 | 1.0.0 | — | refinar todas | refinar todas | refinar todas | refinar todas | refinar todas |

---

## Apêndice A — Como crescer este documento

Para complementar entradas marcadas como placeholder/Fase futura:

1. Quando a fase entrar em planejamento, abrir a seção da NBR correspondente
2. Preencher os campos da entrada (Inputs, Output, Algoritmo, Edge cases)
3. Incrementar REV no header
4. Registrar no changelog: `[Rev N] - data - DETAIL: <ID>: detalhamento de algoritmo + edge cases`
5. Se a entrada for nova (sem placeholder anterior), `[Rev N] - data - ADD: <ID>`

## Apêndice B — Convenção de cross-reference NBR no código Dart

Cada arquivo do `normative_engine` deve abrir com:

```dart
/// **NBR 5410:2004 — <seção>**
///
/// Manual: <ID> (ex: S-3)
/// <descrição curta>
///
/// Dependências: <IDs>
class SpecSobrecarga implements ISpecification { ... }
```

Isso fecha o ciclo: PDF → Manual → Código, com rastreabilidade bidirecional.
