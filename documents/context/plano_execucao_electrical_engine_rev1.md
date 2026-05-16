# ElectroBIM — Plano de Execução do `electrical_engine` até MVP Completo
<!-- REV: 1 -->
<!-- CHANGELOG:
[Rev 1] - 13 05 2026
- ADD: Plano completo de execução com 12 itens identificados a partir de:
  - analise_electrical_engine_rev1.md (achados arquiteturais)
  - Leitura sistemática da ABNT NBR 5410:2004 (versão corrigida 2008)
- Cada item contém: trecho normativo, fórmula, esforço, critério de pronto.
- Documento autossuficiente — não requer consulta ao PDF da norma.
-->

> **Data:** 13 05 2026
> **Base:** ElectroBIM v0.3.5 — `electrical_engine` v1.0.x
> **Meta:** package 100% pronto para MVP (cobertura completa do escopo de dimensionamento residencial conforme NBR 5410)
> **Total de itens:** 12 (2 críticos · 6 vazamentos arquiteturais · 4 melhorias)

---

## 1. Princípio Orientador

Toda regra normativa pertence ao `normative_engine`. O `electrical_engine` só:

1. Faz **cálculos matemáticos** (Ib, Iz, ΔV, somatórios).
2. **Orquestra** o fluxo (carga → circuito → relatório).
3. **Consome contratos** do `normative_engine` (specs e procedures).

Qualquer constante normativa (potências mínimas, perímetros, percentuais) no electrical é **vazamento** e deve migrar.

---

## 2. Matriz de Itens

| # | Tipo | Item | Fonte NBR | Esforço | Sprint |
|---|---|---|---|---|---|
| 1 | 🔴 Bug | Fallback silencioso de Xi | 6.2.7.4 | 1h | S1 |
| 2 | 🟡 Melhoria | Ordenação do catálogo de disjuntores | 5.3.4.1 | 30 min | S1 |
| 3 | 🔴 Vazamento | Limites VA por circuito (TUG/IL/TUE) | 9.5.3 + 9.5.4 | 2h | S1 |
| 4 | 🔴 Vazamento | Potência IL por área | 9.5.2.1.2 | 2h | S2 |
| 5 | 🔴 Vazamento | Potência TUG por tipo de cômodo | 9.5.2.2.2 | 3h | S2 |
| 6 | 🔴 Vazamento | Quantidade mínima de pontos TUG | 9.5.2.2.1 | 3h | S2 |
| 7 | 🟡 Falta | Verificação centralizada Ib ≤ In ≤ Iz | 5.3.4.1.a | 1.5h | S3 |
| 8 | 🟡 Falta | Verificação I₂ ≤ 1,45·Iz | 5.3.4.1.b | 1h | S3 |
| 9 | 🟡 Falta | DR ≤ 30 mA obrigatório | 5.1.3.2 | 3h | S3 |
| 10 | 🟡 Falta | Circuito independente para In > 10 A | 9.5.3.1 | 2h | S3 |
| 11 | 🟡 Falta | Fator de demanda no alimentador | 4.2.1.1.2 | 4h | S4 |
| 12 | 🔵 Melhoria | Equilíbrio de fases (sugestão) | 4.2.5.6 | 4h | S4 |

**Total estimado:** ~27h de desenvolvimento (sem contar testes), distribuídas em **4 sprints**.

---

## 3. Itens Detalhados

### 🔴 Item 1 — Bug: Fallback silencioso na tabela de reatância (Xi)

**Localização:** `electrical_engine/lib/src/orchestrator/circuito/selecionador_condutor.dart:48`

```dart
final xi = ctx.tabelaXi[linha.secao] ?? 0.0;
```

**Problema:** Se a seção não existe na `tabelaXi`, prossegue com Xi = 0 (sem componente reativa). Para cabos ≥ 35 mm² com cosφ baixo, **subestima a queda de tensão**.

**Base normativa — NBR 5410 § 6.2.7.4:**

> *"Para o cálculo da queda de tensão num circuito deve ser utilizada a corrente de projeto do circuito. NOTA 1 — A corrente de projeto inclui as componentes harmônicas."*

A norma exige cálculo completo de ΔV. A fórmula completa (já implementada em `calc_queda_tensao.dart`) é:

```
ΔV = k · Ib · L · (R·cosφ + X·senφ)
k = 2 (mono/bifásico) | √3 (trifásico)
ΔV% = (ΔV / V) · 100
```

Sem Xi correto, o termo `X·senφ` zera e o resultado fica **otimista**.

**Solução escolhida:** Opção C — garantir no `normative_engine.resolverDadosNormativos()` que `tabelaXi` tem entrada para **toda** seção de `tabelaIz`. No selecionador, lançar `StateError` se faltar (em vez de fallback silencioso).

**Critério de pronto:**
- [ ] `normative_engine` valida no boot que `tabelaIz.length == tabelaXi.length` para cada (material, isolação).
- [ ] `selecionador_condutor.dart` substitui `?? 0.0` por `?? throw StateError(...)`.
- [ ] Teste novo: `quando_secao_sem_xi_lanca_state_error`.
- [ ] Teste novo: `quando_circuito_grande_com_cosphi_baixo_queda_e_correta` (validar que ΔV não está subestimada).

---

### 🟡 Item 2 — Melhoria: Catálogo de disjuntores assumido ordenado

**Localização:** `electrical_engine/lib/src/orchestrator/circuito/politica_disjuntor.dart`

```dart
final disjuntor = catalogo.firstWhere((d) => d.in_ >= ib, ...);
```

**Problema:** `firstWhere` retorna o primeiro encontrado, não o **menor** que atende. NBR 5410 § 5.3.4.1.a exige In **mínimo** que satisfaça Ib ≤ In.

**Solução:** Ordenar internamente:

```dart
final ordenado = [...catalogo]..sort((a, b) => a.in_.compareTo(b.in_));
final disjuntor = ordenado.firstWhere((d) => d.in_ >= ib, orElse: ...);
```

**Critério de pronto:**
- [ ] `PoliticaDisjuntor.selecionar` ordena internamente.
- [ ] Teste novo: `quando_catalogo_desordenado_seleciona_menor_in_que_satisfaz_ib`.

---

### 🔴 Item 3 — Vazamento: Limites VA por circuito (TUG/IL/TUE)

**Localização:** `electrical_engine/lib/src/orchestrator/carga/agregador_circuitos.dart`

```dart
const double _maxVaTug = 1500.0;
const double _maxVaIl = 600.0;
```

**Problema:** Constantes hardcoded no electrical, sem origem normativa explícita. A NBR não fixa limites em VA — fixa **corrente máxima** (16 A para circuito comum residencial) e **separação por função**.

**Base normativa — NBR 5410 § 9.5.3 (Locais de habitação — divisão da instalação):**

> *"§ 9.5.3.1 — Todo ponto de utilização previsto para alimentar, de modo exclusivo ou virtualmente dedicado, equipamento com corrente nominal superior a 10 A deve constituir um circuito independente."*
>
> *"§ 9.5.3.2 — Os pontos de tomada de cozinhas, copas, copas-cozinhas, áreas de serviço, lavanderias e locais análogos devem ser atendidos por circuitos exclusivamente destinados à alimentação de tomadas desses locais."*
>
> *"§ 9.5.3.3 — Em locais de habitação, admite-se [...] que pontos de tomada [...] e pontos de iluminação possam ser alimentados por circuito comum, desde que: a) a corrente de projeto (IB) do circuito comum (iluminação mais tomadas) não deve ser superior a 16 A; b) os pontos de iluminação não sejam alimentados, em sua totalidade, por um só circuito; c) os pontos de tomadas [...] não sejam alimentados, em sua totalidade, por um só circuito."*

**Base normativa — NBR 5410 § 4.2.5.5:**

> *"Os circuitos terminais devem ser individualizados pela função dos equipamentos de utilização que alimentam. Em particular, devem ser previstos circuitos terminais distintos para pontos de iluminação e para pontos de tomada."*

**Conclusão técnica:** O limite real não é "1500 VA" — é **Ib ≤ 16 A** (com tensão típica 127 V → 1932 VA mono, ou 220 V → 3520 VA bi/tri). Os 1500 VA são uma **convenção** baseada em 127 V × 16 A × ~0,75 FP, mas **a regra normativa é em A, não em VA**.

**Solução arquitetural:**

```
normative_engine → adicionar:
  spec_circuitos_terminais.dart
    - ibMaximoCircuitoComum(tensao) → 16.0 A
    - admitirCircuitoComumIlTug(comodo) → bool
    - exigirCircuitoExclusivoTomadasMolhadas(comodo) → bool
    - exigirCircuitoIndependente(corrente) → bool  // > 10 A

electrical_engine → refatorar:
  agregador_circuitos.dart
    - Recebe SpecCircuitosTerminais via construtor
    - Calcula Ib do agrupamento usando tensão real
    - Valida contra ibMaximoCircuitoComum() em vez de VA fixo
```

**Critério de pronto:**
- [ ] `normative_engine/src/specification/spec_circuitos_terminais.dart` criado.
- [ ] `agregador_circuitos.dart` consome a spec via construtor (DI).
- [ ] Constantes `_maxVaTug` e `_maxVaIl` removidas.
- [ ] Verificação considera a **tensão do circuito** (127/220/380 V).
- [ ] Testes existentes adaptados; 3 testes novos para os cenários de 9.5.3.1, 9.5.3.2, 9.5.3.3.

---

### 🔴 Item 4 — Vazamento: Potência de iluminação por área

**Localização:** `electrical_engine/lib/src/orchestrator/carga/gerador_pontos_comodo.dart`

```dart
const double _potenciaIlVa = 100.0;
```

**Problema:** 100 VA fixo independentemente da área do cômodo. **Errado para cômodos > 6 m²**.

**Base normativa — NBR 5410 § 9.5.2.1.2:**

> *"Na determinação das cargas de iluminação, como alternativa à aplicação da ABNT NBR 5413, conforme prescrito na alínea a) de 4.2.1.2.2, pode ser adotado o seguinte critério:*
>
> *a) em cômodos ou dependências com área igual ou inferior a 6 m², deve ser prevista uma carga mínima de 100 VA;*
>
> *b) em cômodo ou dependências com área superior a 6 m², deve ser prevista uma carga mínima de 100 VA para os primeiros 6 m², acrescida de 60 VA para cada aumento de 4 m² inteiros."*
>
> *"NOTA — Os valores apurados correspondem à potência destinada a iluminação para efeito de dimensionamento dos circuitos, e não necessariamente à potência nominal das lâmpadas."*

**Fórmula derivada:**

```
Se área ≤ 6 m²:    Pil = 100 VA
Se área > 6 m²:    Pil = 100 + 60 · floor((área - 6) / 4)
```

**Exemplos:**
| Área (m²) | Potência IL (VA) |
|---|---|
| 4 | 100 |
| 6 | 100 |
| 9,9 | 100 (área extra = 3,9 m², não completa 4) |
| 10 | 160 (área extra = 4 m², um incremento) |
| 14 | 220 (dois incrementos de 4 m²) |
| 18 | 280 |
| 22 | 340 |

**Base normativa adicional — NBR 5410 § 9.5.2.1.1:**

> *"Em cada cômodo ou dependência deve ser previsto pelo menos um ponto de luz fixo no teto, comandado por interruptor."*
>
> *"NOTA 2 — Admite-se que o ponto de luz fixo no teto seja substituído por ponto na parede em espaços sob escada, depósitos, despensas, lavabos e varandas, desde que de pequenas dimensões e onde a colocação do ponto no teto seja de difícil execução ou não conveniente."*

**Solução arquitetural:**

```
normative_engine → adicionar:
  spec_pontos_minimos_il.dart
    - potenciaMinimaIl(double areaM2) → double
    - quantidadeMinimaIl(Comodo c) → int   // sempre 1 ponto de teto

electrical_engine → refatorar:
  gerador_pontos_comodo.dart
    - Consome SpecPontosMinimosIl via DI
    - Gera 1 ponto IL por cômodo com potencia = spec.potenciaMinimaIl(areaM2)
  validador_comodo.dart
    - Valida via spec.quantidadeMinimaIl(c)
```

**Critério de pronto:**
- [ ] `spec_pontos_minimos_il.dart` no `normative_engine` com tabela parametrizada.
- [ ] Testes unitários cobrindo: ≤6, 6-10, 10-14, 14-18, casos de fronteira.
- [ ] `gerador_pontos_comodo` e `validador_comodo` consomem a spec.
- [ ] Constante `_potenciaIlVa` removida.

---

### 🔴 Item 5 — Vazamento: Potência de TUG por tipo de cômodo

**Localização:** `electrical_engine/lib/src/orchestrator/carga/gerador_pontos_comodo.dart`

```dart
const double _potenciaTugVa = 100.0;
```

**Problema:** 100 VA fixo para todo TUG. **Errado para cozinhas, copas, áreas de serviço, lavanderias, banheiros** (mínimo 600 VA até 3 pontos).

**Base normativa — NBR 5410 § 9.5.2.2.2:**

> *"A potência a ser atribuída a cada ponto de tomada é função dos equipamentos que ele poderá vir a alimentar e não deve ser inferior aos seguintes valores mínimos:*
>
> *a) em banheiros, cozinhas, copas, copas-cozinhas, áreas de serviço, lavanderias e locais análogos, no mínimo 600 VA por ponto de tomada, até três pontos, e 100 VA por ponto para os excedentes, considerando-se cada um desses ambientes separadamente. Quando o total de tomadas no conjunto desses ambientes for superior a seis pontos, admite-se que o critério de atribuição de potências seja de no mínimo 600 VA por ponto de tomada, até dois pontos, e 100 VA por ponto para os excedentes, sempre considerando cada um dos ambientes separadamente;*
>
> *b) nos demais cômodos ou dependências, no mínimo 100 VA por ponto de tomada."*

**Algoritmo derivado:**

```
// Por cômodo
fun potenciaPorPonto(comodo, indiceDoPonto):
    if comodo.tipo in [banheiro, cozinha, copa, copaCozinha, areaServico, lavanderia]:
        if totalTugsAreasMolhadas <= 6:
            return indiceDoPonto < 3 ? 600.0 : 100.0
        else:
            return indiceDoPonto < 2 ? 600.0 : 100.0
    else:
        return 100.0
```

**Observação crítica:** A regra dos "6 pontos no conjunto" requer **visão global** do projeto — não pode ser decidida cômodo por cômodo. Isso muda a arquitetura do gerador: ele precisa receber o projeto inteiro, ou ser chamado em duas fases (1ª contagem, 2ª atribuição).

**Solução arquitetural:**

```
normative_engine → adicionar:
  spec_pontos_minimos_tug.dart
    enum TipoAreaMolhada { banheiro, cozinha, copa, copaCozinha, areaServico, lavanderia }

    class SpecPontosMinimosTug {
      double potenciaPorPonto({
        required TipoComodo tipo,
        required int indicePonto,           // 0-based
        required int totalTugsNoComodo,
        required int totalTugsAreasMolhadasNoProjeto,
      });

      int quantidadePontosMinimos({          // ver Item 6
        required TipoComodo tipo,
        required double perimetroM,
        required double areaM2,
      });
    }

electrical_engine → refatorar:
  DimensionamentoCargaService.processar:
    Fase 1: gerar pontos sem potência (placeholder)
    Fase 2: somar total de TUGs em áreas molhadas no projeto
    Fase 3: atribuir potências via spec
```

**Critério de pronto:**
- [ ] Enum `TipoComodo` no `normative_engine` cobrindo todos os tipos da NBR.
- [ ] Spec implementa a regra em duas variantes (≤6 e >6 pontos no conjunto).
- [ ] Refactor do `DimensionamentoCargaService` em fases.
- [ ] 8+ testes unitários cobrindo cenários: cozinha 2 tomadas, cozinha 5 tomadas (4 com 600 VA + 1 com 100 VA até descobrir total do projeto), conjunto com 7+ pontos, etc.
- [ ] Constante `_potenciaTugVa` removida.

---

### 🔴 Item 6 — Vazamento: Quantidade mínima de pontos TUG por cômodo

**Localização:** `electrical_engine/lib/src/orchestrator/carga/validador_comodo.dart` + `gerador_pontos_comodo.dart`

```dart
const double _tugMinPorPerimetro = 5.0;
const int _tugMinimoFixo = 2;
const int _ilMinimo = 1;
```

**Problema:** Regra fixa "1 TUG a cada 5 m" para todos. A NBR diferencia por tipo de cômodo.

**Base normativa — NBR 5410 § 9.5.2.2.1:**

> *"O número de pontos de tomada deve ser determinado em função da destinação do local e dos equipamentos elétricos que podem ser aí utilizados, observando-se no mínimo os seguintes critérios:*
>
> *a) em banheiros, deve ser previsto pelo menos um ponto de tomada, próximo ao lavatório, atendidas as restrições de 9.1;*
>
> *b) em cozinhas, copas, copas-cozinhas, áreas de serviço, cozinha-área de serviço, lavanderias e locais análogos, deve ser previsto no mínimo um ponto de tomada para cada 3,5 m, ou fração, de perímetro, sendo que acima da bancada da pia devem ser previstas no mínimo duas tomadas de corrente, no mesmo ponto ou em pontos distintos;*
>
> *c) em varandas, deve ser previsto pelo menos um ponto de tomada;*
>
> *d) em salas e dormitórios devem ser previstos pelo menos um ponto de tomada para cada 5 m, ou fração, de perímetro, devendo esses pontos ser espaçados tão uniformemente quanto possível;*
>
> *e) em cada um dos demais cômodos e dependências de habitação devem ser previstos pelo menos:*
> *— um ponto de tomada, se a área do cômodo ou dependência for igual ou inferior a 2,25 m². Admite-se que esse ponto seja posicionado externamente ao cômodo ou dependência, a até 0,80 m no máximo de sua porta de acesso;*
> *— um ponto de tomada, se a área do cômodo ou dependência for superior a 2,25 m² e igual ou inferior a 6 m²;*
> *— um ponto de tomada para cada 5 m, ou fração, de perímetro, se a área do cômodo ou dependência for superior a 6 m², devendo esses pontos ser espaçados tão uniformemente quanto possível."*

**Algoritmo derivado:**

```
fun quantidadeMinimaTug(tipo, areaM2, perimetroM):
    switch tipo:
      banheiro                                → 1
      cozinha|copa|copaCozinha|areaServico|
        lavanderia                            → ceil(perimetroM / 3.5)  // + 2 acima pia
      varanda                                 → 1  (com exceções, ver nota)
      sala|dormitorio                         → ceil(perimetroM / 5.0)
      outros:
        se area ≤ 2.25 m²                     → 1 (admite externo)
        se 2.25 < area ≤ 6 m²                 → 1
        se area > 6 m²                        → ceil(perimetroM / 5.0)
```

**Solução arquitetural:** Estende `SpecPontosMinimosTug` do Item 5 com o método `quantidadePontosMinimos()`.

**Critério de pronto:**
- [ ] Enum `TipoComodo` cobre: banheiro, cozinha, copa, copaCozinha, areaServico, lavanderia, varanda, sala, dormitorio, outros.
- [ ] Spec implementa todos os 9 casos.
- [ ] `validador_comodo` consome a spec; constantes `_tugMinPorPerimetro` etc. removidas.
- [ ] Testes unitários cobrindo cada caso da NBR (ao menos 9 testes).

---

### 🟡 Item 7 — Falta: Verificação centralizada Ib ≤ In ≤ Iz

**Problema atual:** A verificação está distribuída:
- `politica_disjuntor` garante `In ≥ Ib`.
- `selecionador_condutor` garante `Iz ≥ In`.

Mas não há um **gate único** que sintetize a regra completa e produza diagnóstico estruturado.

**Base normativa — NBR 5410 § 5.3.4.1:**

> *"Para que a proteção dos condutores contra sobrecargas fique assegurada, as características de atuação do dispositivo destinado a provê-la devem ser tais que:*
>
> *a) IB ≤ In ≤ Iz; e*
> *b) I₂ ≤ 1,45 Iz*
>
> *Onde:*
> *— IB é a corrente de projeto do circuito;*
> *— Iz é a capacidade de condução de corrente dos condutores, nas condições previstas para sua instalação (ver 6.2.5);*
> *— In é a corrente nominal do dispositivo de proteção (ou corrente de ajuste, para dispositivos ajustáveis), nas condições previstas para sua instalação;*
> *— I₂ é a corrente convencional de atuação, para disjuntores, ou corrente convencional de fusão, para fusíveis."*

**Solução:** Criar `VerificadorCoordenacao` no electrical (não é norma — é verificação matemática):

```dart
final class VerificadorCoordenacao {
  ResultadoCoordenacao verificar({
    required double ib,
    required double in_,
    required double iz,
    required double i2,   // disjuntor: I2 = 1,45 · In (norma do produto)
  }) {
    final regraA = ib <= in_ && in_ <= iz;
    final regraB = i2 <= 1.45 * iz;
    return ResultadoCoordenacao(
      regraA: regraA,
      regraB: regraB,
      conforme: regraA && regraB,
    );
  }
}
```

**Critério de pronto:**
- [ ] `verificador_coordenacao.dart` criado em `orchestrator/circuito/`.
- [ ] `DimensionamentoCircuitoService` chama o verificador após seleção.
- [ ] `RelatorioDimensionamento` inclui o resultado da coordenação.
- [ ] Testes unitários para os 4 casos (regraA ok/falha × regraB ok/falha).

---

### 🟡 Item 8 — Falta: Verificação I₂ ≤ 1,45·Iz

Subitem do Item 7 — coberto pelo `VerificadorCoordenacao`.

**Base normativa — NBR 5410 § 5.3.4.1 (nota):**

> *"NOTA — A condição da alínea b) é aplicável quando for possível assumir que a temperatura limite de sobrecarga dos condutores (ver tabela 35) não venha a ser mantida por um tempo superior a 100 h durante 12 meses consecutivos, ou por 500 h ao longo da vida útil do condutor. Quando isso não ocorrer, a condição da alínea b) deve ser substituída por: I₂ ≤ Iz."*

**Decisão sugerida:** Para o MVP residencial, assumir o caso geral (100 h / 12 meses) — usar `I₂ ≤ 1,45·Iz`. Para a NOTA aplicar-se, é necessária análise de regime de operação que extrapola o escopo. Documentar a premissa no relatório.

**Critério de pronto:** Mesmo do Item 7 + flag `regimeOperacaoRegular: true` documentada no relatório.

---

### 🟡 Item 9 — Falta: DR ≤ 30 mA obrigatório

**Problema atual:** Nenhuma verificação de DR no `RelatorioDimensionamento`.

**Base normativa — NBR 5410 § 5.1.3.2.1.1:**

> *"O uso de dispositivos de proteção a corrente diferencial-residual com corrente diferencial-residual nominal IΔn igual ou inferior a 30 mA é reconhecido como proteção adicional contra choques elétricos."*

**Base normativa — NBR 5410 § 5.1.3.2.2 (Obrigatoriedade):**

> *"Além dos casos especificados na seção 9, e qualquer que seja o esquema de aterramento, devem ser objeto de proteção adicional por dispositivos a corrente diferencial-residual com corrente diferencial-residual nominal IΔn igual ou inferior a 30 mA:*
>
> *a) os circuitos que sirvam a pontos de utilização situados em locais contendo banheira ou chuveiro (ver 9.1);*
> *b) os circuitos que alimentem tomadas de corrente situadas em áreas externas à edificação;*
> *c) os circuitos de tomadas de corrente situadas em áreas internas que possam vir a alimentar equipamentos no exterior;*
> *d) os circuitos que, em locais de habitação, sirvam a pontos de utilização situados em cozinhas, copas-cozinhas, lavanderias, áreas de serviço, garagens e demais dependências internas molhadas em uso normal ou sujeitas a lavagens;*
> *e) os circuitos que, em edificações não-residenciais, sirvam a pontos de tomada situados em cozinhas, copas-cozinhas, lavanderias, áreas de serviço, garagens e, no geral, em áreas internas molhadas em uso normal ou sujeitas a lavagens."*
>
> *"NOTAS:*
> *1 — No que se refere a tomadas de corrente, a exigência de proteção adicional por DR de alta sensibilidade se aplica às tomadas com corrente nominal de até 32 A.*
> *3 — Admite-se a exclusão, na alínea d), dos pontos que alimentem aparelhos de iluminação posicionados a uma altura igual ou superior a 2,50 m."*

**Solução arquitetural:**

```
normative_engine → adicionar:
  spec_protecao_dr.dart
    enum ExigenciaDr {
      obrigatorio_30ma,    // banheiros, áreas externas, molhadas
      facultativo,
      naoSeAplica,
    }

    ExigenciaDr verificarExigencia({
      required TipoComodo tipo,
      required TagCircuito tag,
      required bool ehAreaExterna,
      required bool podeAlimentarEquipamentoExterno,
    });

electrical_engine → adicionar campo no RelatorioDimensionamento:
  exigenciaDr: ExigenciaDr
  dispositivoDrConfigurado: bool  // app informa via EntradaDimensionamento
  conforme: regraA && regraB && (exigenciaDr != obrigatorio_30ma || dispositivoDrConfigurado)
```

**Critério de pronto:**
- [ ] `spec_protecao_dr.dart` cobrindo as 5 alíneas de 5.1.3.2.2.
- [ ] Campo `dispositivoDrAteSensibilidadeMa: int?` em `EntradaDimensionamento`.
- [ ] Verificação no relatório: se exigência é "obrigatorio_30ma" e sensibilidade > 30 mA (ou null), status = `reprovadoProtecaoDr`.
- [ ] Novo status no enum `StatusDimensionamento`.
- [ ] 5 testes cobrindo cada alínea.

---

### 🟡 Item 10 — Falta: Circuito independente para In > 10 A

**Base normativa — NBR 5410 § 9.5.3.1:**

> *"Todo ponto de utilização previsto para alimentar, de modo exclusivo ou virtualmente dedicado, equipamento com corrente nominal superior a 10 A deve constituir um circuito independente."*

**Aplicação:** TUE (tomadas de uso específico) com Ib > 10 A devem ser sempre **um por circuito** — não podem ser agregados.

**Solução:** O `agregador_circuitos` deve detectar pontos TUE com potência tal que Ib > 10 A e impor que cada um vire seu próprio circuito.

```dart
// Em agregador_circuitos.dart, após agrupar por idCircuito:
for (final c in circuitos) {
  if (c.tag == TagCircuito.tue) {
    final ib = CalcCorrenteProjeto.calcular(
      potenciaVA: c.potenciaVA, tensaoV: tensao, fatorPotencia: fp,
      isTrifasico: false,
    );
    if (ib > 10.0 && temMultiplosPontos(c)) {
      // violação 9.5.3.1
    }
  }
}
```

**Critério de pronto:**
- [ ] `agregador_circuitos` recebe tensão e FP padrão por construtor.
- [ ] Detecta agrupamento ilegal de TUE > 10 A.
- [ ] Retorna `StatusCircuito.reprovadoCircuitoIndependente` (novo status).
- [ ] 2 testes: TUE 5 A com 2 pontos (OK), TUE 15 A com 2 pontos (reprovar).

---

### 🟡 Item 11 — Falta: Fator de demanda no alimentador

**Base normativa — NBR 5410 § 4.2.1.1.2:**

> *"Na determinação da potência de alimentação de uma instalação ou de parte de uma instalação devem ser computados os equipamentos de utilização a serem alimentados, com suas respectivas potências nominais e, em seguida, **consideradas as possibilidades de não-simultaneidade de funcionamento destes equipamentos**, bem como capacidade de reserva para futuras ampliações."*

**Observação:** A NBR 5410 reconhece a necessidade de aplicar fator de demanda, mas **não fixa a tabela** — remete às concessionárias locais e à boa prática. As referências usuais são:

- **Tabela de Demanda Iluminação + TUG (Cotrim, Mamede):** decresce com o número total de pontos.
- **Tabela de Demanda TUE (chuveiro, ar-condicionado etc.):** baseada em quantidade de aparelhos similares.

Para o MVP, sugere-se adotar tabela de referência da concessionária mais relevante (ex.: ENEL-RJ ou CEMIG) e parametrizar:

```dart
// Estrutura sugerida:
abstract class TabelaDemanda {
  double fatorIluminacaoTug(int totalPontos);
  double fatorTueChuveiro(int qtdChuveiros);
  double fatorTueArCondicionado(int qtdEquipamentos);
  // ... outros tipos
}
```

**Solução arquitetural:**

```
normative_engine → adicionar:
  spec_fator_demanda.dart
    - Interface FatorDemanda
    - Implementação padrão (tabela genérica baseada em prática brasileira)

electrical_engine → refatorar:
  dimensionamento_carga_service.dart
    - Calcular demandaIl, demandaTug, demandaTue separadamente
    - VA total = soma das demandas aplicadas
    - Manter VA total instalado para comparação
```

**Critério de pronto:**
- [ ] `spec_fator_demanda.dart` com tabela padrão documentada.
- [ ] `RelatorioCarga` inclui `vaTotalInstalado` e `vaTotalDemanda`.
- [ ] Cálculo do alimentador (futuro) usará `vaTotalDemanda`.
- [ ] Documentação da fonte (ex.: "Tabela de referência ENEL-RJ").

---

### 🔵 Item 12 — Melhoria: Sugestão de equilíbrio de fases

**Base normativa — NBR 5410 § 4.2.5.6:**

> *"As cargas devem ser distribuídas entre as fases, de modo a obter-se o maior equilíbrio possível."*

**Para instalações trifásicas:** atribuir circuitos às fases A, B, C minimizando o desequilíbrio.

**Algoritmo sugerido:** Greedy (a cada novo circuito, atribuir à fase de menor carga acumulada).

**Solução:**

```
electrical_engine → adicionar (opcional para MVP):
  orchestrator/projeto/balanceador_fases.dart
    Map<String, Fase> distribuir(List<CircuitoAgregado> circuitos)
```

**Critério de pronto:**
- [ ] Algoritmo greedy implementado.
- [ ] `RelatorioCarga` inclui `distribuicaoFases` (mapa circuito → fase).
- [ ] Métrica `desequilibrioPercentual` exposta.

> Item opcional para o MVP — pode ficar para Ciclo 5.

---

## 4. Cronograma — 4 Sprints

### Sprint 1 (Ciclo 4.1) — Correções imediatas

| Item | Esforço | Critério de pronto |
|---|---|---|
| 1 — Fallback Xi | 1h | Test passa com circuito 70 mm² cosφ=0,7 |
| 2 — Ordenação disjuntor | 30 min | Test catálogo desordenado passa |
| 3 — Limites VA → ibMax | 2h | Spec criado, agregador refatorado, testes 9.5.3.1/2/3 verdes |

**Subtotal:** ~3,5h · **Saída:** electrical_engine v1.1.0

---

### Sprint 2 (Ciclo 4.2) — Pontos mínimos por cômodo

| Item | Esforço | Critério de pronto |
|---|---|---|
| 4 — IL por área | 2h | Spec + 6 testes (área 4, 6, 10, 14, 18, 22 m²) |
| 5 — TUG potência por tipo | 3h | Spec + 8 testes (regras a/b/c/d/e + caso >6 pontos) |
| 6 — TUG quantidade por tipo | 3h | Spec + 9 testes (um por alínea 9.5.2.2.1) |

**Subtotal:** ~8h · **Saída:** electrical_engine v1.2.0

> Após Sprint 2, **toda regra normativa de previsão de carga** vive no `normative_engine`. Princípio arquitetural restaurado.

---

### Sprint 3 (Ciclo 4.3) — Verificações de proteção

| Item | Esforço | Critério de pronto |
|---|---|---|
| 7+8 — Coordenação Ib ≤ In ≤ Iz e I₂ ≤ 1,45·Iz | 2,5h | `VerificadorCoordenacao` + 4 testes |
| 9 — DR ≤ 30 mA | 3h | Spec + campo na entrada + status novo + 5 testes |
| 10 — Circuito independente >10 A | 2h | Detecção no agregador + 2 testes |

**Subtotal:** ~7,5h · **Saída:** electrical_engine v1.3.0

---

### Sprint 4 (Ciclo 4.4) — Alimentador e refinamento

| Item | Esforço | Critério de pronto |
|---|---|---|
| 11 — Fator de demanda | 4h | Spec + tabela padrão + relatório com vaInstalado/vaDemanda |
| 12 — Equilíbrio de fases (opcional) | 4h | Balanceador + métrica de desequilíbrio |

**Subtotal:** ~8h (4h sem opcional) · **Saída:** electrical_engine v2.0.0 → **MVP completo**

---

## 5. Critérios Globais de "Pronto"

Ao final do Sprint 4, o package deve atender:

### Arquiteturais
- [ ] **Zero constantes normativas** em `electrical_engine/lib/src/`. Toda regra NBR consultada via `normative_engine` (verificável por grep: `grep -rE "(_min|_max|_potencia)" electrical_engine/lib`).
- [ ] **Imports absolutos** (`package:electrical_engine/...`) em todos os arquivos internos.
- [ ] **Status como retorno** mantido em todos os fluxos de dimensionamento; exceções apenas para violação normativa pré-cálculo.
- [ ] **`Comodo.criar` factory** removida ou refatorada para uso real.

### Funcionais (cobertura NBR)
- [ ] § 4.2.1.2 (previsão de carga) — implementado via `normative_engine`.
- [ ] § 4.2.5.5 (separação IL × TUG) — verificado no agregador.
- [ ] § 5.1.3.2 (DR ≤ 30 mA) — verificado por circuito.
- [ ] § 5.3.4.1 (coordenação Ib/In/Iz/I₂) — verificado por circuito.
- [ ] § 6.2.6 (seção neutro) — já implementado (Ciclo 4.1).
- [ ] § 6.2.7 (queda de tensão) — implementado com Xi correto.
- [ ] § 9.5.2.1 (IL — pontos e potência) — implementado.
- [ ] § 9.5.2.2 (TUG — pontos e potência) — implementado por tipo.
- [ ] § 9.5.3.1 (circuito independente >10 A) — verificado.
- [ ] § 9.5.3.2 (circuito exclusivo áreas molhadas) — verificado.
- [ ] § 9.5.3.3 (limites do circuito comum) — verificado.
- [ ] § 9.5.4 (proteção sobrecorrente, dispositivo multipolar) — verificado.

### Qualidade
- [ ] **Cobertura de testes** ≥ 90% nas pastas `orchestrator/` e `calculos/`.
- [ ] **Testes de cenário** ponta a ponta (E2E) com 5 projetos-modelo: apto 1 quarto, apto 2 quartos, casa 3 quartos com área externa, casa com piscina, residência com aquecedor elétrico instantâneo.
- [ ] **README.md** real (substitui o template).
- [ ] **CHANGELOG.md** raiz consolidado com versões 1.0.0 → 2.0.0.
- [ ] **0 warnings** no `dart analyze`.

---

## 6. Riscos e Mitigações

| Risco | Probabilidade | Mitigação |
|---|---|---|
| Refactor do gerador em duas fases (Item 5) introduz bugs | Média | Testes de regressão antes da migração + smoke tests E2E |
| Tabela de fator de demanda diverge de concessionárias | Alta | Tornar a tabela parametrizável; documentar a referência usada |
| Premissa "regime regular" do I₂ ≤ 1,45·Iz mal aplicada | Baixa | Marcar a flag visível no relatório com link à seção 5.3.4.1 |
| Quebra do contrato público `DimensionamentoEngine` | Alta | Manter retrocompatibilidade via overload; major bump na v2.0.0 |

---

## 7. Resumo Executivo

**Estado atual:** `electrical_engine` v1.0.x faz dimensionamento de circuito corretamente (cálculos puros validados contra a norma) mas tem **6 vazamentos normativos** na camada de carga e **5 lacunas de verificação** nas camadas de proteção e alimentador.

**Plano:** 4 sprints, ~27 horas de desenvolvimento, entregando **v2.0.0 com 100% de cobertura do escopo de dimensionamento residencial conforme NBR 5410**.

**Saída esperada:**
- 1 bug crítico corrigido (fallback Xi)
- 6 vazamentos migrados para o `normative_engine`
- 5 novas verificações normativas (coordenação, DR, circuito independente, fator de demanda)
- Arquitetura limpa: `electrical_engine` = matemática + orquestração; `normative_engine` = norma.

---

## 8. Anexo — Tabela 47 (Seções Mínimas)

Transcrita de NBR 5410 § 6.2.6.1.1 — para consulta sem PDF:

| Tipo de linha | Utilização | S mín (mm²) | Material |
|---|---|---|---|
| Cabos isolados (instalações fixas) | Iluminação | 1,5 | Cu |
| Cabos isolados (instalações fixas) | Iluminação | 16 | Al |
| Cabos isolados (instalações fixas) | Força (inclui TUG) | 2,5 | Cu |
| Cabos isolados (instalações fixas) | Força (inclui TUG) | 16 | Al |
| Cabos isolados (instalações fixas) | Sinalização e controle | 0,5 | Cu |
| Condutores nus | Força | 10 | Cu |
| Condutores nus | Força | 16 | Al |
| Condutores nus | Sinalização e controle | 4 | Cu |
| Linhas flexíveis | Aplicação geral | 0,75 | Cu |
| Circuitos a extrabaixa tensão | Aplicações especiais | 0,75 | Cu |

> *Notas: TUG é classificado como circuito de força. Para sinalização/controle eletrônico admite-se mínimo de 0,1 mm² (Cu).*

---

## 9. Anexo — Tabela 48 (Seção Reduzida do Neutro)

Transcrita de NBR 5410 § 6.2.6.2.6 — válida quando: circuito presumivelmente equilibrado + harmônica 3ª ≤ 15% + neutro protegido contra sobrecorrentes:

| Fase (mm²) | Neutro (mm²) |
|---|---|
| ≤ 25 | = S (mesma seção da fase) |
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

> *Para taxa de 3ª harmônica > 33% pode ser necessária seção do neutro **maior** que a da fase — ver Anexo F da NBR.*

---

## 10. Anexo — Limites de Queda de Tensão (§ 6.2.7.1)

| Origem da alimentação | Trecho | Limite total |
|---|---|---|
| Concessionária (ponto de entrega em BT) | Ponto de entrega → último ponto de utilização | **5%** |
| Transformador da unidade consumidora (MT/BT próprio) | Terminais secundários do trafo → último ponto | **7%** |
| Concessionária (ponto de entrega no trafo) | Terminais secundários do trafo → último ponto | **7%** |
| Grupo gerador próprio | Terminais de saída do gerador → último ponto | **7%** |

**Limite específico para circuitos terminais (§ 6.2.7.2):** ΔV ≤ **4%** em qualquer caso.

**Decomposição típica usada no projeto (rev7):**
| Trecho | Concessionária | Próprio |
|---|---|---|
| Alimentador (MED → QDG → QD) | 1% | 3% |
| Terminal (QD → ponto) | 4% | 4% |
| **Total** | **5%** | **7%** |

---

## 11. Anexo — Fórmulas Consolidadas

Para referência sem consultar arquivos:

### Corrente de projeto (§ 6.1.3.1.2)
```
Mono/bifásico:  Ib = P / (V · cosφ)
Trifásico:      Ib = P / (√3 · V · cosφ)
```

### Capacidade de condução corrigida (§ 6.2.5)
```
Iz = Iz_base · FCT · FCA · F_harmonica

F_harmonica = 0,86 quando 4 condutores carregados e harmônica > 15% (§ 6.2.5.6.1)
            = 1,0 caso contrário
```

### Queda de tensão (§ 6.2.7.4)
```
ΔV = k · Ib · L · (R·cosφ + X·senφ)
k = 2 (mono/bifásico) | √3 (trifásico)
R = resistividade / seção
X = reatância (xi) lookup por seção
ΔV% = (ΔV / V) · 100
```

### Resistividade (§ 6.2.5, derivado de regime térmico)
```
Material   PVC (70°C)    XLPE/EPR (90°C)
Cobre      0,02308       0,02538
Alumínio   0,03775       0,04150
                                          [Ω·mm²/m]
```

### Coordenação proteção (§ 5.3.4.1)
```
Regra A:  Ib ≤ In ≤ Iz
Regra B:  I2 ≤ 1,45 · Iz     (I2 = 1,45·In para disjuntores comuns)
```

---

## Referências Internas

- `analise_electrical_engine_rev1.md` — Análise técnica que originou este plano
- `contexto_projeto_electrobim_rev8.md` — Estado atual do projeto
- `regras_nbr5410_classificadas_rev1.md` — Classificação prévia das regras
- `ABNT NBR 5410:2004` (versão corrigida 17.03.2008) — base normativa única
