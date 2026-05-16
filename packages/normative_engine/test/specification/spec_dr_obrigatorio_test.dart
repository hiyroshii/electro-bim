// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - REWRITE: testes refatorados para lógica de DR por local (S-8 v2.0.0).
// [1.0.0] - 2026-05
// - ADD: testes de DR obrigatório nos circuitos terminais residenciais (S-8).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

const _residencial = PerfilInstalacao(escopo: EscopoProjeto.residencial);
const _comercial = PerfilInstalacao(escopo: EscopoProjeto.comercial);

EntradaDrObrigatorio _e({
  required final TagCircuito tag,
  final TipoComodo comodo = TipoComodo.sala,
  final bool temDr = false,
  final double? sensibilidadeMaA,
  final bool ehAreaExterna = false,
  final bool podeAlimentarEquipamentoExterno = false,
}) =>
    (
      comodo: comodo,
      tag: tag,
      temDr: temDr,
      sensibilidadeMaA: sensibilidadeMaA,
      ehAreaExterna: ehAreaExterna,
      podeAlimentarEquipamentoExterno: podeAlimentarEquipamentoExterno,
    );

void main() {
  const spec = SpecDrObrigatorio();

  // ── aplicavelA ────────────────────────────────────────────────────────────

  group('aplicavelA —', () {
    test('Residencial → true', () => expect(spec.aplicavelA(_residencial), isTrue));
    test('Comercial → false', () => expect(spec.aplicavelA(_comercial), isFalse));
  });

  // ── Circuitos de distribuição — nunca exigem DR ───────────────────────────

  group('Distribuição —', () {
    test('MED em sala sem DR → sem violação', () {
      expect(spec.verificar(_e(tag: TagCircuito.med)), isEmpty);
    });

    test('QDG em sala sem DR → sem violação', () {
      expect(spec.verificar(_e(tag: TagCircuito.qdg)), isEmpty);
    });

    test('QD em sala sem DR → sem violação', () {
      expect(spec.verificar(_e(tag: TagCircuito.qd)), isEmpty);
    });

    test('MED em banheiro sem DR → sem violação (distribuição não é terminal)', () {
      expect(spec.verificar(_e(comodo: TipoComodo.banheiro, tag: TagCircuito.med)), isEmpty);
    });
  });

  // ── Banheiro — todos os terminais exigem DR ───────────────────────────────

  group('Banheiro —', () {
    test('TUG em banheiro sem DR → DR_001', () {
      final v = spec.verificar(_e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug));
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('TUE em banheiro sem DR → DR_001', () {
      final v = spec.verificar(_e(comodo: TipoComodo.banheiro, tag: TagCircuito.tue));
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('IL em banheiro sem DR → DR_001', () {
      final v = spec.verificar(_e(comodo: TipoComodo.banheiro, tag: TagCircuito.il));
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('TUG em banheiro com DR 30 mA → sem violação', () {
      final v = spec.verificar(
        _e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug, temDr: true, sensibilidadeMaA: 30.0),
      );
      expect(v, isEmpty);
    });
  });

  // ── Cozinha / área de serviço / garagem — apenas TUG e TUE ───────────────

  group('Áreas molhadas —', () {
    test('TUG em cozinha sem DR → DR_001', () {
      final v = spec.verificar(_e(comodo: TipoComodo.cozinha, tag: TagCircuito.tug));
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('TUE em cozinha sem DR → DR_001', () {
      final v = spec.verificar(_e(comodo: TipoComodo.cozinha, tag: TagCircuito.tue));
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('IL em cozinha sem DR → sem violação (IL não exige DR em cozinha)', () {
      expect(spec.verificar(_e(comodo: TipoComodo.cozinha, tag: TagCircuito.il)), isEmpty);
    });

    test('TUG em areaServico sem DR → DR_001', () {
      final v = spec.verificar(_e(comodo: TipoComodo.areaServico, tag: TagCircuito.tug));
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('TUG em garagem sem DR → DR_001', () {
      final v = spec.verificar(_e(comodo: TipoComodo.garagem, tag: TagCircuito.tug));
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });
  });

  // ── Sala / quarto / corredor — sem exigência de DR ────────────────────────

  group('Ambientes secos —', () {
    test('TUG em sala sem DR → sem violação', () {
      expect(spec.verificar(_e(tag: TagCircuito.tug)), isEmpty);
    });

    test('IL em sala sem DR → sem violação', () {
      expect(spec.verificar(_e(tag: TagCircuito.il)), isEmpty);
    });

    test('TUG em quarto sem DR → sem violação', () {
      expect(spec.verificar(_e(comodo: TipoComodo.quarto, tag: TagCircuito.tug)), isEmpty);
    });

    test('TUG em corredor sem DR → sem violação', () {
      expect(spec.verificar(_e(comodo: TipoComodo.corredor, tag: TagCircuito.tug)), isEmpty);
    });
  });

  // ── Área externa — TUG e TUE ──────────────────────────────────────────────

  group('Área externa —', () {
    test('TUG em área externa sem DR → DR_001', () {
      final v = spec.verificar(
        _e(tag: TagCircuito.tug, ehAreaExterna: true),
      );
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('TUE em área externa sem DR → DR_001', () {
      final v = spec.verificar(
        _e(tag: TagCircuito.tue, ehAreaExterna: true),
      );
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('IL em área externa sem DR → sem violação', () {
      expect(
        spec.verificar(_e(tag: TagCircuito.il, ehAreaExterna: true)),
        isEmpty,
      );
    });
  });

  // ── Pode alimentar equipamento externo — TUG e TUE ───────────────────────

  group('Alimenta equipamento externo —', () {
    test('TUG pode alimentar externo sem DR → DR_001', () {
      final v = spec.verificar(
        _e(tag: TagCircuito.tug, podeAlimentarEquipamentoExterno: true),
      );
      expect(v.any((final Violacao e) => e.codigo == 'DR_001'), isTrue);
    });

    test('IL pode alimentar externo sem DR → sem violação', () {
      expect(
        spec.verificar(_e(tag: TagCircuito.il, podeAlimentarEquipamentoExterno: true)),
        isEmpty,
      );
    });
  });

  // ── DR_001 — ausente ──────────────────────────────────────────────────────

  group('DR_001 — DR ausente —', () {
    test('Apenas uma violação por ausência', () {
      final v = spec.verificar(_e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug));
      expect(v.length, equals(1));
    });

    test('Código DR_001 correto', () {
      final v = spec.verificar(_e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug));
      expect(v.first.codigo, equals('DR_001'));
    });
  });

  // ── DR_002 — sensibilidade > 30 mA ───────────────────────────────────────

  group('DR_002 — sensibilidade excessiva —', () {
    test('TUG em banheiro, DR 100 mA → DR_002', () {
      final v = spec.verificar(
        _e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug, temDr: true, sensibilidadeMaA: 100.0),
      );
      expect(v.any((final Violacao e) => e.codigo == 'DR_002'), isTrue);
    });

    test('TUG em cozinha, DR 30.1 mA → DR_002', () {
      final v = spec.verificar(
        _e(comodo: TipoComodo.cozinha, tag: TagCircuito.tug, temDr: true, sensibilidadeMaA: 30.1),
      );
      expect(v.any((final Violacao e) => e.codigo == 'DR_002'), isTrue);
    });

    test('TUG em banheiro, DR 30 mA exato → sem DR_002 (limite inclusivo)', () {
      final v = spec.verificar(
        _e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug, temDr: true, sensibilidadeMaA: 30.0),
      );
      expect(v.any((final Violacao e) => e.codigo == 'DR_002'), isFalse);
    });

    test('Apenas uma violação por sensibilidade', () {
      final v = spec.verificar(
        _e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug, temDr: true, sensibilidadeMaA: 300.0),
      );
      expect(v.length, equals(1));
    });
  });

  // ── Metadata das violações ────────────────────────────────────────────────

  group('Metadata DR_001 —', () {
    late List<Violacao> v;
    setUp(() {
      v = spec.verificar(_e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug));
    });

    test('Código correto', () => expect(v.first.codigo, equals('DR_001')));
    test('Referência 5.1.3.2.2', () => expect(v.first.referencia, contains('5.1.3.2.2')));
  });

  group('Metadata DR_002 —', () {
    late List<Violacao> v;
    setUp(() {
      v = spec.verificar(
        _e(comodo: TipoComodo.banheiro, tag: TagCircuito.tug, temDr: true, sensibilidadeMaA: 300.0),
      );
    });

    test('Código correto', () => expect(v.first.codigo, equals('DR_002')));
    test('Referência 5.1.3.2.2', () => expect(v.first.referencia, contains('5.1.3.2.2')));
  });
}
