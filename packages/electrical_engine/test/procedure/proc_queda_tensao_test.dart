// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes de parâmetros de queda de tensão (6.2.5.6, 6.2.7).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/procedure/proc_queda_tensao.dart';

void main() {
  const proc = ProcQuedaTensao();

  // ── Limites de queda ──────────────────────────────────────────────────────

  group('Limites de queda —', () {
    test('TUG — limite 4%', () {
      final e = entradaPadrao(tagCircuito: TagCircuito.tug);
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.limitePercent, equals(4.0));
    });

    test('TUE — limite 4%', () {
      final e = entradaPadrao(tagCircuito: TagCircuito.tue);
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.limitePercent, equals(4.0));
    });

    test('IL — limite 4%', () {
      final e = entradaPadrao(tagCircuito: TagCircuito.il);
      final r = proc.resolver((e, OrigemAlimentacao.trafoProprio));
      expect(r.limitePercent, equals(4.0));
    });

    test('QDG via concessionária — limite 1%', () {
      final e = entradaPadrao(tagCircuito: TagCircuito.qdg);
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.limitePercent, equals(1.0));
    });

    test('QDG trafo próprio — limite 3%', () {
      final e = entradaPadrao(tagCircuito: TagCircuito.qdg);
      final r = proc.resolver((e, OrigemAlimentacao.trafoProprio));
      expect(r.limitePercent, equals(3.0));
    });
  });

  // ── Condutores carregados ─────────────────────────────────────────────────

  group('Condutores carregados —', () {
    test('Monofásico — 2 condutores', () {
      final e = entradaPadrao(numeroFases: NumeroFases.monofasico);
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.condutoresCarregados, equals(2));
    });

    test('Trifásico sem harmônicas — 3 condutores', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: false,
      );
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.condutoresCarregados, equals(3));
    });

    test('Trifásico com harmônicas > 15% — 4 condutores', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: true,
      );
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.condutoresCarregados, equals(4));
    });

    test('Bifásico — 3 condutores (com neutro)', () {
      final e = entradaPadrao(
        tensao: Tensao.v220,
        numeroFases: NumeroFases.bifasico,
      );
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.condutoresCarregados, equals(3));
    });
  });

  // ── Fator harmônico ───────────────────────────────────────────────────────

  group('Fator harmônico —', () {
    test('Sem harmônicas — fator 1.0', () {
      final e = entradaPadrao(harmonicasAcima15pct: false);
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.fatorHarmonico, equals(1.0));
      expect(r.temCorrecaoHarmonica, isFalse);
    });

    test('Trifásico com harmônicas > 15% — fator 0.86', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: true,
      );
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.fatorHarmonico, closeTo(0.86, 0.001));
      expect(r.temCorrecaoHarmonica, isTrue);
    });

    test('Monofásico com harmônicas — fator 1.0 (não aplica)', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.monofasico,
        harmonicasAcima15pct: true,
      );
      final r = proc.resolver((e, OrigemAlimentacao.pontoEntrega));
      expect(r.fatorHarmonico, equals(1.0));
    });
  });
}
