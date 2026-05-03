// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes dos três cálculos matemáticos.

import 'dart:math';
import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

// ignore: implementation_imports
import 'package:electrical_engine/src/calculos/calc_corrente_projeto.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/calculos/calc_ampacidade_cabo.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/calculos/calc_queda_tensao.dart';

void main() {
  // ── CalcCorrenteProjeto ───────────────────────────────────────────────────

  group('CalcCorrenteProjeto —', () {
    test('Monofásico 220V 1000VA FP=1,0 → Ib ≈ 4,545A', () {
      final ib = CalcCorrenteProjeto.calcular(
        potenciaVA: 1000,
        tensaoV: 220,
        fatorPotencia: 1.0,
        isTrifasico: false,
      );
      expect(ib, closeTo(4.545, 0.001));
    });

    test('Monofásico 220V 2000VA FP=0,9 → Ib ≈ 10,101A', () {
      final ib = CalcCorrenteProjeto.calcular(
        potenciaVA: 2000,
        tensaoV: 220,
        fatorPotencia: 0.9,
        isTrifasico: false,
      );
      expect(ib, closeTo(10.101, 0.001));
    });

    test('Trifásico 380V 10000VA FP=0,85 → Ib correto', () {
      final ib = CalcCorrenteProjeto.calcular(
        potenciaVA: 10000,
        tensaoV: 380,
        fatorPotencia: 0.85,
        isTrifasico: true,
      );
      expect(ib, closeTo(10000 / (sqrt(3) * 380 * 0.85), 0.001));
    });

    test('Trifásico usa √3 — resultado menor que monofásico mesma tensão', () {
      final ibMono = CalcCorrenteProjeto.calcular(
        potenciaVA: 5000, tensaoV: 220, fatorPotencia: 1.0, isTrifasico: false,
      );
      final ibTri = CalcCorrenteProjeto.calcular(
        potenciaVA: 5000, tensaoV: 220, fatorPotencia: 1.0, isTrifasico: true,
      );
      expect(ibTri, lessThan(ibMono));
    });

    test('FP menor → Ib maior', () {
      final ibFp09 = CalcCorrenteProjeto.calcular(
        potenciaVA: 1000, tensaoV: 220, fatorPotencia: 0.9, isTrifasico: false,
      );
      final ibFp10 = CalcCorrenteProjeto.calcular(
        potenciaVA: 1000, tensaoV: 220, fatorPotencia: 1.0, isTrifasico: false,
      );
      expect(ibFp09, greaterThan(ibFp10));
    });

    test('potência zero → Ib = 0', () {
      final ib = CalcCorrenteProjeto.calcular(
        potenciaVA: 0, tensaoV: 220, fatorPotencia: 1.0, isTrifasico: false,
      );
      expect(ib, equals(0.0));
    });
  });

  // ── CalcAmpacidadeCabo ────────────────────────────────────────────────────

  group('CalcAmpacidadeCabo —', () {
    final linha25 = LinhaAmpacidade(secao: 2.5, izBase: 21.0);

    test('FCT=1,0 FCA=1,0 fatorHarm=1,0 → Iz = izBase', () {
      final r = CalcAmpacidadeCabo.calcular(
        linha: linha25,
        fatores: const FatoresCorrecao(fct: 1.0, fca: 1.0),
        fatorHarmonico: 1.0,
      );
      expect(r.izCabo, closeTo(21.0, 0.001));
      expect(r.secao, equals(2.5));
      expect(r.ampacidadeBase, equals(21.0));
    });

    test('FCT=0,87 FCA=0,70 → Iz = 21 × 0,87 × 0,70', () {
      final r = CalcAmpacidadeCabo.calcular(
        linha: linha25,
        fatores: const FatoresCorrecao(fct: 0.87, fca: 0.70),
        fatorHarmonico: 1.0,
      );
      expect(r.izCabo, closeTo(21.0 * 0.87 * 0.70, 0.001));
    });

    test('fatorHarmonico=0,86 reduz Iz', () {
      final rNormal = CalcAmpacidadeCabo.calcular(
        linha: linha25,
        fatores: const FatoresCorrecao(fct: 1.0, fca: 1.0),
        fatorHarmonico: 1.0,
      );
      final rHarm = CalcAmpacidadeCabo.calcular(
        linha: linha25,
        fatores: const FatoresCorrecao(fct: 1.0, fca: 1.0),
        fatorHarmonico: 0.86,
      );
      expect(rHarm.izCabo, closeTo(rNormal.izCabo * 0.86, 0.001));
    });

    test('Todos os fatores combinados', () {
      final r = CalcAmpacidadeCabo.calcular(
        linha: linha25,
        fatores: const FatoresCorrecao(fct: 0.91, fca: 0.80),
        fatorHarmonico: 0.86,
      );
      expect(r.izCabo, closeTo(21.0 * 0.91 * 0.80 * 0.86, 0.001));
    });
  });

  // ── CalcQuedaTensao ───────────────────────────────────────────────────────

  group('CalcQuedaTensao —', () {
    const ib = 10.0;
    const dist = 20.0;
    const tensao = 220.0;
    const rho = 0.02308;
    const secao = 2.5;
    const r = rho / secao;
    const xi = 0.0;

    test('Monofásico reatância zero cosφ=1 → ΔV% = 2×Ib×L×R/V×100', () {
      final dv = CalcQuedaTensao.calcularPercentual(
        distancia: dist, corrente: ib, tensao: tensao,
        resistencia: r, reatancia: xi, isTrifasico: false, cosPhi: 1.0,
      );
      final esperado = (2 * ib * dist * r / tensao) * 100;
      expect(dv, closeTo(esperado, 0.001));
    });

    test('Trifásico fator √3 → resultado menor que monofásico', () {
      final dvMono = CalcQuedaTensao.calcularPercentual(
        distancia: dist, corrente: ib, tensao: tensao,
        resistencia: r, reatancia: xi, isTrifasico: false, cosPhi: 1.0,
      );
      final dvTri = CalcQuedaTensao.calcularPercentual(
        distancia: dist, corrente: ib, tensao: tensao,
        resistencia: r, reatancia: xi, isTrifasico: true, cosPhi: 1.0,
      );
      expect(dvTri, lessThan(dvMono));
      expect(dvTri, closeTo(dvMono * sqrt(3) / 2.0, 0.001));
    });

    test('Reatância não-zero com cosφ < 1 aumenta queda', () {
      final dvSemXi = CalcQuedaTensao.calcularPercentual(
        distancia: dist, corrente: ib, tensao: tensao,
        resistencia: r, reatancia: 0.0, isTrifasico: false, cosPhi: 0.85,
      );
      final dvComXi = CalcQuedaTensao.calcularPercentual(
        distancia: dist, corrente: ib, tensao: tensao,
        resistencia: r, reatancia: 0.0001, isTrifasico: false, cosPhi: 0.85,
      );
      expect(dvComXi, greaterThan(dvSemXi));
    });

    test('Seção maior → queda menor', () {
      final dvPequena = CalcQuedaTensao.calcularPercentual(
        distancia: dist, corrente: ib, tensao: tensao,
        resistencia: rho / 2.5, reatancia: xi, isTrifasico: false, cosPhi: 1.0,
      );
      final dvGrande = CalcQuedaTensao.calcularPercentual(
        distancia: dist, corrente: ib, tensao: tensao,
        resistencia: rho / 6.0, reatancia: xi, isTrifasico: false, cosPhi: 1.0,
      );
      expect(dvGrande, lessThan(dvPequena));
    });

    test('Distância dobrada → queda dobrada (relação linear)', () {
      final dv20 = CalcQuedaTensao.calcularPercentual(
        distancia: 20, corrente: ib, tensao: tensao,
        resistencia: r, reatancia: xi, isTrifasico: false, cosPhi: 1.0,
      );
      final dv40 = CalcQuedaTensao.calcularPercentual(
        distancia: 40, corrente: ib, tensao: tensao,
        resistencia: r, reatancia: xi, isTrifasico: false, cosPhi: 1.0,
      );
      expect(dv40, closeTo(dv20 * 2, 0.001));
    });
  });
}
