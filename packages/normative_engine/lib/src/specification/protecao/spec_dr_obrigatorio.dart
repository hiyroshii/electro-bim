// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - BREAK: EntradaDrObrigatorio agora inclui TipoComodo, ehAreaExterna e
//   podeAlimentarEquipamentoExterno — DR é exigido por local, não para todos os terminais.
// - FIX: banheiro exige DR em todos os terminais; cozinha/areaServico/garagem
//   exigem DR apenas em TUG e TUE; demais cômodos sem exigência salvo área externa.
// [1.0.0] - 2026-05
// - ADD: S-8 — DR obrigatório nos circuitos terminais residenciais (5.1.3.2.2).

import '../../contracts/i_specification.dart';
import '../../domain/instalacao/escopo_projeto.dart';
import '../../domain/instalacao/tag_circuito.dart';
import '../../domain/locais/tipo_comodo.dart';
import '../../models/violacao.dart';

/// Parâmetros de entrada para [SpecDrObrigatorio].
typedef EntradaDrObrigatorio = ({
  TipoComodo comodo,
  TagCircuito tag,
  bool temDr,
  double? sensibilidadeMaA,
  bool ehAreaExterna,
  bool podeAlimentarEquipamentoExterno,
});

const _distribuicao = {TagCircuito.med, TagCircuito.qdg, TagCircuito.qd};
const _tomadas = {TagCircuito.tug, TagCircuito.tue};

// Banheiro: DR obrigatório em todos os circuitos terminais (IL, TUG, TUE).
const _comodosDrTodasFuncoes = {TipoComodo.banheiro};

// Cozinha, área de serviço, garagem: DR obrigatório apenas em TUG e TUE.
const _comodosDrApenasTomadas = {
  TipoComodo.cozinha,
  TipoComodo.areaServico,
  TipoComodo.garagem,
};

bool _exigeDr(final EntradaDrObrigatorio e) {
  if (_distribuicao.contains(e.tag)) return false;
  if (e.ehAreaExterna && _tomadas.contains(e.tag)) return true;
  if (e.podeAlimentarEquipamentoExterno && _tomadas.contains(e.tag)) return true;
  if (_comodosDrTodasFuncoes.contains(e.comodo)) return true;
  if (_comodosDrApenasTomadas.contains(e.comodo) && _tomadas.contains(e.tag)) return true;
  return false;
}

/// S-8 — Dispositivo DR obrigatório por local (NBR 5410:2004 — 5.1.3.2.2).
///
/// DR com I∆n ≤ 30 mA é exigido em:
/// - Banheiro: todos os circuitos terminais (IL, TUG, TUE).
/// - Cozinha, área de serviço, garagem: apenas TUG e TUE.
/// - Área externa ou circuito que pode alimentar equipamento externo: TUG e TUE.
///
/// Viola DR_001 quando o DR está ausente; viola DR_002 quando a
/// sensibilidade é superior a 30 mA.
///
/// Rastreabilidade: NBR 5410:2004 — 5.1.3.2.2 / 9.5.5.
final class SpecDrObrigatorio implements ISpecification<EntradaDrObrigatorio> {
  const SpecDrObrigatorio();

  @override
  bool aplicavelA(final PerfilInstalacao perfil) =>
      perfil.escopo == EscopoProjeto.residencial;

  @override
  List<Violacao> verificar(final EntradaDrObrigatorio entrada) {
    if (!_exigeDr(entrada)) return const [];
    if (!entrada.temDr) return [Violacao.drAusente()];
    final sens = entrada.sensibilidadeMaA;
    if (sens != null && sens > 30.0) {
      return [Violacao.drSensibilidadeInsuficiente(sensibilidade: sens)];
    }
    return const [];
  }
}
