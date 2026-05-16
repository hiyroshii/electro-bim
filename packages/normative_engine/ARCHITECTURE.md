# Architecture — normative_engine

**Versão deste documento:** 0.5.0
**Norma de referência:** ABNT NBR 5410:2004 — Instalações elétricas de baixa tensão

---

## 1. Propósito

`normative_engine` é um package Dart puro que encapsula as regras da NBR 5410:2004.
Não faz cálculos de dimensionamento — fornece os dados, limites e verificações normativas
que o `dimensionamento_engine` consome para calcular.

Sem dependências externas. Publicável no pub.dev.

---

## 2. Os 4 contratos

O engine organiza toda a lógica normativa em quatro contratos:

| Contrato | Interface | Responsabilidade |
|---|---|---|
| Specification | `ISpecification<T>` | Verifica conformidade — devolve `List<Violacao>` |
| Procedure | `IProcedure<I, O>` | Resolve dados normativos — consulta tabelas e fatores |
| Classification | `IClassification<I>` | Classifica contexto — determina influências e perfil |
| Verification | `IVerification<M, P, R>` | Verifica medições em campo contra projeto |

### 2.1 ISpecification

```dart
abstract interface class ISpecification<T> {
  List<Violacao> verificar(final T entrada);
  bool aplicavelA(final PerfilInstalacao perfil);
}
```

- Nunca lança exceção — acumula todas as violações
- Retorna lista vazia se conforme
- `aplicavelA` é **abstract**: cada spec declara explicitamente sua aplicabilidade
  - Specs universais: `=> true`
  - Specs restritas: filtram por escopo ou influência (ex: `SpecAluminio`)
- O `SpecificationService` só chama `verificar()` se `aplicavelA(perfil)` retornar `true`

### 2.2 IProcedure

```dart
abstract interface class IProcedure<I, O> {
  O resolver(final I entrada);
}
```

- Pré-condição: a entrada já foi validada por `ISpecification`
- Entrada tipada por `I`, saída por `O` — par declarado no `typedef` de cada procedure

---

## 3. Fluxo de uso

```
dimensionamento_engine
        │
        ▼
 NormativeEngine (contrato público)
        │
        ├─ 1. verificarConformidade(entrada)   ← specs pré-cálculo
        │       retorna List<Violacao>
        │       abortar se não vazia
        │
        ├─ 2. resolverDadosNormativos(entrada)  ← procedures
        │       retorna DadosNormativos
        │       (tabelas Iz, fatores FCT/FCA, limites queda, Xi)
        │
        │  [dimensionamento_engine executa os cálculos]
        │
        └─ 3. auditar(entrada, resultado)       ← specs pós-cálculo
                retorna List<Violacao>
```

**Invariante:** o `dimensionamento_engine` nunca importa nada de `src/` diretamente —
apenas `NormativeEngine`, os models e os enums expostos pelo barrel.

---

## 4. Orchestrators

Os orchestrators coordenam os contratos — não contêm lógica normativa.

```
NormativeService             ← fachada raiz, implementa NormativeEngine
├── ClassificationService    ← resolve PerfilInstalacao via IClassification
├── SpecificationService     ← filtra specs por aplicavelA(perfil)
├── ProcedureService         ← coordena ProcAmpacidade + ProcQuedaTensao
└── VerificationService      ← skeleton (Fase 3+)
```

### 4.1 SpecificationService

```
verificarConformidade(entrada)
  → para cada spec: if (spec.aplicavelA(perfil)) ...spec.verificar(entrada)
  → specs: SpecCombinacoes + SpecAluminio + SpecDispositivoMultipolar

auditar(entrada, resultado)
  → SpecSobrecarga + SpecSecaoMinima + SpecNeutro + SpecQuedaTensao
```

A separação pré/pós-cálculo é intencional: specs de combinação só precisam da entrada;
specs de sobrecarga e queda precisam do resultado calculado.

### 4.2 ProcedureService

Consulta `ProcAmpacidade` e `ProcQuedaTensao`, agrega tabela Xi e seção mínima normativa,
e monta o `DadosNormativos` completo.

### 4.3 ClassificationService

Recebe dados brutos de influência externa e devolve um `PerfilInstalacao` consolidado:

```
resolverPerfil(escopo, competencia?, material?)
  → ClassCompetenciaBa   → CodigoInfluencia? (ba3 / ba4 / ba5)
  → ClassFugaEmergenciaBd → CodigoInfluencia? (bd1 / bd2 / bd3 / bd4)
  → PerfilInstalacao(escopo: escopo, influencias: {ba?, bd?})
```

---

## 5. Modelos de domínio

| Modelo | Direção | Descrição |
|---|---|---|
| `EntradaNormativa` | entrada | Parâmetros do circuito: tensão, fases, isolação, método, material, temperatura... |
| `DadosNormativos` | saída de procedure | Tabelas Iz, fatores FCT/FCA, parâmetros de queda, tabela Xi, seção mínima |
| `ResultadoNormativo` | entrada de auditoria | Resultado já calculado: seção fase/neutro, queda %, Ib, In, Iz final |
| `Violacao` | saída de spec | Código, descrição e referência normativa de uma inconformidade |

---

## 6. Estrutura de pastas (estado atual — Fase 3.3)

```
lib/src/
├── contracts/
│   ├── i_specification.dart    ← + aplicavelA(PerfilInstalacao)
│   ├── i_procedure.dart
│   ├── i_classification.dart
│   ├── i_verification.dart     ← skeleton
│   └── normative_engine.dart
│
├── domain/
│   ├── condutor/               ← Isolacao, Arquitetura, Material,
│   │                              MetodoInstalacao, ArranjoCondutores
│   ├── instalacao/             ← EscopoProjeto, TagCircuito, OrigemAlimentacao,
│   │                              Tensao, NumeroFases, FaixaTensao, PerfilInstalacao
│   ├── influencias/            ← CodigoInfluencia
│   └── locais/                 ← TipoComodo
│
├── models/                     ← EntradaNormativa, DadosNormativos,
│                                  ResultadoNormativo, Violacao
│
├── tables/
│   ├── tabela_35…39_iz_*.dart  ← ampacidade por isolação e método (Tab. 36-39)
│   ├── tabela_40…45_f*.dart    ← fatores FCT (Tab. 40) e FCA (Tab. 41, 42-45)
│   ├── tabela_47_48_*.dart     ← seção mínima do neutro (Tab. 47-48)
│   ├── tabela_xi_reatancia.dart← Xi Ω/km por seção
│   └── habitacao/              ← tabela_carga_iluminacao, tabela_potencia_tug (T-13, T-14)
│
├── classification/
│   ├── influencias_externas/   ← ClassCompetenciaBa, ClassFugaEmergenciaBd
│   └── instalacao/             ← ClassPerfilPadraoPorEscopo
│
├── procedure/
│   ├── condutor/               ← ProcAmpacidade, ProcSecaoNeutro
│   ├── tensao/                 ← ProcQuedaTensao
│   └── carga/                  ← ProcCargaResidencial (P-6)
│
├── specification/
│   ├── condutor/               ← SpecCombinacoes, SpecAluminio,
│   │                              SpecSecaoMinima, SpecNeutro
│   ├── protecao/               ← SpecSobrecarga, SpecDispositivoMultipolar
│   ├── instalacao/             ← SpecQuedaTensao
│   └── carga/                  ← SpecMinimoIL (S-12), SpecMinimoTUG (S-13)
│
└── orchestrator/
    ├── normative_service.dart
    ├── classification_service.dart
    ├── specification_service.dart
    ├── procedure_service.dart
    └── verification_service.dart     ← skeleton
```

---

## 7. Estrutura de pastas (alvo — v1.0.0)

Hierarquia máxima: 3 níveis (`<categoria>/<dominio>/<arquivo>.dart`).

```
lib/src/
├── contracts/
│   ├── i_specification.dart
│   ├── i_procedure.dart
│   ├── i_classification.dart
│   └── i_verification.dart
│
├── domain/
│   ├── condutor/                  ← Isolacao, Arquitetura, Material, MetodoInstalacao
│   ├── instalacao/                ← EscopoProjeto, TagCircuito, OrigemAlimentacao, PerfilInstalacao
│   ├── influencias/               ← CodigoInfluencia, GrauProtecaoIP
│   ├── locais/                    ← TipoComodo, VolumeBanheiro, SituacaoChoque
│   ├── carga/                     ← EntradaCarga (sealed) + variantes por escopo
│   └── resultados/                ← Violacao, ResultadoNormativo, ResultadoEnsaio
│
├── tables/
│   ├── ampacidade/                ← Tab. 36-39 (métodos A/B/C/D/E/F/G)
│   ├── correcao/                  ← Tab. 40-47 (temperatura, solo, agrupamento)
│   ├── influencias_externas/      ← Tab. 1-24 (famílias AA-CB, 20 arquivos)
│   ├── protecao/                  ← Tab. 25-26/30-31/54
│   ├── instalacao/                ← Tab. 32-33/59
│   ├── linha/                     ← R e Xi Ω/km
│   ├── habitacao/                 ← carga iluminação e TUG
│   ├── verificacao/               ← Tab. 60 resistência isolamento
│   └── anexos/                    ← Anexo A (faixas), C (UL), F (harmônicas)
│
├── classification/
│   ├── influencias_externas/      ← 10 classes (AA, AD, BA, BB, BC, BD, BE, CA, CB...)
│   ├── instalacao/                ← perfil padrão por escopo, esquema aterramento
│   ├── ambiente/                  ← situação choque, categoria sobretensão
│   └── locais/                    ← volume banheiro
│
├── procedure/
│   ├── condutor/                  ← ProcAmpacidade, ProcFatorCorrecao, ProcSecaoNeutro
│   ├── tensao/                    ← ProcQuedaTensao, ProcTensaoContato
│   ├── protecao/                  ← ProcCorrenteCurtoCircuito, ProcIntegralJoule
│   ├── aterramento/               ← ProcSecaoPE
│   ├── carga/                     ← residencial, comercial, industrial, fator demanda
│   └── industrial/                ← partida motor, harmônicas
│
├── specification/
│   ├── condutor/                  ← S-1 combinacoes, S-2 aluminio, S-4 secao_minima...
│   ├── protecao/                  ← S-3 sobrecarga, S-6 multipolar, S-7/S-8/S-14/S-16...
│   ├── instalacao/                ← S-5 queda tensao, grau IP, método admitido...
│   ├── carga/                     ← S-9 a S-13 (circuitos e pontos mínimos)
│   ├── aterramento/               ← S-20 a S-22 + equalizacao
│   ├── locais_especificos/        ← S-15 banheiro, piscina, sauna...
│   └── industrial/                ← S-17 motor, S-18 neutro harmônicas
│
├── verification/
│   ├── verify_continuidade_pe.dart         ← V-1
│   ├── verify_resistencia_isolamento.dart  ← V-2
│   ├── verify_seccionamento_automatico.dart ← V-3
│   ├── verify_dr.dart                      ← V-4
│   ├── verify_resistencia_aterramento.dart ← V-5
│   ├── verify_resistencia_pe.dart          ← V-6
│   └── verify_tensao_aplicada.dart         ← V-7
│
└── orchestrator/
    ├── normative_service.dart
    ├── classification_service.dart
    ├── specification_service.dart
    ├── procedure_service.dart
    └── verification_service.dart
```

---

## 8. Convenções

**Nomes de arquivo:** `<contrato>_<dominio>.dart` — `spec_sobrecarga.dart`, `proc_ampacidade.dart`.

**Construtores antes de campos** (`sort_constructors_first`).

**Parâmetros finais** (`prefer_final_parameters`) em todos os métodos e closures.

**Sem sub-barris.** Cada arquivo importa exatamente o que usa.
O único arquivo exportado publicamente é `lib/normative_engine.dart`, que expõe:
- `contracts/normative_engine.dart`
- todos os models e enums necessários ao consumidor

**Specs nunca lançam exceção.** Validação de entrada é responsabilidade do chamador.

**Procedures assumem entrada válida.** O `SpecificationService` deve rodar antes.

---

## 9. Rastreabilidade

IDs do manual `manual_normativo_electrobim_rev1.md`:

| Prefixo | Categoria | Exemplos |
|---|---|---|
| D-n | Domínio / modelo | D-1 EscopoProjeto, D-9 Violacao |
| T-n | Tabela NBR | T-2 Tab.36, T-6 Tab.40 |
| C-n | Classification | C-1 PerfilPadrao, C-3 SituacaoChoque |
| P-n | Procedure | P-1 Ampacidade, P-2 QuedaTensao |
| S-n | Specification | S-1 Combinacoes, S-3 Sobrecarga |
| V-n | Verification | V-1 ContinuidadePE, V-2 ResistenciaIsolamento |
