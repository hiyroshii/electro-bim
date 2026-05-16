# electrical_engine

Package Dart puro que implementa os algoritmos de dimensionamento de cargas e
circuitos elétricos conforme NBR 5410:2004.

**Não conhece a norma diretamente** — consome `normative_engine` para regras,
tabelas e fatores. Os `Calc*` são matemática pura.

---

## Dependências

| Package | Papel |
|---|---|
| [`normative_engine`](../normative_engine) | Regras NBR, tabelas, specs, fatores |
| [`uuid`](https://pub.dev/packages/uuid) | Geração de IDs de pontos de utilização |

---

## Como usar

O ponto de entrada é `DimensionamentoService`, que implementa `DimensionamentoEngine`:

```dart
import 'package:electrical_engine/electrical_engine.dart';
import 'package:normative_engine/normative_engine.dart';

final servico = DimensionamentoService(
  normative: NormativeService(
    origemAlimentacao: OrigemAlimentacao.pontoEntrega,
    perfil: const PerfilInstalacao(escopo: EscopoProjeto.residencial),
  ),
  catalogoDisjuntores: [Disjuntor(10), Disjuntor(16), Disjuntor(20), Disjuntor(25)],
);

// 1. Criar cômodo com sugestões normativas
final comodo = servico.criarComodoComSugestoes(
  idTipo: 'sala',
  label: 'Sala de Estar',
  regraTomadasComodo: RegraTomadasComodo.porPerimetro,
  areaM2: 20.0,
  perimetroM: 18.0,
);

// 2. Processar carga → circuitos agregados
final carga = servico.processarCarga(EntradaCarga(comodos: [comodo]));

// 3. Dimensionar circuito
final relatorio = servico.dimensionarCircuito(
  EntradaDimensionamento(
    idCircuito: 'C-001',
    tagCircuito: TagCircuito.tug,
    potenciaVA: 1500,
    // ...demais parâmetros
  ),
);
// relatorio.status, relatorio.secaoFinal, relatorio.ib, relatorio.inDisjuntor
```

---

## Fluxo de dimensionamento de circuito

```
EntradaDimensionamento
  │
  ├─ 1. verificarConformidade()     ← specs pré-cálculo (lança EntradaInvalidaException)
  ├─ 2. CalcCorrenteProjeto         ← Ib = P / (V × FP)
  ├─ 3. resolverDadosNormativos()   ← FCT, FCA, tabela Iz, limites queda
  ├─ 4. PoliticaDisjuntor           ← In ≥ Ib no catálogo (catálogo vem do app)
  ├─ 5. SelecionadorCondutor        ← seção ótima por ampacidade + queda
  └─ 6. calcularSecaoNeutro()       ← seção do neutro conforme 6.2.6.2
        │
        ▼
  RelatorioDimensionamento
  (status, secaoFinal, ib, inDisjuntor, izFinal, secaoNeutro, ΔV%)
```

---

## Contrato público

```dart
abstract interface class DimensionamentoEngine {
  Comodo criarComodoComSugestoes({...});
  Comodo criarComodoCustom({...});
  RelatorioCarga processarCarga(EntradaCarga entrada);
  RelatorioDimensionamento dimensionarCircuito(EntradaDimensionamento entrada);
}
```
