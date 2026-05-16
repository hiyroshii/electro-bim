# normative_engine

Package Dart puro que encapsula as regras da **ABNT NBR 5410:2004** aplicáveis
ao dimensionamento de instalações elétricas de baixa tensão.

**Não calcula** — fornece regras, dados normativos e verificações para que o
`electrical_engine` calcule. Zero dependências externas.

---

## Dependências

Nenhuma. Dart puro, sem Flutter, sem JSON em runtime.

---

## Como usar

O ponto de entrada é a interface `NormativeEngine`, implementada por `NormativeService`:

```dart
import 'package:normative_engine/normative_engine.dart';

final normative = NormativeService(
  origemAlimentacao: OrigemAlimentacao.pontoEntrega,
  perfil: const PerfilInstalacao(escopo: EscopoProjeto.residencial),
);

// 1. Pré-validação (antes do cálculo)
final violacoes = normative.verificarConformidade(entrada);
if (violacoes.isNotEmpty) throw EntradaInvalidaException(violacoes);

// 2. Dados normativos para o cálculo
final dados = normative.resolverDadosNormativos(entrada, params);
// dados.tabelaIz, dados.fatores, dados.queda, dados.secaoMinimaNormativa

// 3. Auditoria pós-cálculo
final auditoria = normative.auditar(entrada, resultado);
```

Specs standalone (nível de cômodo, sem circuito):

```dart
// Piso mínimo de pontos de iluminação — S-12
const spec = SpecMinimoIL();
final v = spec.verificar((comodo: TipoComodo.sala, areaM2: 20.0, numPontos: 4));

// Piso mínimo de TUGs — S-13
const spec = SpecMinimoTUG();
final v = spec.verificar((comodo: TipoComodo.cozinha, areaM2: 8.0, numTomadas: 2));
```

---

## Arquitetura

Ver [ARCHITECTURE.md](ARCHITECTURE.md) para estrutura detalhada, contratos,
fluxo de uso e rastreabilidade NBR.
