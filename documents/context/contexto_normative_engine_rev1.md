# Contexto — normative_engine
<!-- REV: 1 -->
<!-- CHANGELOG:
[Rev 1] - 01 05 2026
- ADD: criação do documento de contexto específico do normative_engine.
-->

> Complementa o contexto geral do projeto (`contexto_projeto_electrobim_rev6.md`).
> Foco: decisões, contratos e detalhes internos exclusivos do normative_engine.

---

## 1. Propósito

Package Dart puro que encapsula as regras da **ABNT NBR 5410:2004** aplicáveis
ao dimensionamento de instalações elétricas de baixa tensão.

**Não calcula** — fornece regras e dados para que outros packages calculem.
Consumidor principal: `dimensionamento_engine`.

---

## 2. Fluxo de uso pelo consumidor

```
1. verificarConformidade(EntradaNormativa)  → pré-cálculo, aborta se inválido
2. resolverDadosNormativos(entrada, params) → tabelas, FCT/FCA, limites, seção mínima
3. [dimensionamento_engine calcula...]
4. auditar(EntradaNormativa, ResultadoNormativo) → pós-cálculo, valida o resultado
```

O `apps/flutter` nunca chama o `normative_engine` diretamente —
passa pelo `dimensionamento_engine`.

---

## 3. Estrutura interna

```
src/
  contracts/
    normative_engine.dart      ← interface NormativeEngine (3 métodos)
    i_specification.dart       ← interface ISpecification<T>
    i_procedure.dart           ← interface IProcedure<I, O>

  enums/                       ← tipos do domínio normativo
    isolacao.dart              ← PVC, XLPE, EPR
    arquitetura.dart           ← ISOLADO, UNIPOLAR, MULTIPOLAR
    metodo_instalacao.dart     ← A1, A2, B1, B2, C, D, E, F, G
    arranjo_condutores.dart    ← justaposto2c, trifolio, planoJustaposto,
                                  espacadoHorizontal, espacadoVertical
    material.dart              ← COBRE, ALUMINIO
    tag_circuito.dart          ← MED, QDG, QD, TUG, TUE, IL
    tensao.dart                ← V127, V220, V380
    numero_fases.dart          ← MONOFASICO, BIFASICO, TRIFASICO
    contexto_instalacao.dart   ← industrial, comercialBd1, bd4
    origem_alimentacao.dart    ← pontoEntrega, trafoProprio

  models/
    entrada_normativa.dart     ← input do NormativeEngine (sem paramsAgrupamento)
    resultado_normativo.dart   ← input do auditar() — vem do relatório calculado
    dados_normativos.dart      ← output de resolverDadosNormativos()
    violacao.dart              ← código + descrição + referência normativa
    fatores_correcao.dart      ← FCT, FCA, combinado
    linha_ampacidade.dart      ← secao + izBase (sem fatores)
    parametros_queda.dart      ← limite%, condutoresCarregados, fatorHarmonico

  tables/                      ← const Map Dart, um arquivo por tabela
    tabela_35_temp_servico.dart
    tabela_36_iz_pvc_a1d.dart
    tabela_37_iz_xlpe_epr_a1d.dart
    tabela_38_iz_pvc_efg.dart
    tabela_39_iz_xlpe_epr_efg.dart
    tabela_40_fct_temperatura.dart
    tabela_41_fca_resistividade_solo.dart
    tabela_42_45_fca_agrupamento.dart
    tabela_47_48_secao_minima_neutro.dart

  specification/               ← pré-cálculo + auditoria
    spec_combinacoes.dart      ← iso×arq, arq×método, arranjo, tensão×fases
    spec_aluminio.dart         ← restrições de uso por contexto
    spec_secao_minima.dart     ← pisos Tab. 47 (auditoria)
    spec_neutro.dart           ← regras do neutro (auditoria)
    spec_queda_tensao.dart     ← limites ΔV% (auditoria)

  procedure/
    proc_ampacidade.dart       ← FCT (Tab. 40/41), FCA (Tab. 42-45), tabela Iz
    proc_queda_tensao.dart     ← limite%, condutores carregados, fator harmônico

  orchestrator/
    normative_service.dart     ← NormativeService implements NormativeEngine
    specification_service.dart ← agrega spec_* pré e pós cálculo
    procedure_service.dart     ← agrega proc_*, monta DadosNormativos
```

---

## 4. Contrato público (NormativeEngine)

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

## 5. Specs — momentos de execução

| Spec | Momento | Depende de resultado? |
|---|---|---|
| `spec_combinacoes` | pré-cálculo | ❌ |
| `spec_aluminio` | pré-cálculo | ❌ |
| `spec_secao_minima` | auditoria | ✅ secaoFase |
| `spec_neutro` | auditoria | ✅ secaoFase, secaoNeutro |
| `spec_queda_tensao` | auditoria | ✅ quedaPercent |

---

## 6. Decisões de design específicas

**Tabelas como `const Map` Dart**
Sem JSON em runtime. Type-safe, zero overhead de parsing, funciona em Dart puro.
Cada tabela = um arquivo `src/tables/tabela_NN_nome.dart`.

**EPR compartilha tabelas com XLPE**
A norma usa colunas idênticas para EPR e XLPE (mesma temperatura máxima 90°C).
`Isolacao.epr.chaveTabela == 'XLPE_EPR'`. Distinção preservada no enum para
rastreabilidade e relatório.

**`null` para temperatura não admissível (Tabela 40)**
`null` distingue "fator inexistente" de "fator zero". Se `fctAr[isolacao][temp] == null`,
a `spec_combinacoes` (futuro) deve gerar `Violacao.temperaturaInadmissivel()`.

**`ArranjoCondutores?` nullable**
Campo só existe para métodos F e G. Para A1–E, `null` é semanticamente correto
— não há arranjo de condutores ao ar livre.

**`paramsAgrupamento` por chamada, não por instância**
O agrupamento varia por circuito dentro do mesmo projeto.
`resolverDadosNormativos(entrada, paramsAgrupamento)` — não no construtor do service.

**Violações acumuladas — nunca para na primeira**
`SpecificationService` roda todos os `spec_*` e acumula. Usuário vê todos os erros.

**`OrigemAlimentacao` relevante para alimentadores**
`pontoEntrega` → limite alimentador 1% (total 5%)
`trafoProprio` → limite alimentador 3% (total 7%)
Terminal sempre 4%, independente da origem.

---

## 7. Regras normativas implementadas

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
| 6.2.6.2 | Regras do neutro (Tab. 48) | `spec_neutro` |
| 6.2.7.1 | Limite queda alimentador | `spec_queda_tensao`, `proc_queda_tensao` |
| 6.2.7.2 | Limite queda terminal (4%) | `spec_queda_tensao`, `proc_queda_tensao` |

---

## 8. Cobertura de testes

| Arquivo | Casos |
|---|---|
| `spec_combinacoes_test` | 19 |
| `spec_aluminio_test` | 8 |
| `spec_neutro_test` | 7 |
| `spec_secao_queda_test` | 11 |
| `proc_ampacidade_test` | 14 |
| `proc_queda_tensao_test` | 9 |
| `normative_service_test` | 13 |
| **Total** | **81** |

---

## 9. Pendências (TODO)

| Item | Ciclo |
|---|---|
| `Violacao.temperaturaInadmissivel()` integrada à `spec_combinacoes` | 4.0 |
| Tabela de reatâncias Xi por seção e material | 4.0 |
| `spec_combinacoes` — restrições de faixas de tensão no mesmo conduto (6.2.9.5) | 4.x |
| `spec_combinacoes` — multipolar = um circuito (6.2.10.1) | 4.x |
| Neutro com harmônicas > 33% — Anexo F | 5.x |
| Condutores em paralelo (6.2.5.7.2) | 5.x |
