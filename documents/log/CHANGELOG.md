# CHANGELOG — Projeto ElectroBIM

Registro consolidado de todas as alterações do projeto.
Organizado por ciclo de desenvolvimento e versão de cada arquivo.

---

## Ciclo 3 — Feature dimensionamento_carga (27 04 2026)

Implementação completa da feature de previsão de carga conforme NBR 5410:2004 seção 9.5.2.
Substitui código alpha anterior (descartado do Drive) por arquitetura alinhada ao padrão do projeto.

### Arquivos Novos

| Arquivo | Versão | Localização |
|---|---|---|
| `dominio_regra_tomada.dart` | 1.0.0 | `lib/core/dominio/` |
| `repositorio_config_comodo_json.dart` | 1.0.0 | `lib/core/repositorio/` |
| `repositorio_comodos.dart` | 1.0.0 | `lib/core/repositorio/` |
| `modelo_comodo.dart` | 1.0.0 | `lib/features/dimensionamento_carga/modelos/` |
| `modelo_ponto_carga.dart` | 1.0.0 | `lib/features/dimensionamento_carga/modelos/` |
| `modelo_tue.dart` | 1.0.0 | `lib/features/dimensionamento_carga/modelos/` |
| `modelo_entrada_carga.dart` | 1.0.0 | `lib/features/dimensionamento_carga/modelos/` |
| `modelo_relatorio_carga.dart` | 1.0.0 | `lib/features/dimensionamento_carga/modelos/` |
| `politica_iluminacao.dart` | 1.0.0 | `lib/features/dimensionamento_carga/politicas/` |
| `algoritmo_gerador_pontos_comodo.dart` | 1.0.1 | `lib/features/dimensionamento_carga/algoritmos/` |
| `algoritmo_validador_comodo.dart` | 1.0.1 | `lib/features/dimensionamento_carga/algoritmos/` |
| `algoritmo_agregador_circuitos.dart` | 1.0.1 | `lib/features/dimensionamento_carga/algoritmos/` |
| `servico_dimensionamento_carga.dart` | 1.0.0 | `lib/features/dimensionamento_carga/servicos/` |

#### `dominio_regra_tomada.dart` — 1.0.0
- ADD: sealed class RegraTomada com 4 subclasses cobrindo a 9.5.2.2
- ADD: RegraTomadaPerimetro (cozinhas, salas, dormitórios)
- ADD: RegraTomadaMinimoFixo (banheiros, varandas)
- ADD: RegraTomadaDemaisComodos (alínea e — depósitos, lavabos)
- ADD: RegraTomadaPotenciaCircuito (área técnica — 4.2.1.2.3 alínea b)
- ADD: funções privadas `_pontosPorPerimetro`, `_vaProgressivo`, `_vaFixo` (absorvem `calculo_tug.dart`)

#### `repositorio_config_comodo_json.dart` — 1.0.0
- ADD: ConfigComodoJson como DTO de parsing do config_comodos.json
- ADD: factory fromJson com parsing seguro e tolerância a chaves ausentes

#### `repositorio_comodos.dart` — 1.0.0
- ADD: carregamento eager via factory async `RepositorioComodos.carregar()`
- ADD: dicionário interno const de IDs de regra → instâncias de RegraTomada
- ADD: ComodoResolvido como output tipado (string → RegraTomada)
- ADD: listarDisponiveis() para popular dropdowns na UI
- ADD: falha rápida com ArgumentError descritivo se JSON referenciar ID desconhecido

#### `modelo_comodo.dart` — 1.0.0
- ADD: modelo central com factory `criar()` e validações acumuladas
- ADD: pontosTug e pontosIl separados para mapear abas da UI
- ADD: copyWith para edições incrementais
- ADD: getter `vaTotalComodo` (soma TUG + IL + TUE)

#### `modelo_ponto_carga.dart` — 1.0.0
- ADD: PontoCarga com factories `sugerido()` (gerador) e `editar()` (UI)
- ADD: vaMinimoCircuito para propagação do piso de circuito de área técnica

#### `modelo_tue.dart` — 1.0.0
- ADD: factories `Tue.fromVa()` e `Tue.fromW()`
- ADD: armazenamento somente em VA (entrada W+FP normalizada e descartada)

#### `modelo_entrada_carga.dart` — 1.0.0
- ADD: EntradaCarga como input do serviço (projeto inteiro, não cômodo isolado)

#### `modelo_relatorio_carga.dart` — 1.0.0
- ADD: PrevisaoComodo + StatusPrevisao + ViolacaoNorma + TipoViolacao
- ADD: CircuitoAgregado + StatusCircuito + ViolacaoCircuito + TipoViolacaoCircuito
- ADD: RelatorioCarga + StatusRelatorio (output final do serviço)

#### `politica_iluminacao.dart` — 1.0.0
- ADD: PoliticaIluminacao aplicando 9.5.2.1.2 (100 VA até 6 m², +60 VA cada 4 m²)
- ADD: ResultadoIluminacao com VA e pontosMinimos
- CHG: absorve CalculoIluminacao do alpha (era arquivo separado)

#### `algoritmo_gerador_pontos_comodo.dart` — 1.0.1
- ADD: gerador de pontos sugeridos com idCircuito padrão "TAG-COMODO-NN"
- ADD: propagação de vaMinimoCircuito quando regra é RegraTomadaPotenciaCircuito
- FIX (1.0.1): const constructor agora atribui campos privados `_politicaIl` e `_uuid`

#### `algoritmo_validador_comodo.dart` — 1.0.1
- ADD: validação contra mínimos da NBR com violações acumuladas
- ADD: 3 tipos de violação (POUCOS_PONTOS_TUG, VA_TUG_INSUFICIENTE, VA_IL_INSUFICIENTE)
- ADD: status reprovado sem bloquear salvamento (decisão fica com o usuário)
- FIX (1.0.1): const constructor agora atribui campo privado `_politicaIl`

#### `algoritmo_agregador_circuitos.dart` — 1.0.1
- ADD: agregação de pontos por idCircuito entre todos os cômodos
- ADD: TUG como base de circuito misto TUG+IL (NBR 9.5.3.3)
- ADD: detecção de TUE_MISTURADA (TUE com TUG ou IL no mesmo circuito)
- ADD: validação de VA_MINIMO_CIRCUITO_INSUFICIENTE via vaMinimoCircuito do ponto
- DEL (1.0.1): IL_BASE_DE_CIRCUITO_MISTO removido (lógica nunca era atingida — TUG sempre é base na mistura)

#### `servico_dimensionamento_carga.dart` — 1.0.0
- ADD: criarComodoComSugestoes — novo cômodo com pontos pré-populados pela norma
- ADD: criarComodoCustom — cômodo personalizado com RegraTomada explícita
- ADD: processar — valida todos os cômodos e agrega circuitos do projeto
- ADD: vaTotalProjeto como soma simples (sem fator de demanda — fica no orquestrador mestre)

---

### Padrão de nomenclatura adotado

Arquivos passam a ter prefixo de pasta no nome (singular), tornando autoexplicativo
onde cada um deve ficar. Não se aplica quando o nome já tem o prefixo natural
(`politica_*`, `servico_*`, `repositorio_*`).

| Pasta | Prefixo |
|---|---|
| `core/dominio/` | `dominio_` |
| `core/repositorio/` | `repositorio_` |
| `features/*/algoritmos/` | `algoritmo_` |
| `features/*/modelos/` | `modelo_` |
| `features/*/politicas/` | (já tem `politica_`) |
| `features/*/servicos/` | (já tem `servico_`) |

A renomeação foi aplicada apenas aos arquivos novos da feature `dimensionamento_carga`.
A feature `dimensionamento_circuito` permanece com nomenclatura original — eventual
migração ficará para um ciclo dedicado.

---

### Arquivos descartados do alpha (não migrados ao Drive de produção)

| Arquivo do alpha | Substituído por |
|---|---|
| `politica_tug.dart` | `dominio_regra_tomada.dart` (sealed class) |
| `calculo_tug.dart` | `dominio_regra_tomada.dart` (função privada) |
| `registro_politica_tug.dart` | `repositorio_comodos.dart` (dicionário interno) |
| `resolver_politica_tug.dart` | `repositorio_comodos.dart` (resolução interna) |
| `comodo_config.dart` | `repositorio_config_comodo_json.dart` |
| `equipamento_tue.dart` | `modelo_tue.dart` (sem fatorPotencia armazenado) |
| `calculo_tue.dart` | `modelo_tue.dart` (factory `fromW`) |
| `calculo_iluminacao.dart` | `politica_iluminacao.dart` (função privada) |
| `politica_il.dart` | `politica_iluminacao.dart` |
| `entrada_dimensionamento_carga.dart` | `modelo_entrada_carga.dart` |
| `resultado_carga_ambiente.dart` | `modelo_relatorio_carga.dart` |
| `resultado_il.dart` | `modelo_relatorio_carga.dart` |
| `resultado_tug.dart` | `modelo_relatorio_carga.dart` |
| `resultado_tue.dart` | `modelo_relatorio_carga.dart` |
| `servico_dimensionsmento_carga.dart` (sic) | `servico_dimensionamento_carga.dart` |

### Infraestrutura

#### `pubspec.yaml`
- ADD: dependência `uuid: ^4.0.0` (usado pelo gerador de pontos e serviço)
- ADD: declaração de assets `assets/config/` (para `config_comodos.json`)

#### `assets/config/config_comodos.json`
- Mantido conforme alpha — nenhuma mudança de estrutura

---

## Ciclo 2 — Algoritmo e Orquestração (26 04 2026)

### Arquivos Novos

| Arquivo | Versão | Localização |
|---|---|---|
| `politica_queda_tensao.dart` | 1.0.0 | `lib/features/dimensionamento_circuito/politicas/` |
| `contexto_selecao.dart` | 1.0.0 | `lib/features/dimensionamento_circuito/modelos/` |
| `resultado_selecao.dart` | 1.0.0 | `lib/features/dimensionamento_circuito/modelos/` |
| `selecionador_condutor.dart` | 1.0.0 | `lib/features/dimensionamento_circuito/algoritmo/` |

#### `politica_queda_tensao.dart` — 1.0.0
- ADD: encapsula limite de queda de tensão conforme NBR 5410 seção 6.2.7
- ADD: terminais (TUG, TUE, IL) → 4%
- ADD: alimentadores (MED, QDG, QD) → 1% (margem conservadora de projeto)

#### `contexto_selecao.dart` — 1.0.0
- ADD: modelo de entrada do SelecionadorCondutor com 13 campos derivados
- ADD: getter resistenciaDe(imp) centraliza lógica PVC/EPR

#### `resultado_selecao.dart` — 1.0.0
- ADD: modelo de saída do SelecionadorCondutor com resultado teórico e final
- ADD: factories reprovadoAmpacidade() e reprovadoQueda()

#### `selecionador_condutor.dart` — 1.0.0
- ADD: loop iterativo extraído do orquestrador — critério duplo (ampacidade + queda)
- ADD: registro separado do resultado teórico e final para memória de cálculo
- ADD: retorno via ResultadoSelecao — elimina exceção como fluxo de controle

---

### Arquivos Adaptados

#### `calculo_ampacidade_cabo.dart` — 2.0.0
- CHG: Map<String, dynamic> → LinhaAmpacidade tipada
- CHG: String metodo → MetodoInstalacao (enum)
- DEL: toUpperCase() removido

#### `politica_disjuntor.dart` — 2.0.0
- CHG: List<dynamic> → List<Disjuntor> tipada
- CHG: indexManual (int) → correnteManual (double?)
- CHG: retorno -1.0 substituído por StateError descritivo

#### `politica_secao_transversal.dart` — 2.0.0
- CHG: String tipoCircuito → TagCircuito (enum)
- DEL: toUpperCase() e comparação de String removidos

#### `calculo_corrente_proj.dart` — 1.1.0
- ADD: cabeçalho de versionamento e changelog
- CHG: nenhuma mudança de lógica ou assinatura

---

### Arquivos Atualizados

#### `relatorio_dimensionamento.dart` — 2.1.0
- ADD: REPROVADO_DISJUNTOR em StatusDimensionamento

#### `relatorio_dimensionamento.dart` — 2.0.0
- ADD: enum StatusDimensionamento (APROVADO, REPROVADO_AMPACIDADE, REPROVADO_QUEDA)
- ADD: campos idCircuito, tagCircuito, material, tipoConstrutivo, metodoInstalacao
- CHG: limiteQuedaAplicado corrigido de "1% ou 3%" para "1% ou 4%"
- CHG: construtor convertido para const

#### `resultado_ampacidade.dart` — 1.1.0
- ADD: cabeçalho de versionamento e changelog
- ADD: construtor const

#### `repositorio_tabelas.dart` — 1.0.3
- ADD: ordenação explícita das linhas de ampacidade por seção crescente na carga

#### `servico_dimensionamento_circuito.dart` — 3.1.0
- ADD: captura de StateError da PoliticaDisjuntor → devolve REPROVADO_DISJUNTOR
- ADD: helper _relatorioReprovado para falhas antes da selção de condutor

---

### Arquivos Removidos

| Arquivo | Motivo |
|---|---|
| `calculo_fator.dart` | Absorvido pelo RepositorioTabelas |
| `politica_metodo_instalacao.dart` | Regra resolvida via MetodoInstalacao.isSolo |
| `seletor_tabela_ampacidade.dart` | Helper privado do RepositorioTabelas |
| `seletor_tabela_disjuntor.dart` | Helper privado do RepositorioTabelas |
| `seletor_tabela_fator.dart` | Helper privado do RepositorioTabelas |
| `seletor_tablea_reatancia.dart` | Helper privado do RepositorioTabelas |

---

## Ciclo 1 — Fundação (25 04 2026)

### Arquivos Novos

| Arquivo | Versão | Localização |
|---|---|---|
| `enums.dart` | 1.0.1 | `lib/core/dominio/` |
| `modelos_tabela.dart` | 1.0.2 | `lib/core/modelos/` |
| `repositorio_tabelas.dart` | 1.0.2 | `lib/core/repositorio/` |
| `entrada_dimensionamento.dart` | 1.0.1 | `lib/features/dimensionamento_circuito/modelos/` |

#### `enums.dart` — 1.0.1
- ADD: 6 enums do domçnio elétrico com 7 getters derivados
- CHG (1.0.1): localização e estrutura por feature

#### `modelos_tabela.dart` — 1.0.2
- ADD: 6 modelos tipados com factory fromJson e validação rigorosa de tipo
- CHG (1.0.2): metodos renomeado para regrasMetodo em LinhaAmpacidade

#### `repositorio_tabelas.dart` — 1.0.2
- ADD: carga eager de 18 JSONs em paralelo com relatório consolidado de erros
- ADD: guarda de reinicialização e 8 måtodos públicos tipados

#### `entrada_dimensionamento.dart` — 1.0.1
- ADD: modelo imutável de 12 campos com 9 validações acumuladas
- ADD: getter condutoresAtivos

---

### Infraestrutura

#### `pubspec.yaml`
- CHG: flutter_lints atualizado para ^4.0.0
- ADD: declaração dos assets assets/rules/ e assets/tables/

---

## Estado atual — versões por arquivo

```
lib/core/dominio/
  enums.dart                                     v1.0.1
  dominio_regra_tomada.dart                      v1.0.0

lib/core/modelos/
  modelos_tabela.dart                            v1.0.2

lib/core/repositorio/
  repositorio_tabelas.dart                       v1.0.3
  repositorio_comodos.dart                       v1.0.0
  repositorio_config_comodo_json.dart            v1.0.0

lib/features/dimensionamento_circuito/algoritmo/
  selecionador_condutor.dart                     v1.0.0

lib/features/dimensionamento_circuito/calculos/
  calculo_corrente_proj.dart                     v1.1.0
  calculo_ampacidade_cabo.dart                   v2.0.0
  calculo_queda_tensao.dart                      v1.0.0

lib/features/dimensionamento_circuito/modelos/
  entrada_dimensionamento.dart                   v1.0.1
  contexto_selecao.dart                          v1.0.0
  resultado_selecao.dart                         v1.0.0
  resultado_ampacidade.dart                      v1.1.0
  relatorio_dimensionamento.dart                 v2.1.0

lib/features/dimensionamento_circuito/politicas/
  politica_queda_tensao.dart                     v1.0.0
  politica_secao_transversal.dart                v2.0.0
  politica_disjuntor.dart                        v2.0.0

lib/features/dimensionamento_circuito/servico/
  servico_dimensionamento_circuito.dart          v3.1.0

lib/features/dimensionamento_carga/algoritmos/
  algoritmo_gerador_pontos_comodo.dart           v1.0.1
  algoritmo_validador_comodo.dart                v1.0.1
  algoritmo_agregador_circuitos.dart             v1.0.1

lib/features/dimensionamento_carga/modelos/
  modelo_comodo.dart                             v1.0.0
  modelo_ponto_carga.dart                        v1.0.0
  modelo_tue.dart                                v1.0.0
  modelo_entrada_carga.dart                      v1.0.0
  modelo_relatorio_carga.dart                    v1.0.0

lib/features/dimensionamento_carga/politicas/
  politica_iluminacao.dart                       v1.0.0

lib/features/dimensionamento_carga/servicos/
  servico_dimensionamento_carga.dart             v1.0.0
```

## Próximos passos planejados
- Ciclo 4: UI da feature dimensionamento_circuito
- Ciclo 5: UI da feature dimensionamento_carga (3 abas TUG/TUE/IL + aba de circuitos do projeto)
- Ciclo 6: Orquestrador mestre — soma de cargas entre features e fator de demanda
- Futura: Feature luminotécnica
- Futura: Aterramento
