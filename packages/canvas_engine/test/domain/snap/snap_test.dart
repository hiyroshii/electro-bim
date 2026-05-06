// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 06 05 2026
// - CHG: SnapService.createDefault() registra todos os providers
// - ADD: testes por provider (Line, Circle, Rectangle, Intersection)
// - ADD: validação de prioridade endpoint > center > midpoint > nearest
// [1.0.1] - 06 05 2026
// - FIX: result.point → result.position
// [1.0.0] - 06 05 2026
// - FIX: migração Vector2 → Vector3, parâmetros snap() corrigidos

import 'package:test/test.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/domain/entities/circle_shape.dart';
import 'package:canvas_engine/domain/entities/rectangle_shape.dart';
import 'package:canvas_engine/services/snap/snap_service.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';

void main() {
  // =========================
  // SEM SHAPES
  // =========================
  group('SnapService — sem shapes', () {
    test('retorna none com lista vazia', () {
      final service = SnapService.createDefault();

      final result = service.snap(
        mousePoint: const Vector3(0, 0),
        sceneShapes: [],
        zoom: 1.0,
      );

      expect(result.type, SnapType.none);
      expect(result.position, const Vector3(0, 0));
      expect(result.isSnapped, isFalse);
    });

    test('retorna none quando mouse está fora da tolerância', () {
      final service = SnapService.createDefault();
      final line = LineShape(const Vector3(0, 0), const Vector3(100, 0));

      // zoom=1 → tolerância=10. Mouse em (50,20): dist ao segmento=20 > 10
      final result = service.snap(
        mousePoint: const Vector3(50, 20),
        sceneShapes: [line],
        zoom: 1.0,
      );

      expect(result.type, SnapType.none);
    });
  });

  // =========================
  // LINE SHAPE
  // =========================
  group('SnapService — LineShape', () {
    late SnapService service;
    late LineShape line;

    setUp(() {
      service = SnapService.createDefault();
      line = LineShape(const Vector3(0, 0), const Vector3(100, 0));
    });

    test('snap para endpoint start', () {
      final r = service.snap(
        mousePoint: const Vector3(2, 0),
        sceneShapes: [line],
        zoom: 1.0,
      );

      expect(r.type, SnapType.endpoint);
      expect(r.position, const Vector3(0, 0));
    });

    test('snap para endpoint end', () {
      final r = service.snap(
        mousePoint: const Vector3(98, 0),
        sceneShapes: [line],
        zoom: 1.0,
      );

      expect(r.type, SnapType.endpoint);
      expect(r.position, const Vector3(100, 0));
    });

    test('snap para midpoint', () {
      final r = service.snap(
        mousePoint: const Vector3(50, 5),
        sceneShapes: [line],
        zoom: 1.0,
      );

      expect(r.type, SnapType.midpoint);
      expect(r.position, const Vector3(50, 0));
    });

    test('endpoint tem prioridade sobre nearest', () {
      // Mouse em (2,2): endpoint (0,0) dist≈2.83, nearest (2,0) dist=2
      // Endpoint vence por prioridade (0) mesmo com distância maior
      final r = service.snap(
        mousePoint: const Vector3(2, 2),
        sceneShapes: [line],
        zoom: 1.0,
      );

      expect(r.type, SnapType.endpoint);
      expect(r.position, const Vector3(0, 0));
    });
  });

  // =========================
  // CIRCLE SHAPE
  // =========================
  group('SnapService — CircleShape', () {
    late SnapService service;
    late CircleShape circle;

    setUp(() {
      service = SnapService.createDefault();
      circle = CircleShape(const Vector3(50, 50), 20);
    });

    test('snap para centro', () {
      final r = service.snap(
        mousePoint: const Vector3(51, 50),
        sceneShapes: [circle],
        zoom: 1.0,
      );

      expect(r.type, SnapType.center);
      expect(r.position, const Vector3(50, 50));
    });

    test('snap para quadrante direito', () {
      final r = service.snap(
        mousePoint: const Vector3(71, 50),
        sceneShapes: [circle],
        zoom: 1.0,
      );

      expect(r.type, SnapType.endpoint);
      expect(r.position.x, closeTo(70, 1e-6));
      expect(r.position.y, closeTo(50, 1e-6));
    });

    test('snap para quadrante superior', () {
      final r = service.snap(
        mousePoint: const Vector3(50, 71),
        sceneShapes: [circle],
        zoom: 1.0,
      );

      expect(r.type, SnapType.endpoint);
      expect(r.position.x, closeTo(50, 1e-6));
      expect(r.position.y, closeTo(70, 1e-6));
    });

    test('endpoint (quadrante) tem prioridade sobre center', () {
      // Mouse em (70,50): quadrante (70,50) dist=0 (endpoint, prio 0)
      //                   centro (50,50) dist=20 > 10 → fora da tolerância
      final r = service.snap(
        mousePoint: const Vector3(70, 50),
        sceneShapes: [circle],
        zoom: 1.0,
      );

      expect(r.type, SnapType.endpoint);
    });
  });

  // =========================
  // RECTANGLE SHAPE
  // =========================
  group('SnapService — RectangleShape', () {
    late SnapService service;
    late RectangleShape rect;

    setUp(() {
      service = SnapService.createDefault();
      // corner1=(0,0), corner2=(100,50)
      // gripPoints: (0,0), (100,0), (100,50), (0,50)
      // midpoints bordas: (50,0), (100,25), (50,50), (0,25)
      rect = RectangleShape(const Vector3(0, 0), const Vector3(100, 50));
    });

    test('snap para canto (endpoint)', () {
      final r = service.snap(
        mousePoint: const Vector3(1, 1),
        sceneShapes: [rect],
        zoom: 1.0,
      );

      expect(r.type, SnapType.endpoint);
      expect(r.position, const Vector3(0, 0));
    });

    test('snap para midpoint da borda inferior', () {
      // Midpoint inferior: (50,0). Mouse em (50,3), endpoint mais próximo > 10
      final r = service.snap(
        mousePoint: const Vector3(50, 3),
        sceneShapes: [rect],
        zoom: 1.0,
      );

      expect(r.type, SnapType.midpoint);
      expect(r.position.x, closeTo(50, 1e-6));
      expect(r.position.y, closeTo(0, 1e-6));
    });

    test('snap para midpoint da borda direita', () {
      // Midpoint direita: (100,25). Mouse em (97,25)
      final r = service.snap(
        mousePoint: const Vector3(97, 25),
        sceneShapes: [rect],
        zoom: 1.0,
      );

      expect(r.type, SnapType.midpoint);
      expect(r.position.x, closeTo(100, 1e-6));
      expect(r.position.y, closeTo(25, 1e-6));
    });
  });

  // =========================
  // INTERSECTION (GLOBAL PROVIDER)
  // =========================
  group('SnapService — IntersectionSnapProvider', () {
    test('snap para interseção de duas linhas', () {
      final service = SnapService.createDefault();

      // Linha A: (0,25)-(200,25). Midpoint=(100,25), endpoints longe
      // Linha B: (60,0)-(60,100). Midpoint=(60,50), endpoints longe
      // Interseção em (60,25)
      final lineA = LineShape(const Vector3(0, 25), const Vector3(200, 25));
      final lineB = LineShape(const Vector3(60, 0), const Vector3(60, 100));

      // Mouse em (60,26): intersection (60,25) dist=1, nearest dist≈0
      // Intersection (prio 3) bate nearest (prio 4)
      final r = service.snap(
        mousePoint: const Vector3(60, 26),
        sceneShapes: [lineA, lineB],
        zoom: 1.0,
      );

      expect(r.type, SnapType.intersection);
      expect(r.position.x, closeTo(60, 1e-6));
      expect(r.position.y, closeTo(25, 1e-6));
    });

    test('sem interseção retorna outro snap válido', () {
      final service = SnapService.createDefault();

      // Linhas paralelas: sem interseção
      final lineA = LineShape(const Vector3(0, 0), const Vector3(100, 0));
      final lineB = LineShape(const Vector3(0, 20), const Vector3(100, 20));

      final r = service.snap(
        mousePoint: const Vector3(2, 0),
        sceneShapes: [lineA, lineB],
        zoom: 1.0,
      );

      expect(r.type, isNot(SnapType.intersection));
      expect(r.type, SnapType.endpoint);
    });
  });
}
