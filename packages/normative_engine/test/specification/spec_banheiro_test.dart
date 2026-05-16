// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - REWRITE: testes refatorados para S-15 v1.1.0 (V3, BANH_004, V2 SELV, V1 IPX4).
// [1.0.0] - 2026-05
// - ADD: testes de prescrições para locais de banho por volume (S-15).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

const _residencial = PerfilInstalacao(escopo: EscopoProjeto.residencial);
const _industrial = PerfilInstalacao(escopo: EscopoProjeto.industrial);

void main() {
  const spec = SpecBanheiro();

  // ── aplicavelA ────────────────────────────────────────────────────────────

  group('aplicavelA —', () {
    test('Residencial → true', () => expect(spec.aplicavelA(_residencial), isTrue));
    test('Industrial → false', () => expect(spec.aplicavelA(_industrial), isFalse));
  });

  // ── V3 conforme — sem violação ────────────────────────────────────────────

  group('V3 conforme —', () {
    test('V3, sem tomada, IPX1 → sem violação', () {
      expect(
        spec.verificar((
          volume: VolumeBanheiro.v3,
          temTomada: false,
          tomadaSelv: false,
          tomadaComDr: false,
          grauIpX: 1,
        ),),
        isEmpty,
      );
    });

    test('V3, tomada com DR, IPX1 → sem violação', () {
      expect(
        spec.verificar((
          volume: VolumeBanheiro.v3,
          temTomada: true,
          tomadaSelv: false,
          tomadaComDr: true,
          grauIpX: 1,
        ),),
        isEmpty,
      );
    });
  });

  // ── V2 conforme — sem violação ────────────────────────────────────────────

  group('V2 conforme —', () {
    test('V2, sem tomada, IPX4 → sem violação', () {
      expect(
        spec.verificar((
          volume: VolumeBanheiro.v2,
          temTomada: false,
          tomadaSelv: false,
          tomadaComDr: false,
          grauIpX: 4,
        ),),
        isEmpty,
      );
    });

    test('V2, tomada SELV, IPX4 → sem violação', () {
      expect(
        spec.verificar((
          volume: VolumeBanheiro.v2,
          temTomada: true,
          tomadaSelv: true,
          tomadaComDr: false,
          grauIpX: 4,
        ),),
        isEmpty,
      );
    });
  });

  // ── V1 conforme — sem violação ────────────────────────────────────────────

  group('V1 conforme —', () {
    test('V1, sem tomada, IPX4 → sem violação', () {
      expect(
        spec.verificar((
          volume: VolumeBanheiro.v1,
          temTomada: false,
          tomadaSelv: false,
          tomadaComDr: false,
          grauIpX: 4,
        ),),
        isEmpty,
      );
    });

    test('V1, tomada SELV, IPX4 → sem violação', () {
      expect(
        spec.verificar((
          volume: VolumeBanheiro.v1,
          temTomada: true,
          tomadaSelv: true,
          tomadaComDr: false,
          grauIpX: 4,
        ),),
        isEmpty,
      );
    });
  });

  // ── V0 conforme — sem violação ────────────────────────────────────────────

  group('V0 conforme —', () {
    test('V0, sem tomada, IPX7 → sem violação', () {
      expect(
        spec.verificar((
          volume: VolumeBanheiro.v0,
          temTomada: false,
          tomadaSelv: false,
          tomadaComDr: false,
          grauIpX: 7,
        ),),
        isEmpty,
      );
    });
  });

  // ── BANH_001 — tomada em V0 ───────────────────────────────────────────────

  group('BANH_001 — tomada em V0 —', () {
    test('V0, temTomada=true → BANH_001', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v0,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 7,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_001'), isTrue);
    });

    test('V0, tomada SELV também proibida → BANH_001', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v0,
        temTomada: true,
        tomadaSelv: true,
        tomadaComDr: false,
        grauIpX: 7,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_001'), isTrue);
    });

    test('V1 com tomada não-SELV → sem BANH_001 (BANH_002 se aplica)', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v1,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_001'), isFalse);
    });
  });

  // ── BANH_002 — tomada em V1 ou V2 sem SELV ───────────────────────────────

  group('BANH_002 — tomada em V1 ou V2 sem SELV —', () {
    test('V1, temTomada=true, tomadaSelv=false → BANH_002', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v1,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_002'), isTrue);
    });

    test('V1, temTomada=true, tomadaSelv=true → sem BANH_002', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v1,
        temTomada: true,
        tomadaSelv: true,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_002'), isFalse);
    });

    test('V2, temTomada=true, tomadaSelv=false → BANH_002', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v2,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_002'), isTrue);
    });

    test('V2, temTomada=true, tomadaSelv=true → sem BANH_002', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v2,
        temTomada: true,
        tomadaSelv: true,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_002'), isFalse);
    });

    test('V0, temTomada=true, tomadaSelv=false → sem BANH_002 (BANH_001 se aplica)', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v0,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 7,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_002'), isFalse);
    });
  });

  // ── BANH_003 — IP insuficiente ────────────────────────────────────────────

  group('BANH_003 — IP insuficiente —', () {
    test('V0, IPX4 (< 7) → BANH_003', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v0,
        temTomada: false,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_003'), isTrue);
    });

    test('V1, IPX3 (< 4) → BANH_003', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v1,
        temTomada: false,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 3,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_003'), isTrue);
    });

    test('V2, IPX2 (< 4) → BANH_003', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v2,
        temTomada: false,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 2,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_003'), isTrue);
    });

    test('V1, IPX4 exato → sem BANH_003 (limite inclusivo)', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v1,
        temTomada: false,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_003'), isFalse);
    });

    test('V2, IPX6 (> 4) → sem BANH_003', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v2,
        temTomada: false,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 6,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_003'), isFalse);
    });

    test('V3, IPX0 (< 1) → BANH_003', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v3,
        temTomada: false,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 0,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_003'), isTrue);
    });
  });

  // ── BANH_004 — tomada em V3 sem DR ───────────────────────────────────────

  group('BANH_004 — tomada em V3 sem DR —', () {
    test('V3, temTomada=true, tomadaComDr=false → BANH_004', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v3,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 1,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_004'), isTrue);
    });

    test('V3, temTomada=true, tomadaComDr=true → sem BANH_004', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v3,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: true,
        grauIpX: 1,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_004'), isFalse);
    });

    test('V3, sem tomada → sem BANH_004', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v3,
        temTomada: false,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 1,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_004'), isFalse);
    });

    test('V2 com tomada sem DR → sem BANH_004 (BANH_002 se aplica)', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v2,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(v.any((final Violacao e) => e.codigo == 'BANH_004'), isFalse);
    });
  });

  // ── Múltiplas violações simultâneas ──────────────────────────────────────

  group('Múltiplas violações —', () {
    test('V0, tomada + IPX4 → BANH_001 + BANH_003', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v0,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      final codigos = v.map((final Violacao e) => e.codigo).toSet();
      expect(codigos, containsAll(['BANH_001', 'BANH_003']));
      expect(v.length, equals(2));
    });

    test('V1, tomada sem SELV + IPX3 → BANH_002 + BANH_003', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v1,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 3,
      ),);
      final codigos = v.map((final Violacao e) => e.codigo).toSet();
      expect(codigos, containsAll(['BANH_002', 'BANH_003']));
      expect(v.length, equals(2));
    });

    test('V3, tomada sem DR + IPX0 → BANH_004 + BANH_003', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v3,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 0,
      ),);
      final codigos = v.map((final Violacao e) => e.codigo).toSet();
      expect(codigos, containsAll(['BANH_004', 'BANH_003']));
      expect(v.length, equals(2));
    });
  });

  // ── Metadata das violações ────────────────────────────────────────────────

  group('Metadata —', () {
    test('BANH_001 referência Seção 701', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v0,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 7,
      ),);
      expect(
        v.firstWhere((final Violacao e) => e.codigo == 'BANH_001').referencia,
        contains('701'),
      );
    });

    test('BANH_003 referência Seção 701', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v0,
        temTomada: false,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 4,
      ),);
      expect(
        v.firstWhere((final Violacao e) => e.codigo == 'BANH_003').referencia,
        contains('701'),
      );
    });

    test('BANH_004 referência Seção 701', () {
      final v = spec.verificar((
        volume: VolumeBanheiro.v3,
        temTomada: true,
        tomadaSelv: false,
        tomadaComDr: false,
        grauIpX: 1,
      ),);
      expect(
        v.firstWhere((final Violacao e) => e.codigo == 'BANH_004').referencia,
        contains('701'),
      );
    });
  });
}
