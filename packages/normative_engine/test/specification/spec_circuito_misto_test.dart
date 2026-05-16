// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes de restrições para circuitos mistos IL + TUG (S-11).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

const _residencial = PerfilInstalacao(escopo: EscopoProjeto.residencial);
const _comercial = PerfilInstalacao(escopo: EscopoProjeto.comercial);

EntradaCircuitoMisto _entrada({
  final bool temIl = true,
  final bool temTug = true,
  final double ibCircuito = 10.0,
  final bool unicoCircuitoIl = false,
  final bool unicoCircuitoTug = false,
  final List<TipoComodo> comodos = const [TipoComodo.sala],
}) =>
    (
      temIl: temIl,
      temTug: temTug,
      ibCircuito: ibCircuito,
      unicoCircuitoIl: unicoCircuitoIl,
      unicoCircuitoTug: unicoCircuitoTug,
      comodos: comodos,
    );

void main() {
  const spec = SpecCircuitoMisto();

  // ── aplicavelA ────────────────────────────────────────────────────────────

  group('aplicavelA —', () {
    test('Residencial → true', () => expect(spec.aplicavelA(_residencial), isTrue));
    test('Comercial → false', () => expect(spec.aplicavelA(_comercial), isFalse));
  });

  // ── Circuito não misto — spec não age ─────────────────────────────────────

  group('Circuito não misto —', () {
    test('Só IL (temTug=false) → sem violação', () {
      expect(spec.verificar(_entrada(temTug: false)), isEmpty);
    });

    test('Só TUG (temIl=false) → sem violação', () {
      expect(spec.verificar(_entrada(temIl: false)), isEmpty);
    });
  });

  // ── Circuito misto conforme ───────────────────────────────────────────────

  group('Misto conforme —', () {
    test('Ib=16A, não único IL/TUG, sala → sem violação', () {
      expect(spec.verificar(_entrada(ibCircuito: 16.0)), isEmpty);
    });

    test('Ib=10A, sala e quarto → sem violação', () {
      expect(
        spec.verificar(
          _entrada(comodos: [TipoComodo.sala, TipoComodo.quarto]),
        ),
        isEmpty,
      );
    });
  });

  // ── CIRC_003 — Ib > 16 A ─────────────────────────────────────────────────

  group('CIRC_003 — Ib > 16 A —', () {
    test('Ib=16.1A → CIRC_003', () {
      final v = spec.verificar(_entrada(ibCircuito: 16.1));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_003'), isTrue);
    });

    test('Ib=20A → CIRC_003', () {
      final v = spec.verificar(_entrada(ibCircuito: 20.0));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_003'), isTrue);
    });
  });

  // ── CIRC_004 — única IL ───────────────────────────────────────────────────

  group('CIRC_004 — único circuito IL —', () {
    test('unicoCircuitoIl=true → CIRC_004', () {
      final v = spec.verificar(_entrada(unicoCircuitoIl: true));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_004'), isTrue);
    });
  });

  // ── CIRC_005 — única TUG ──────────────────────────────────────────────────

  group('CIRC_005 — único circuito TUG —', () {
    test('unicoCircuitoTug=true → CIRC_005', () {
      final v = spec.verificar(_entrada(unicoCircuitoTug: true));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_005'), isTrue);
    });
  });

  // ── CIRC_006 — área molhada ───────────────────────────────────────────────

  group('CIRC_006 — área molhada —', () {
    test('comodos=[cozinha] → CIRC_006', () {
      final v = spec.verificar(_entrada(comodos: [TipoComodo.cozinha]));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_006'), isTrue);
    });

    test('comodos=[areaServico] → CIRC_006', () {
      final v = spec.verificar(_entrada(comodos: [TipoComodo.areaServico]));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_006'), isTrue);
    });

    test('comodos=[banheiro] → sem CIRC_006 (banheiro não listado em 9.5.3.2)', () {
      final v = spec.verificar(_entrada(comodos: [TipoComodo.banheiro]));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_006'), isFalse);
    });

    test('comodos=[sala, cozinha] → CIRC_006', () {
      final v = spec.verificar(
        _entrada(comodos: [TipoComodo.sala, TipoComodo.cozinha]),
      );
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_006'), isTrue);
    });
  });

  // ── Múltiplas violações simultâneas ──────────────────────────────────────

  group('Múltiplas violações —', () {
    test('Ib>16 + único IL + único TUG → 3 violações', () {
      final v = spec.verificar(
        _entrada(ibCircuito: 20.0, unicoCircuitoIl: true, unicoCircuitoTug: true),
      );
      final codigos = v.map((final Violacao e) => e.codigo).toSet();
      expect(codigos, containsAll(['CIRC_003', 'CIRC_004', 'CIRC_005']));
      expect(v.length, equals(3));
    });

    test('Ib>16 + área molhada → CIRC_003 + CIRC_006', () {
      final v = spec.verificar(
        _entrada(ibCircuito: 20.0, comodos: [TipoComodo.cozinha]),
      );
      final codigos = v.map((final Violacao e) => e.codigo).toSet();
      expect(codigos, containsAll(['CIRC_003', 'CIRC_006']));
    });
  });

  // ── Metadata das violações ────────────────────────────────────────────────

  group('Metadata —', () {
    test('CIRC_003 referência 9.5.3.3', () {
      final v = spec.verificar(_entrada(ibCircuito: 20.0));
      expect(
        v.firstWhere((final Violacao e) => e.codigo == 'CIRC_003').referencia,
        contains('9.5.3.3'),
      );
    });

    test('CIRC_006 referência 9.5.3.3', () {
      final v = spec.verificar(_entrada(comodos: [TipoComodo.cozinha]));
      expect(
        v.firstWhere((final Violacao e) => e.codigo == 'CIRC_006').referencia,
        contains('9.5.3.3'),
      );
    });
  });
}
