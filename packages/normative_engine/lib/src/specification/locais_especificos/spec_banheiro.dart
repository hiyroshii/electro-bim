// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - ADD: suporte a VolumeBanheiro.v3 — BANH_004 (tomada sem DR em V3).
// - FIX: V2 restringe tomadas a SELV, igual a V1 — BANH_002 agora se aplica a V1 e V2.
// - ADD: tomadaComDr em EntradaBanheiro para verificação de tomada em V3.
// [1.0.0] - 2026-05
// - ADD: S-15 — proteção em locais de banho por volume (NBR 5410 — Seção 701).

import '../../contracts/i_specification.dart';
import '../../domain/instalacao/escopo_projeto.dart';
import '../../domain/locais/volume_banheiro.dart';
import '../../models/violacao.dart';

/// Parâmetros de entrada para [SpecBanheiro].
typedef EntradaBanheiro = ({
  VolumeBanheiro volume,
  bool temTomada,
  bool tomadaSelv,
  bool tomadaComDr,
  int grauIpX,
});

/// S-15 — Prescrições para locais contendo banheira ou box de chuveiro.
///
/// Verifica, por volume (V0/V1/V2/V3):
/// - BANH_001: tomada proibida em V0.
/// - BANH_002: tomada em V1 ou V2 sem SELV.
/// - BANH_003: grau de proteção IP insuficiente para o volume.
/// - BANH_004: tomada em V3 sem DR (I∆n ≤ 30 mA).
///
/// Rastreabilidade: NBR 5410:2004 — Seção 701 (IEC 60364-7-701).
final class SpecBanheiro implements ISpecification<EntradaBanheiro> {
  const SpecBanheiro();

  @override
  bool aplicavelA(final PerfilInstalacao perfil) =>
      perfil.escopo == EscopoProjeto.residencial;

  @override
  List<Violacao> verificar(final EntradaBanheiro entrada) {
    final violacoes = <Violacao>[];
    final rotulo = entrada.volume.rotulo;

    // Tomada em V0 → sempre proibida
    if (entrada.volume == VolumeBanheiro.v0 && entrada.temTomada) {
      violacoes.add(Violacao.banheiraTomadaProibida(volume: rotulo));
    }

    // Tomada em V1 ou V2 sem SELV
    if ((entrada.volume == VolumeBanheiro.v1 ||
            entrada.volume == VolumeBanheiro.v2) &&
        entrada.temTomada &&
        !entrada.tomadaSelv) {
      violacoes.add(Violacao.banheiraExigeSELV(volume: rotulo));
    }

    // Tomada em V3 sem DR
    if (entrada.volume == VolumeBanheiro.v3 &&
        entrada.temTomada &&
        !entrada.tomadaComDr) {
      violacoes.add(Violacao.banheiraV3ExigeDr(volume: rotulo));
    }

    // IP insuficiente para o volume
    final ipMinimo = entrada.volume.ipXMinimo;
    if (entrada.grauIpX < ipMinimo) {
      violacoes.add(
        Violacao.banheiraIpInsuficiente(
          volume: rotulo,
          ipXMinimo: ipMinimo,
          ipXFornecido: entrada.grauIpX,
        ),
      );
    }

    return violacoes;
  }
}
