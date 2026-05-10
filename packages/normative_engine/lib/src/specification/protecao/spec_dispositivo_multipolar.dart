// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: verificação de dispositivo multipolar para circuitos multifásicos.

import '../../contracts/i_specification.dart';
import '../../enums/numero_fases.dart';
import '../../models/entrada_normativa.dart';
import '../../models/violacao.dart';

/// Verifica se circuitos multifásicos utilizam dispositivo de proteção multipolar.
///
/// Rastreabilidade: NBR 5410:2004 — 9.5.4.
final class SpecDispositivoMultipolar implements ISpecification<EntradaNormativa> {
  const SpecDispositivoMultipolar();

  @override
  bool aplicavelA(final PerfilInstalacao perfil) => true;

  @override
  List<Violacao> verificar(final EntradaNormativa entrada) {
    final violacoes = <Violacao>[];

    if (entrada.numeroFases != NumeroFases.monofasico &&
        !entrada.dispositivoMultipolar) {
      violacoes.add(Violacao.dispositivoDeveSerMultipolar(
        numeroFases: entrada.numeroFases.name.toUpperCase(),
      ),);
    }

    return violacoes;
  }
}
