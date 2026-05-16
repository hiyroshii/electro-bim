# ElectroBIM — Roadmap do `normative_engine` até v1.0.0
<!-- REV: 2 -->
<!-- CHANGELOG:
[Rev 2] - 16 05 2026
- CHG: Fases 1 e 2 marcadas como CONCLUÍDAS.
- CHG: Fase 3 atualizada — subfases 3.1..3.6 concluídas, pendências mapeadas.
- CHG: Fase 4 atualizada — S-15 banheiro antecipada para Fase 3.6.
- CHG: referências cruzadas corrigidas (arquivos deletados removidos).
- CHG: estado atual atualizado (363 testes, v0.6.0-dev).
[Rev 1] - 06 05 2026
- ADD: Plano de fases de desenvolvimento partindo de v0.3.5 até v1.0.0.
-->

> Data: 16 05 2026
> Estado atual: **Fase 3 em progresso** — 363 testes, dart analyze limpo
> Meta: **v1.0.0** — NBR 5410 cobrindo residencial + comercial + industrial com API estável

---

## Princípios do roadmap

Cada fase respeita 4 invariantes:

1. **Versão é minor bump** (`0.x.0`) — entrega capacidade nova sem quebrar API anterior
2. **Encerramento normativo** — fase só fecha quando todas as suas seções da NBR têm referência cruzada nos comentários do código
3. **Cobertura de teste ≥ 90%** por arquivo entregue
4. **Sem dívida arquitetural acumulada** — refactors necessários acontecem na primeira fase em que a regra envolvida aparece, nunca depois

A ordem das fases respeita dependências reais. Curto-circuito (Fase 5) precisa de esquemas de aterramento (Fase 3). Comercial (Fase 6) precisa dos 4 contratos explícitos (Fase 2). E assim por diante.

---

## Visão geral

| Fase | Versão | Foco | Escopo coberto | Estado |
|---|---|---|---|---|
| 1 | 0.4.0 | Consolidação residencial — fechamento de pendências G2 | RESIDENCIAL | ✅ Concluída |
| 2 | 0.5.0 | Reestruturação dos 4 contratos | RESIDENCIAL | ✅ Concluída |
| 3 | 0.6.0 | Locais, carga, proteção residencial | RESIDENCIAL | 🔄 Em progresso |
| 4 | 0.7.0 | Choques, aterramento, locais especiais restantes | RESIDENCIAL completo | 🔲 |
| 5 | 0.8.0 | Curto-circuito | RESIDENCIAL completo | 🔲 |
| 6 | 0.9.0 | Escopo comercial | RES + COM | 🔲 |
| 7 | 0.10.0 | Escopo industrial | RES + COM + IND | 🔲 |
| 8 | 0.11.0 | Verificação pós-instalação | Os três escopos | 🔲 |
| 9 | 1.0.0 | Refinamentos finais e release | Os três escopos | 🔲 |

---

## ✅ Fase 1 — Consolidação MVP Residencial → v0.4.0 — CONCLUÍDA

**Entregas realizadas:**
- `ProcSecaoNeutro` real conforme 6.2.6 (Tab. 47/48)
- `tabela_xi_reatancia` — reatâncias de cabo
- `SpecDispositivoMultipolar` (S-6) — 9.5.4
- `SpecSobrecarga` (S-3) — Ib ≤ In ≤ Iz
- `EscopoProjeto` enum: residencial, comercial, industrial
- `FaixaTensao` enum + COMB_007/COMB_008

---

## ✅ Fase 2 — Reestruturação dos 4 Contratos → v0.5.0 — CONCLUÍDA

**Entregas realizadas:**
- `IClassification<I>` e `IVerification<M,P,R>` introduzidos
- `PerfilInstalacao` VO: escopo + `Set<CodigoInfluencia>`
- `CodigoInfluencia` enum: ba3/ba4/ba5, bd1..bd4
- `ClassCompetenciaBa`, `ClassFugaEmergenciaBd`, `ClassPerfilPadraoPorEscopo`
- `ClassificationService`, `VerificationService` (skeleton)
- `aplicavelA(PerfilInstalacao)` em todas as specs
- `enums/` eliminado — tipos migrados para `domain/`
- `ContextoInstalacao` removido definitivamente

---

## ✅ Fase 3 — Locais, Carga e Proteção Residencial → v0.6.0 — CONCLUÍDA

**Entregas realizadas (subfases 3.1 a 3.6):**

**3.1 — Migração `enums/` → `domain/`**
- Todos os tipos movidos para `domain/` hierárquico (22 imports atualizados)
- `ContextoInstalacao` removido definitivamente

**3.2 — Carga residencial**
- `domain/locais/tipo_comodo.dart` — enum `TipoComodo` (9.5.x)
- `tables/habitacao/carga_iluminacao.dart` (T-13), `potencia_tug.dart` (T-14)
- `procedure/carga/proc_carga_residencial.dart` (P-6) — Strategy residencial

**3.3 — Pontos mínimos**
- `specification/carga/spec_minimo_il.dart` (S-12) — IL mínimo por cômodo
- `specification/carga/spec_minimo_tug.dart` (S-13) — TUG mínima por cômodo
- Violações IL_001, TUG_001

**3.4 — Tipologia de circuitos**
- `specification/carga/spec_circuito_independente.dart` (S-9)
- `specification/carga/spec_circuito_exclusivo.dart` (S-10)
- `specification/carga/spec_circuito_misto.dart` (S-11)
- Violações CIRC_001..CIRC_006

**3.5 — DR por local (§ 5.1.3.2.2)**
- `specification/protecao/spec_dr_obrigatorio.dart` (S-8) — lógica por local:
  banheiro→todos os terminais; cozinha/áreaServiço/garagem→TUG+TUE; área externa→TUG+TUE
- Violações DR_001, DR_002

**3.6 — Volumes de banheiro (Seção 701)**
- `domain/locais/volume_banheiro.dart` — V0/V1/V2/V3 com `ipXMinimo` correto
- `specification/locais_especificos/spec_banheiro.dart` (S-15) — IP + SELV + DR por volume
- Violações BANH_001..BANH_004

---

## Fase 4 — Choques, Aterramento e Locais Especiais Restantes → v0.7.0

**Objetivo:** Cobrir Seção 5.1 (seccionamento automático), 4.2.2 (esquemas), 6.4 (aterramento)
e encerrar a Seção 9 residencial (piscina, sauna). Banheiros (9.1) já foram cobertos na Fase 3.6.

**Entregas:**

- `classification/instalacao/class_esquema_aterramento.dart` — TN-S, TN-C, TN-C-S, TT, IT
- `classification/ambiente/class_situacao_choque.dart` — situações 1, 2, 3 (Anexo C)
- `tables/protecao/tabela_25_seccionamento_tn.dart`
- `tables/protecao/tabela_26_seccionamento_tt.dart`
- `tables/protecao/tabela_54_pe_proporcional.dart`
- `tables/anexos/anexo_c_situacoes_ul.dart`
- `spec/protecao/spec_seccionamento_automatico.dart` — Zs·Ia ≤ Uo (5.1.2.2)
- `spec/aterramento/spec_secao_pe.dart` (S-20) — 6.4.3 + Tabela 54
- `spec/aterramento/spec_equipotencializacao_principal.dart` (S-21) — 6.4.4
- `spec/aterramento/spec_equipotencializacao_suplementar.dart` (S-22) — 6.4.5
- `proc/condutor/proc_secao_pe.dart` (P-4) — fórmula térmica quando Tabela 54 não se aplica
- `spec/locais_especificos/spec_piscina.dart` — 9.2 (volumes, SELV, equipotencialização)
- `spec/locais_especificos/spec_sauna.dart` — 9.4 (zonas térmicas)

**Critério de pronto:**
- Para qualquer combinação esquema × situação de choque, engine retorna tempo máximo de seccionamento e UL aplicável
- Piscinas e saunas dimensionadas com restrições corretas de IP e SELV
- Residencial completo: todas as Seções 5.1, 6.4 e 9 cobertas

---

## Fase 5 — Curto-Circuito → v0.8.0

**Objetivo:** Cobrir Seção 5.3.5 e Anexos K, L. Vale para todos os escopos.

**Entregas:**

- `tables/protecao/tabela_30_k_curto_circuito.dart` — coeficiente k por isolação/material
- `proc/protecao/proc_corrente_curto_circuito.dart` — Icc presumida (Anexo K)
- `proc/protecao/proc_integral_joule.dart` — I²t do disjuntor vs. k²S²
- `proc/protecao/proc_impedancia_falta.dart` — Anexo K
- `spec/protecao/spec_curto_circuito.dart` — 5.3.5 (capacidade de interrupção, k²S²)
- `spec/condutor/spec_temperatura_servico.dart` — Tabela 35 (limites de temperatura por isolação)

**Critério de pronto:**
- Para cada circuito, engine retorna Icc max (barramento) e Icc min (extremidade)
- Validação automática de capacidade de interrupção do disjuntor
- Validação automática de I²t ≤ k²S² para o tempo de atuação do disjuntor

**Pré-requisito:** Fase 4 (esquemas de aterramento determinam impedância da malha).

---

## Fase 6 — Escopo Comercial → v0.9.0

**Objetivo:** Habilitar `EscopoProjeto.COMERCIAL` no fluxo completo.

**Entregas:**

- `classification/instalacao/class_perfil_padrao_por_escopo.dart` (estende para COMERCIAL)
- `proc/carga/proc_carga_comercial.dart` — 4.2.1 (potência instalada × fator de demanda)
- `proc/carga/proc_fator_demanda.dart`
- `domain/carga/entrada_carga_comercial.dart` — sealed variant
- `spec/carga/spec_iluminacao_emergencia.dart` — 4.2.4 + 6.6 (circuitos ininterruptíveis)
- `spec/protecao/spec_dps_classes.dart` — 5.4.2 (Classe I, II, III por categoria de sobretensão)
- `classification/ambiente/class_categoria_sobretensao.dart` — 5.4 + Anexo E
- `spec/instalacao/spec_alimentacao_coletiva.dart` — múltiplos medidores, ramal coletivo
- `tables/instalacao/tabela_59_quadros.dart` — 6.5.4

**Critério de pronto:**
- UI seleciona "Comercial" → `PerfilInstalacao` com BA, BD, BE comerciais padrão
- `DimensionadorCarga` despacha para `ProcCargaComercial` via Strategy
- Specs residenciais (9.5.x) **não** ativam para escopo comercial — testado

---

## Fase 7 — Escopo Industrial → v0.10.0

**Objetivo:** Habilitar `EscopoProjeto.INDUSTRIAL` com regras específicas.

**Entregas:**

- `classification/instalacao/class_perfil_padrao_por_escopo.dart` (estende para INDUSTRIAL)
- `proc/carga/proc_carga_industrial.dart` — listagem de equipamentos + regime S1–S8
- `domain/carga/entrada_carga_industrial.dart`
- `spec/industrial/spec_motor.dart` — 6.5.1 (corrente de partida, fator de utilização)
- `proc/industrial/proc_corrente_partida_motor.dart` — Ip/In, classes B/C/D, MPCB
- `spec/industrial/spec_neutro_harmonicas.dart` — Anexo F
- `proc/industrial/proc_fator_harmonicas.dart` — fh para neutro reforçado
- `spec/condutor/spec_paralelos.dart` — Anexo D normativo
- `proc/condutor/proc_distribuicao_paralelos.dart`
- `spec/locais_especificos/spec_compartimento_condutivo.dart` — 9.3
- `spec/protecao/spec_protecao_falta_tensao.dart` — 5.5
- `spec/aterramento/spec_equalizacao_funcional.dart` — 6.4.7
- `tables/anexos/anexo_f_harmonicas.dart` — fator fh

**Critério de pronto:**
- UI seleciona "Industrial" → fluxo de cadastro de equipamentos por placa
- Motores com partida direta dimensionados corretamente (curva D, MPCB)
- Neutro reforçado quando taxa de 3ª harmônica > 15%

---

## Fase 8 — Verificação Pós-Instalação → v0.11.0

**Objetivo:** Implementar o contrato `IVerification` com a suite completa da Seção 7 e Anexos H, J, L, M.

**Entregas:**

- `verification/verify_continuidade_pe.dart` — 7.3.2
- `verification/verify_resistencia_isolamento.dart` — 7.3.3 + Tabela 60
- `verification/verify_seccionamento_automatico.dart` — 7.3.5
- `verification/verify_dr.dart` — 7.3.7 + Anexo H
- `verification/verify_resistencia_aterramento.dart` — Anexo J
- `verification/verify_resistencia_pe.dart` — Anexo L
- `verification/verify_tensao_aplicada.dart` — Anexo M
- `tables/verificacao/tabela_60_resistencia_isolamento.dart`
- `domain/resultados/resultado_ensaio.dart` — VO (valor medido + limite + pass/fail)
- `orchestrator/verification_service.dart` — fachada pública

**Critério de pronto:**
- Engine recebe valores medidos em campo + parâmetros do projeto → retorna relatório de conformidade
- Suite permite gerar laudo de comissionamento

**Observação:** introduz fluxo novo (instalação executada vs. projeto). Pode ser opcional para o app — engine fica pronto, UI pode adiar tela de comissionamento.

---

## Fase 9 — Refinamentos Finais e Release v1.0.0

**Objetivo:** Fechar lacunas residuais, atingir cobertura completa da NBR 5410 em escopo, estabilizar API.

**Entregas:**

- Cobertura completa da Tabela 32 (todas as 24 famílias de influência externa)
- `tables/anexos/anexo_a_faixas_tensao.dart`
- `classification/instalacao/class_faixa_tensao.dart` — Anexo A
- Documentação completa: cada arquivo com referência NBR no header (`/// NBR 5410:2004 — 6.2.7.1`)
- Cobertura de testes ≥ 95%
- API pública 100% documentada com `dart doc`
- Migration guide se houve breaking changes ao longo das fases
- Bench de performance — `dimensiona()` < 50 ms para projeto residencial típico

**Critério de pronto:**
- 100% das seções da NBR 5410 marcadas como "relevantes" (classificação rev1) cobertas
- Os três escopos validados em projetos-exemplo end-to-end
- API estável: a partir de v1.0.0, mudanças seguem semver estrito

---

## Mapa: seção NBR → fase

| Seção NBR 5410 | Fase |
|---|---|
| 4.1 Princípios | — (não codificável) |
| 4.2.1 Potência de alimentação | 6 |
| 4.2.2 Esquemas de aterramento | 4 |
| 4.2.4 Serviços de segurança | 6 |
| 4.2.5 Divisão de circuitos (S-9/S-10/S-11) | ✅ 3 |
| 4.2.6 Influências externas | 2 (núcleo) + 9 (refinamento) |
| 5.1 Choques — DR por local (S-8) | ✅ 3.5 |
| 5.1 Choques — seccionamento automático (S-7) | 4 |
| 5.3.4 Sobrecarga (S-3) | ✅ 1 |
| 5.3.5 Curto-circuito (S-14) | 5 |
| 5.4 Sobretensões + DPS (S-16) | 6 |
| 5.5 Falta de tensão | 7 |
| 6.1.3 Influências → IP | 2 (núcleo) + 9 (refinamento) |
| 6.2.3 Condutores | ✅ 1 |
| 6.2.5 Ampacidade | ✅ 1 |
| 6.2.6 Neutro (P-3) | ✅ 1 |
| 6.2.7 Queda de tensão | ✅ 1 |
| 6.3 Dispositivos | 5 (curto) + 6 (DPS) |
| 6.4 Aterramento (P-4, S-20/S-21/S-22) | 4 |
| 6.5.1 Motores | 7 |
| 6.6 Serviços de segurança | 6 |
| 7 Verificação | 8 |
| 9.1 Banheiros (S-15) | ✅ 3.6 |
| 9.2 Piscinas | 4 |
| 9.3 Compartimentos condutivos | 7 |
| 9.4 Saunas | 4 |
| 9.5 Habitação — carga (P-6), pontos mínimos (S-12/S-13) | ✅ 3.2/3.3 |
| Anexo A | 9 |
| Anexo C (situações de choque) | 4 |
| Anexo D | 7 |
| Anexo F | 7 |
| Anexo H | 8 |
| Anexo J/K/L/M | 8 |

---

## Estimativa de volume (referência, não compromisso)

| Fase | Specs | Procs | Classifications | Verifications | Tables novas |
|---|---|---|---|---|---|
| 1 | 1 | 2 | 0 | 0 | 1 |
| 2 | refactor | refactor | ~3 | 0 (interface) | 0 |
| 3 ✅ | 7 | 1 | 1 | 0 | 2 |
| 4 | 5 | 1 | 2 | 0 | 4 |
| 5 | 2 | 3 | 0 | 0 | 1 |
| 6 | 4 | 2 | 2 | 0 | 1 |
| 7 | 6 | 3 | 1 | 0 | 1 |
| 8 | 0 | 0 | 0 | 7 | 1 |
| 9 | 0 | 0 | 1 | 0 | refinamentos |

Total novos arquivos de produção até v1.0.0: ~50–60.

---

## Referências cruzadas

- `ARCHITECTURE.md` (raiz do repo) — estrutura de packages, grafo de dependências, camadas
- `regras_nbr5410_classificadas_rev1.md` — base normativa de prioridade (G1–G4)
- `contexto_projeto_electrobim_rev8.md` — estado atual do projeto
- `contexto_normative_engine_rev2.md` — estado interno do package (contratos, specs, pendências)
- `packages/normative_engine/CHANGELOG.md` — histórico versionado autoritativo do package
