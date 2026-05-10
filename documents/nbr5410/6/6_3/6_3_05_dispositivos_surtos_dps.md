# NBR 5410 — 6.3.5 Dispositivos de proteção contra surtos (DPS)

**Norma:** ABNT NBR 5410:2004
**Subseção:** 6.3.5
**Pertence a:** `6_3_dispositivos_protecao.md`
**Tabelas relacionadas:**
- `6_3_5_tabela49_tensao_operacao_continua_dps.md`
- `6_3_5_tabela50_tensao_impulso_suportavel.md`

---

## 6.3.5 Dispositivos de proteção contra surtos (DPS)

### 6.3.5.1 Generalidades

Trata da seleção e instalação de DPS para proteção contra sobretensões transitórias em linhas de energia e de sinal.

### 6.3.5.2 Proteção em linhas de energia

**6.3.5.2.1 Uso e localização**  
Quando exigidos (5.4.2.1.1), os DPS devem ser instalados:
- Junto ao ponto de entrada da linha ou no quadro de distribuição principal (proteção contra descargas atmosféricas transmitidas pela linha e sobretensões de manobra).
- No ponto de entrada da linha (descargas diretas sobre a edificação ou proximidades).

> **NOTA 1:** Ver definição de “ponto de entrada” (3.4.4).
> **NOTA 2:** Em instalações existentes individuais atendidas em BT, admite‑se DPS junto à caixa de medição, com barra PE interligada ao BEP (distância ≤ 10 m do ponto de entrada).
> **NOTA 3:** DPS adicionais podem ser necessários para equipamentos sensíveis, devendo ser coordenados com os de montante/jusante (ver 6.3.5.2.4‑f)).
> **NOTA 4:** DPS não alojados em quadros devem ter sua presença indicada por etiqueta na origem do circuito.

**6.3.5.2.2 Instalação no ponto de entrada ou QD principal**  
Devem ser dispostos no mínimo como mostra a Figura 13 da norma (esquemas de conexão 1, 2 e 3). As conexões dependem do esquema de aterramento (TN‑C, TN‑S, TT, IT com ou sem neutro).

**6.3.5.2.3 Conexão em pontos ao longo da instalação**  
Seguir a mesma orientação da Figura 13:
- TN‑S / TT com neutro / IT com neutro: esquema 2 (cada fase‑PE e neutro‑PE) ou 3 (cada fase‑neutro e neutro‑PE).
- Circuitos sem neutro: esquema 1 (cada fase‑PE).
- TN‑C: esquema 1 (cada fase‑PE/PEN).

Todo DPS ao longo da instalação deve ser coordenado com montante e jusante (6.3.5.2.4‑f)).

**6.3.5.2.4 Seleção dos DPS**  
Devem atender à IEC 61643‑1 e ser selecionados por:
- a) Nível de proteção (Up) – compatível com a categoria II de suportabilidade (Tabela 31). No esquema 3, o nível refere‑se ao global (fase‑PE).
- b) Máxima tensão de operação contínua (Uc) – conforme Tabela 49.
- c) Sobretensões temporárias – o DPS deve atender aos ensaios da IEC 61643‑1.
- d) Corrente nominal de descarga (In) e corrente de impulso (Iimp):
  - Proteção contra surtos transmitidos e de manobra: In ≥ 5 kA (8/20 µs) por modo; entre neutro‑PE (esquema 3) → In ≥ 20 kA (trifásico) / 10 kA (monofásico).
  - Descargas diretas: Iimp determinada pela IEC 61312‑1; se não determinada, Iimp ≥ 12,5 kA por modo. Neutro‑PE (esquema 3) → Iimp ≥ 50 kA (trifásico) / 25 kA (monofásico).
- e) Suportabilidade à corrente de curto‑circuito – igual ou superior à corrente presumida no ponto. Se houver centelhador, a capacidade de interrupção de corrente subsequente declarada deve ser ≥ Icc presumida. Neutro‑PE: no mínimo 100 A (TN/TT), mesma capacidade que fase‑neutro no IT.
- f) Coordenação dos DPS – o fabricante deve fornecer instruções claras para coordenação entre DPS em cascata.

**6.3.5.2.5 Falha do DPS e proteção contra sobrecorrentes**  
Devido ao risco de falha do DPS em curto‑circuito, deve haver um DP (dispositivo de proteção contra sobrecorrentes). Opções (Figura 14):
- a) DP na conexão do DPS (continuidade de serviço, mas ausência de proteção contra novo surto após falha).
- b) DP do circuito (interrupção da alimentação até substituição do DPS).
- c) Redundância com dois DPS idênticos e DPs individuais (maior confiabilidade).

O DP deve ter corrente nominal ≤ indicada pelo fabricante do DPS. A seção dos condutores de conexão do DP específico deve suportar a máxima corrente de curto‑circuito presumida.

**6.3.5.2.6 Proteção contra choques e compatibilidade com DR**  
- Nenhuma falha do DPS pode comprometer a proteção contra choques.
- DPS a montante de DR em TT → usar esquema 3 (Figura 13).
- DPS a jusante de DR → DR deve possuir imunidade a surtos de no mínimo 3 kA (8/20 µs). (Ex.: dispositivos tipo S conforme IEC 61008‑2‑1/61009‑2‑1).

**6.3.5.2.7 Medição da resistência de isolamento**  
DPS podem ser desconectados durante o ensaio de 7.3.3, exceto os incorporados a tomadas e conectados ao PE, que devem suportar o ensaio.

**6.3.5.2.8 Indicação do estado do DPS**  
Deve evidenciar quando não cumpre a função: por indicador de estado ou por proteção separada (6.3.5.2.5).

**6.3.5.2.9 Condutores de conexão do DPS**  
Ligações as mais curtas possíveis, sem curvas ou laços; comprimento total (Figura 15‑a) de preferência ≤ 0,5 m. Se impossível, adotar esquema da Figura 15‑b. Seção mínima das ligações DPS–PE:
- 4 mm² cobre (ponto de entrada, proteção contra surtos conduzidos).
- 16 mm² cobre (descargas diretas).

### 6.3.5.3 Proteção em linhas de sinal

**6.3.5.3.1 Localização**  
- Linha de telefonia: DPS no DG (distribuidor geral) junto ao BEP.
- Outras redes públicas: DPS junto ao BEP.
- Linhas entre edificações ou associadas a antenas externas: DPS junto ao BEL mais próximo.

**6.3.5.3.2 Conexão**  
Devem ser conectados entre a linha de sinal e a referência de eqüipotencialização mais próxima (BEP, barra de terra do DG, BEL, barra PE ou terminal de massa do equipamento).

**6.3.5.3.3 Seleção do DPS (telefonia em par trançado no DG)**  
- a) Tipo: curto‑circuitante simples ou combinado.
- b) Tensão de disparo c.c.: entre 200 V e 500 V (linha balanceada aterrada) ou ≥ 300 V (linha flutuante).
- c) Tensão de disparo impulsiva: ≤ 1 kV.
- d) Corrente de descarga impulsiva: ≥ 5 kA (blindagem aterrada) / 10 kA (blindagem não aterrada).
- e) Corrente de descarga c.a.: ≥ 10 A.
- f) Protetor de sobrecorrente: obrigatório se linha balanceada aterrada (150‑250 mA); opcional em flutuante (mesma faixa).
- g) DPS para blindagens/capas metálicas (5.4.3.2 e 5.4.3.3): tipo curto‑circuitante, tensão disruptiva c.c. 200‑300 V, corrente impulsiva ≥ 10 kA (8/20 µs), corrente c.a. ≥ 10 A (60 Hz/1 s).

**6.3.5.3.4 Falha do DPS**  
Deve ser do tipo “falha segura” (proteção contra sobreaquecimento que curto‑circuita a linha com a terra).

**6.3.5.3.5 Condutores de conexão**  
Ligações as mais curtas e retilíneas possíveis.

### Tabela 49 — Máxima tensão de operação contínua Uc

Ver arquivo separado: `6_3_5_tabela49_tensao_operacao_continua_dps.md`.

### Tabela 50 — Tensão de impulso suportável para seccionadores

Ver arquivo separado: `6_3_5_tabela50_tensao_impulso_suportavel.md`.

---
*Referência: ABNT NBR 5410:2004 — Seção 6.3.5*