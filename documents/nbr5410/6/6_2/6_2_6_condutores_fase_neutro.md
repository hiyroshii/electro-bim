# NBR 5410 — 6.2.6 Condutores de Fase e Condutor Neutro

**Norma:** ABNT NBR 5410:2004
**Seção:** 6.2.6 (agrupa 6.2.6.1 e 6.2.6.2)
**Tabelas:** 47, 48

---

## 6.2.6.1 Seção dos Condutores de Fase

### 6.2.6.1.1 — Seção Mínima (Tabela 47)

A seção dos condutores de fase (CA) e dos condutores vivos (CC) não deve ser inferior aos valores da Tabela 47.

### Tabela 47 — Seção Mínima dos Condutores

| Tipo de Linha | Utilização | Seção Mínima (mm²) | Material |
| :--- | :--- | :---: | :---: |
| **Instalações fixas — condutores e cabos isolados** | Circuitos de iluminação | 1,5 | Cu |
| | Circuitos de iluminação | 16 | Al |
| | Circuitos de força ¹⁾ (inclui tomadas) | 2,5 | Cu |
| | Circuitos de força | 16 | Al |
| | Circuitos de sinalização e controle | 0,5 | Cu ²⁾ |
| **Condutores nus — instalações fixas** | Circuitos de força | 10 | Cu |
| | Circuitos de força | 16 | Al |
| | Circuitos de sinalização e controle | 4 | Cu |
| **Linhas flexíveis (cabos isolados)** | Para equipamento específico | Conforme norma do equipamento | — |
| | Qualquer outra aplicação | 0,75 | Cu |
| | Circuitos a extrabaixa tensão para aplicações especiais | 0,75 | Cu |

**Notas:**
1. Circuitos de tomadas de corrente são considerados circuitos de força.
2. Em circuitos de sinalização para equipamentos eletrônicos: mínimo de **0,1 mm²**.
3. Em cabos multipolares flexíveis com **7 ou mais veias**: mínimo de **0,1 mm²**.

### 6.2.6.1.2 — Critérios de Dimensionamento

A seção deve ser determinada atendendo **simultaneamente**:

a) Ampacidade ≥ corrente de projeto (incluindo harmônicas), com os fatores de correção aplicáveis (ver 6.2.5);
b) Proteção contra sobrecargas (5.3.4 e 6.3.4.2);
c) Proteção contra curtos-circuitos e solicitações térmicas (5.3.5 e 6.3.4.3);
d) Proteção contra choques — seccionamento automático em TN e IT (5.1.2.2.4);
e) Limites de queda de tensão (6.2.7);
f) Seções mínimas da Tabela 47.

---

## 6.2.6.2 Condutor Neutro

### 6.2.6.2.1
O condutor neutro **não pode ser comum a mais de um circuito**.

### 6.2.6.2.2
O condutor neutro de circuito **monofásico** deve ter a **mesma seção do condutor de fase**.

### 6.2.6.2.3 — Taxa de 3ª Harmônica entre 15% e 33%
Em circuito trifásico com neutro, quando a taxa de 3ª harmônica e múltiplos for **> 15%**, a seção do neutro **não deve ser inferior à das fases**.

Pode ser igual à das fases se a taxa **não for superior a 33%**.

> Níveis > 15%: presentes em circuitos com luminárias de descarga, incluindo fluorescentes.

### 6.2.6.2.4 — Circuito Duas Fases + Neutro
Idem 6.2.6.2.3: seção do neutro não inferior à das fases; pode ser igual se taxa ≤ 33%.

### 6.2.6.2.5 — Taxa de 3ª Harmônica > 33%
Pode ser necessário neutro com seção **superior à das fases**.

> Ocorre em circuitos que alimentam principalmente computadores ou equipamentos de TI. Ver Anexo F para dimensionamento.

### 6.2.6.2.6 — Redução da Seção do Neutro (Tabela 48)

Em circuito trifásico com fases **> 25 mm²**, o neutro pode ter seção reduzida se as **três condições** forem atendidas simultaneamente:

a) Circuito presumivelmente equilibrado em serviço normal;
b) Taxa de 3ª harmônica e múltiplos **≤ 15%**;
c) Neutro protegido contra sobrecorrentes conforme 5.3.2.2.

### Tabela 48 — Seção Reduzida do Condutor Neutro

*Aplicável quando os condutores de fase e neutro são do mesmo metal.*

| Seção das Fases (mm²) | Seção Mínima do Neutro (mm²) |
| :---: | :---: |
| ≤ 25 | Igual às fases (sem redução) |
| 35 | 25 |
| 50 | 25 |
| 70 | 35 |
| 95 | 50 |
| 120 | 70 |
| 150 | 70 |
| 185 | 95 |
| 240 | 120 |
| 300 | 150 |
| 400 | 185 |

---
*Referência: ABNT NBR 5410:2004 — Seção 6.2.6, Tabelas 47 e 48*
