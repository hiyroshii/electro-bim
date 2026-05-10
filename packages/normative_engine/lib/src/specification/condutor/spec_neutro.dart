// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: verificação de regras do condutor neutro (6.2.6.2).

import '../../contracts/i_specification.dart';
import '../../enums/numero_fases.dart';
import '../../models/violacao.dart';
import '../../models/entrada_normativa.dart';
import '../../tables/tabela_47_48_secao_minima_neutro.dart';

/// Verifica conformidade do condutor neutro.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.6.2.
final class SpecNeutro implements ISpecification<EntradaNormativa> {

  const SpecNeutro({
    required this.secaoNeutro,
    required this.secaoFase,
  });
  /// Seção do condutor neutro proposta (mm²).
  final double secaoNeutro;

  /// Seção dos condutores de fase (mm²).
  final double secaoFase;

  @override
  bool aplicavelA(final PerfilInstalacao perfil) => true;

  @override
  List<Violacao> verificar(final EntradaNormativa entrada) {
    final violacoes = <Violacao>[];

    // Monofásico: neutro obrigatoriamente igual à fase.
    // Rastreabilidade: NBR 5410:2004 — 6.2.6.2.2.
    if (entrada.numeroFases == NumeroFases.monofasico) {
      if (secaoNeutro < secaoFase) {
        violacoes.add(_violacaoNeutroInferiorFase());
      }
      return violacoes;
    }

    // Trifásico/bifásico com harmônicas > 15%: neutro >= fase.
    // Rastreabilidade: NBR 5410:2004 — 6.2.6.2.3 e 6.2.6.2.4.
    if (entrada.harmonicasAcima15pct) {
      if (secaoNeutro < secaoFase) {
        violacoes.add(_violacaoNeutroHarmonicas());
      }
      return violacoes;
    }

    // Trifásico com harmônicas ≤ 15% e fase > 25 mm²:
    // redução permitida conforme Tabela 48.
    // Rastreabilidade: NBR 5410:2004 — 6.2.6.2.6.
    if (secaoFase > 25.0) {
      final secaoMinimaPermitida = tabelaNeutroReduzido[secaoFase];
      if (secaoMinimaPermitida != null && secaoNeutro < secaoMinimaPermitida) {
        violacoes.add(Violacao(
          codigo: 'NEUTRO_001',
          descricao: 'Seção do neutro ($secaoNeutro mm²) abaixo do mínimo '
              'permitido pela Tabela 48 para fase de $secaoFase mm² '
              '(mínimo: $secaoMinimaPermitida mm²).',
          referencia: 'NBR 5410:2004 — Tabela 48, 6.2.6.2.6',
        ),);
      }
      return violacoes;
    }

    // Fase ≤ 25 mm² com harmônicas ≤ 15%: neutro = fase.
    // Rastreabilidade: NBR 5410:2004 — 6.2.6.2.6 (sem redução permitida).
    if (secaoNeutro < secaoFase) {
      violacoes.add(_violacaoNeutroInferiorFase());
    }

    return violacoes;
  }

  Violacao _violacaoNeutroInferiorFase() => Violacao(
        codigo: 'NEUTRO_002',
        descricao: 'Seção do neutro ($secaoNeutro mm²) deve ser igual à '
            'seção da fase ($secaoFase mm²).',
        referencia: 'NBR 5410:2004 — 6.2.6.2.2',
      );

  Violacao _violacaoNeutroHarmonicas() => Violacao(
        codigo: 'NEUTRO_003',
        descricao: 'Com taxa de 3ª harmônica > 15%, a seção do neutro '
            '($secaoNeutro mm²) não pode ser inferior à fase ($secaoFase mm²).',
        referencia: 'NBR 5410:2004 — 6.2.6.2.3',
      );
}
