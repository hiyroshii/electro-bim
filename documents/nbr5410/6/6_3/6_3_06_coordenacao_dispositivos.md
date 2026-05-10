# NBR 5410 — 6.3.6 Coordenação entre diferentes dispositivos de proteção

**Norma:** ABNT NBR 5410:2004
**Subseção:** 6.3.6
**Pertence a:** `6_3_dispositivos_protecao.md`

---

## 6.3.6 Coordenação entre diferentes dispositivos de proteção

### 6.3.6.1 Seletividade entre dispositivos de proteção contra sobrecorrentes

Quando a continuidade de serviço for requisito, os dispositivos em série devem ser selecionados para que apenas o dispositivo a montante da falta atue (seletividade).

### 6.3.6.2 Associação entre dispositivos DR e dispositivos de proteção contra sobrecorrentes

**6.3.6.2.1** Dispositivo DR incorporado/associado a proteção contra sobrecorrentes → o conjunto deve atender a 5.3, 6.3.4.2 e 6.3.4.3.

**6.3.6.2.2** Dispositivo DR não incorporado/associado:
- a) Proteção contra sobrecorrentes provida separadamente conforme 5.3.
- b) O DR deve suportar solicitações térmicas/dinâmicas de curto‑circuito a jusante.
- c) O DR não deve ser danificado por curto‑circuito, mesmo que se abra por desequilíbrio ou corrente para terra.

### 6.3.6.3 Seletividade entre dispositivos DR

**6.3.6.3.1** Pode ser exigida por razões de serviço ou segurança.

**6.3.6.3.2** Para garantir seletividade entre dois DR em série:
- a) A característica tempo‑corrente de não‑atuação do DR a montante deve estar acima da característica de atuação do DR a jusante.
- b) A corrente diferencial‑residual nominal do DR a montante deve ser superior à do DR a jusante. Em dispositivos conforme IEC 61008‑2‑1 / IEC 61009‑2‑1, **a montante deve ter I∆n ≥ 3 × I∆n do dispositivo a jusante**.

> **NOTA:** A condição a) pode ser atendida usando dispositivo de uso geral a jusante e tipo S (retardado) a montante.

---
*Referência: ABNT NBR 5410:2004 — Seção 6.3.6*