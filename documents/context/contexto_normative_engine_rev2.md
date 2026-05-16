# Contexto — normative_engine
<!-- REV: 2 -->
<!-- CHANGELOG:
[Rev 2] - 15 05 2026
- MAJOR: atualização para refletir Fases 1-3 concluídas (363 testes).
- CHG: enums/ eliminado — tipos migrados para domain/.
- ADD: IClassification, IVerification, PerfilInstalacao, CodigoInfluencia.
- ADD: estrutura completa domain/, classification/, tabelas habitacao/.
- ADD: 9 specs novas (S-3, S-8, S-9, S-10, S-11, S-12, S-13, S-15 + SpecSobrecarga).
- ADD: ProcCargaResidencial (P-6), ProcSecaoNeutro real.
- REM: ContextoInstalacao (substituído por PerfilInstalacao).
- CHG: pendências atualizadas para refletir estado Fase 3.
[Rev 1] - 01 05 2026
- ADD: criação do documento de contexto específico do normative_engine.
-->

> Complementa o contexto geral do projeto (`contexto_projeto_electrobim_rev8.md`).
> Foco: decisões, contratos e detalhes internos exclusivos do normative_engine.
> Estado: **Fase 3.6 concluída** — 363 testes, dart analyze limpo.

---

## 1. Propósito

Package Dart puro que encapsula as regras da **ABNT NBR 5410:2004** aplicáveis
ao dimensionamento de instalações elétricas de baixa tensão.

**Não calcula** — fornece regras, tabelas e dados para que outros packages calculem.
Consumidor principal: `electrical_engine`.

---

## 2. Fluxo de uso pelo consumidor

```
1. verificarConformidade(EntradaNormativa)      → pré-cálculo, aborta se inválido
2. resolverDadosNormativos(entrada, params)     → tabelas Iz, FCT/FCA, limites, seção mínima
3. [electrical_engine calcula...]
4. auditar(EntradaNormativa, ResultadoNormativo) → pós-cálculo, valida o resultado
```

Specs de carga e locais especiais (S-8 a S-15) são chamadas diretamente pelo consumidor
com seus próprios typedefs de entrada — não passam pelo fluxo `NormativeEngine`.

---

## 3. Os 4 Contratos

| Contrato | Interface | Responsabilidade |
|---|---|---|
| Specification | `ISpecification<T>` | Verifica conformidade — devolve `List<Violacao>` |
| Procedure | `IProcedure<I, O>` | Resolve dados normativos — consulta tabelas e fatores |
| Classification | `IClassification<I>` | Classifica contexto — determina influências e perfil |
| Verification | `IVerification<M, P, R>` | Verifica medições em campo contra projeto (skeleton) |

`ISpecification` expõe `aplicavelA(PerfilInstalacao)` — o `SpecificationService`
só chama `verificar()` para specs onde `aplicavelA` retorna true.

---

## 4. Estrutura interna (estado Fase 3.6)

```
src/
  contracts/
    normative_engine.dart       ← interface NormativeEngine (3 métodos)
    i_specification.dart        ← ISpecification<T> + aplicavelA; re-exports PerfilInstalacao
    i_procedure.dart            ← IProcedure<I, O>
    i_classification.dart       ← IClassification<I>
    i_verification.dart         ← IVerification<M, P, R> (skeleton)

  domain/
    condutor/
      isolacao.dart             ← PVC, XLPE, EPR
      arquitetura.dart          ← isolado, unipolar, multipolar
      metodo_instalacao.dart    ← A1, A2, B1, B2, C, D, E, F, G
      arranjo_condutores.dart   ← justaposto2c, trifolio, planoJustaposto…
      material.dart             ← cobre, aluminio
    instalacao/
      escopo_projeto.dart       ← residencial, comercial, industrial
      tag_circuito.dart         ← med, qdg, qd, tug, tue, il
      tensao.dart               ← v127, v220, v380
      numero_fases.dart         ← monofasico, bifasico, trifasico
      origem_alimentacao.dart   ← pontoEntrega, trafoProprio
      faixa_tensao.dart         ← faixaI (SELV/PELV), faixaII (convencional)
      perfil_instalacao.dart    ← VO: escopo + Set<CodigoInfluencia>
    influencias/
      codigo_influencia.dart    ← ba3, ba4, ba5, bd1, bd2, bd3, bd4
    locais/
      tipo_comodo.dart          ← sala, quarto, cozinha, banheiro, areaServico…
      volume_banheiro.dart      ← v0 (IPX7), v1 (IPX4), v2 (IPX4), v3 (IPX1)

  models/
    entrada_normativa.dart      ← input do NormativeEngine
    resultado_normativo.dart    ← input do auditar() — ib, inDisjuntor, izFinal
    dados_normativos.dart       ← output de resolverDadosNormativos()
    violacao.dart               ← código + descrição + referência (16 factories)
    fatores_correcao.dart       ← FCT, FCA, combinado
    linha_ampacidade.dart       ← secao + izBase
    parametros_queda.dart       ← limite%, condutoresCarregados, fatorHarmonico

  tables/
    tabela_35_temp_servico.dart
    tabela_36_iz_pvc_a1d.dart … tabela_39_iz_xlpe_epr_efg.dart
    tabela_40_fct_temperatura.dart
    tabela_41_fca_resistividade_solo.dart
    tabela_42_45_fca_agrupamento.dart
    tabela_47_48_secao_minima_neutro.dart
    tabela_xi_reatancia.dart
    habitacao/
      tabela_carga_iluminacao.dart    ← T-13: 100 VA/ponto IL por cômodo
      tabela_potencia_tug.dart        ← T-14: 100/600 VA por TUG por cômodo

  classification/
    influencias_externas/
      class_competencia_ba.dart       ← ClassCompetenciaBa (ba3/ba4/ba5)
      class_fuga_emergencia_bd.dart   ← ClassFugaEmergenciaBd (bd1..bd4)
    instalacao/
      class_perfil_padrao_por_escopo.dart ← perfil padrão para cada EscopoProjeto

  procedure/
    condutor/
      proc_ampacidade.dart            ← P-1: FCT, FCA, tabela Iz
      proc_secao_neutro.dart          ← P-3: seção real do neutro (Tab. 47/48)
    tensao/
      proc_queda_tensao.dart          ← P-2: limite%, condutores, harmônicas
    carga/
      proc_carga_residencial.dart     ← P-6: carga mínima normativa via T-13/T-14

  specification/
    condutor/
      spec_combinacoes.dart           ← S-1: iso×arq, arq×método, arranjo, tensão×fases
      spec_aluminio.dart              ← S-2: restrições por PerfilInstalacao
      spec_secao_minima.dart          ← S-4: pisos Tab. 47 (auditoria)
      spec_neutro.dart                ← Tab. 48 (auditoria)
    protecao/
      spec_sobrecarga.dart            ← S-3: Ib ≤ In ≤ Iz (auditoria)
      spec_dispositivo_multipolar.dart ← S-6: corte simultâneo
      spec_dr_obrigatorio.dart        ← S-8: DR por local (banheiro, cozinha, externa)
    instalacao/
      spec_queda_tensao.dart          ← S-5: limites ΔV% (auditoria)
    carga/
      spec_circuito_independente.dart ← S-9: TUE > 10 A exclusivo
      spec_circuito_exclusivo.dart    ← S-10: TUG cozinha/areaServico exclusivo
      spec_circuito_misto.dart        ← S-11: IL+TUG Ib ≤ 16 A
      spec_minimo_il.dart             ← S-12: pontos IL mínimos por cômodo
      spec_minimo_tug.dart            ← S-13: TUGs mínimas por cômodo
    locais_especificos/
      spec_banheiro.dart              ← S-15: V0/V1/V2/V3 — BANH_001..004

  orchestrator/
    normative_service.dart            ← NormativeService implements NormativeEngine
    classification_service.dart       ← ClassificationService: BA + BD → PerfilInstalacao
    specification_service.dart        ← filtra por aplicavelA, agrega violações
    procedure_service.dart            ← monta DadosNormativos completo
    verification_service.dart         ← skeleton
```

---

## 5. Contrato público (NormativeEngine)

```dart
abstract interface class NormativeEngine {
  List<Violacao> verificarConformidade(EntradaNormativa entrada);

  DadosNormativos resolverDadosNormativos(
    EntradaNormativa entrada,
    ParamsAgrupamento paramsAgrupamento,
  );

  List<Violacao> auditar(EntradaNormativa entrada, ResultadoNormativo resultado);
}
```

---

## 6. Specs — momentos de execução e aplicabilidade

| Spec | Momento | `aplicavelA` | Depende de resultado? |
|---|---|---|---|
| `spec_combinacoes` | pré-cálculo | sempre | ❌ |
| `spec_aluminio` | pré-cálculo | por escopo/perfil | ❌ |
| `spec_dispositivo_multipolar` | pré-cálculo | sempre | ❌ |
| `spec_secao_minima` | auditoria | sempre | ✅ secaoFase |
| `spec_neutro` | auditoria | sempre | ✅ secaoFase, secaoNeutro |
| `spec_sobrecarga` | auditoria | sempre | ✅ ib, inDisjuntor, izFinal |
| `spec_queda_tensao` | auditoria | sempre | ✅ quedaPercent |
| `spec_dr_obrigatorio` | standalone | residencial | ❌ (EntradaDrObrigatorio) |
| `spec_circuito_*` (S-9..11) | standalone | residencial | ❌ |
| `spec_minimo_il/tug` (S-12/13) | standalone | residencial | ❌ |
| `spec_banheiro` (S-15) | standalone | residencial | ❌ (EntradaBanheiro) |

---

## 7. Decisões de design específicas

**Tabelas como `const Map` Dart** — sem JSON em runtime. Type-safe, zero overhead.

**EPR compartilha tabelas com XLPE** — mesma temperatura máxima (90°C).
`Isolacao.epr.chaveTabela == 'XLPE_EPR'`. Distinção preservada no enum.

**`null` para temperatura não admissível (Tabela 40)** — `null` distingue "inexistente" de "zero".
Gera `Violacao.temperaturaInadmissivel()` na `spec_combinacoes`.

**`ArranjoCondutores?` nullable** — só existe para métodos F e G. Null é semanticamente correto.

**`paramsAgrupamento` por chamada, não por instância** — agrupamento varia por circuito no projeto.

**Violações acumuladas, nunca para na primeira** — `SpecificationService` roda todos e acumula.

**`OrigemAlimentacao` relevante para alimentadores** — pontoEntrega: 1% (total 5%), trafoProprio: 3% (total 7%).

**DR por local, não para todos os terminais (S-8)** — banheiro: todos os terminais (IL/TUG/TUE).
Cozinha/areaServico/garagem: apenas TUG e TUE. Área externa: TUG e TUE.
Circuitos de distribuição (MED, QDG, QD): nunca exigem DR.

**`PerfilInstalacao` como VO** — imutável, substitui `ContextoInstalacao` enum.
Agrega `EscopoProjeto` + `Set<CodigoInfluencia>`. Passado a `aplicavelA()` em todas as specs.

---

## 8. Regras normativas implementadas

| Seção NBR | Regra | Onde |
|---|---|---|
| 6.1.3.1.1 | Tensão × fases válidas | `spec_combinacoes` |
| 6.2.3 | Iso × Arq × Método (Tab. 33) | `spec_combinacoes` |
| 6.2.3.8 | Restrições alumínio | `spec_aluminio` |
| 6.2.5.3 | FCT por temperatura | `proc_ampacidade`, Tab. 40 |
| 6.2.5.4 | FCT resistividade solo (Método D) | `proc_ampacidade`, Tab. 41 |
| 6.2.5.5 | FCA agrupamento | `proc_ampacidade`, Tab. 42-45 |
| 6.2.5.6.1 | 4 condutores carregados (harm > 15%) | `proc_queda_tensao` |
| 6.2.6.1.1 | Seção mínima de fase (Tab. 47) | `spec_secao_minima` |
| 6.2.6.2 | Regras do neutro (Tab. 48) | `spec_neutro` (proc_secao_neutro) |
| 6.2.7.1 | Limite queda alimentador | `spec_queda_tensao`, `proc_queda_tensao` |
| 6.2.7.2 | Limite queda terminal (4%) | `spec_queda_tensao` |
| 6.2.9.5 | Faixas de tensão distintas no mesmo conduto | `spec_combinacoes` (COMB_007) |
| 6.2.10.1 | Multipolar = um único circuito | `spec_combinacoes` (COMB_008) |
| 5.3.4.1 | Ib ≤ In ≤ Iz (sobrecarga) | `spec_sobrecarga` |
| 5.1.3.2.2 | DR por local (banheiro, cozinha, externo) | `spec_dr_obrigatorio` |
| 9.5.3.1 | TUE > 10 A com circuito exclusivo | `spec_circuito_independente` |
| 9.5.3.2 | TUG em área molhada com circuito exclusivo | `spec_circuito_exclusivo` |
| 9.5.3.3 | Circuito misto IL+TUG | `spec_circuito_misto` |
| 9.5.4.1.1 | Pontos mínimos IL por cômodo | `spec_minimo_il` |
| 9.5.4.1.2 | TUGs mínimas por cômodo | `spec_minimo_tug` |
| Seção 701 | Volumes de banheiro V0/V1/V2/V3 | `spec_banheiro` |
| 9.5.4 | Dispositivo multipolar | `spec_dispositivo_multipolar` |

---

## 9. Cobertura de testes (Fase 3.6)

| Grupo | Arquivo(s) | Casos |
|---|---|---|
| spec_combinacoes | spec_combinacoes_test | ~19 |
| spec_aluminio | spec_aluminio_test | ~8 |
| spec_neutro | spec_neutro_test | ~7 |
| spec_secao + queda | spec_secao_queda_test | ~14 |
| spec_sobrecarga | spec_sobrecarga_test | ~14 |
| spec_dr_obrigatorio | spec_dr_obrigatorio_test | ~30 |
| spec_circuito_* | spec_circuito_*_test | ~45 |
| spec_minimo_il/tug | spec_minimo_*_test | ~50 |
| spec_banheiro | spec_banheiro_test | ~36 |
| proc_ampacidade | proc_ampacidade_test | ~14 |
| proc_queda_tensao | proc_queda_tensao_test | ~9 |
| proc_carga_residencial | proc_carga_residencial_test | ~18 |
| classification | class_*_test | ~20 |
| normative_service | normative_service_test | ~19 |
| **Total** | | **363** |

---

## 10. Pendências (pós-Fase 3.6)

| Item | Status | Observação |
|---|---|---|
| `spec_seccionamento_automatico` (S-7) | ⏸ Adiado | Requer EsquemaAterramento (Fase grounding) |
| `spec_dps_obrigatorio` (S-16) | ⏸ Adiado | Requer Tab. 49/50, tipo de rede (Fase comercial) |
| `SpecSecaoPE` (S-20) + `ProcSecaoPE` (P-4) | 🔲 Próximo | Candidato próxima subfase |
| Classificações influências externas (AA, AD, BB, BC, BE, CA, CB) | 🔲 | Volume médio |
| Tabelas influências externas (Tab. 1-24) | 🔲 | 20 arquivos — volume alto |
| `spec_piscina` (9.2), `spec_sauna` (9.4) | 🔲 Fase 4 | Locais especiais residenciais |
| Specs comerciais (carga m², DPS, alimentação coletiva) | 🔲 Fase 6 | |
| `motor_engine` — specs industriais (S-17, S-18) | 🔲 Fase 7 | Package separado |
| Verifications V-1..V-7 | 🔲 Fase 8 | Skeleton existe |
