// REV: 1.5.0
// CHANGELOG:
// [1.5.0] - 06 05 2026
// - FIX: projection reescrito para API real (Projection.pointToSegment)
// - FIX: const adicionado em construtores de Segment
// [1.4.0] - 06 05 2026
// - FIX: migração Vector2 → Vector3 (vector2.dart removido do pacote)
// [1.3.1] - 02 05 2026
// - FIX: remoção total de dependência indireta de SnapService
// - CHG: testes 100% isolados de geometria pura (CAD-core)
// - ADD: validação de estabilidade matemática pós-refactor SnapContract V1

import 'package:test/test.dart';

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';
import 'package:canvas_engine/domain/geometry/primitives/segment.dart';
import 'package:canvas_engine/domain/geometry/primitives/aabb.dart';
import 'package:canvas_engine/domain/geometry/operations/distance.dart';
import 'package:canvas_engine/domain/geometry/operations/intersection.dart';
import 'package:canvas_engine/domain/geometry/operations/projection.dart';

void main() {
  // =========================
  // VECTOR3
  // =========================
  group('Vector3', () {
    test('aritmética básica', () {
      const a = Vector3(1, 2);
      const b = Vector3(3, 4);

      expect(a + b, equals(const Vector3(4, 6)));
      expect(b - a, equals(const Vector3(2, 2)));
      expect(a * 2, equals(const Vector3(2, 4)));
      expect(b / 2, equals(const Vector3(1.5, 2)));
    });

    test('dot product', () {
      const a = Vector3(1, 0);
      const b = Vector3(0, 1);

      expect(a.dot(b), equals(0.0));
      expect(a.dot(a), equals(1.0));
    });

    test('cross product', () {
      const a = Vector3(1, 0);
      const b = Vector3(0, 1);

      expect(a.cross(b), equals(1.0));
      expect(b.cross(a), equals(-1.0));
    });

    test('length e normalize', () {
      expect(const Vector3(3, 4).length, closeTo(5.0, 1e-10));

      final n = const Vector3(3, 0).normalize();
      expect(n.x, closeTo(1.0, 1e-10));
    });

    test('equalsApprox', () {
      const a = Vector3(1.0, 2.0);
      const b = Vector3(1.0 + 1e-7, 2.0);

      expect(a.equalsApprox(b), isTrue);
    });
  });

  // =========================
  // SEGMENT
  // =========================
  group('Segment', () {
    test('midpoint', () {
      const s = Segment(Vector3(0, 0), Vector3(4, 0));
      expect(s.midpoint, equals(const Vector3(2, 0)));
    });

    test('degenerate segment', () {
      const s = Segment(Vector3(1, 1), Vector3(1, 1));
      expect(s.isDegenerate, isTrue);
    });

    test('non-directional equality', () {
      const a = Segment(Vector3(0, 0), Vector3(1, 1));
      const b = Segment(Vector3(1, 1), Vector3(0, 0));

      expect(a, equals(b));
    });
  });

  // =========================
  // AABB
  // =========================
  group('AABB', () {
    test('contains', () {
      const box = AABB(0, 0, 10, 10);

      expect(box.contains(const Vector3(5, 5)), isTrue);
      expect(box.contains(const Vector3(11, 5)), isFalse);
    });

    test('intersects', () {
      const a = AABB(0, 0, 5, 5);
      const b = AABB(4, 4, 8, 8);

      expect(a.intersects(b), isTrue);
    });
  });

  // =========================
  // DISTANCE
  // =========================
  group('distance', () {
    test('point to point', () {
      expect(
        distancePointToPoint(const Vector3(0, 0), const Vector3(3, 4)),
        closeTo(5.0, 1e-10),
      );
    });

    test('point to segment', () {
      const s = Segment(Vector3(0, 0), Vector3(4, 0));

      expect(
        distancePointToSegment(const Vector3(2, 3), s),
        closeTo(3.0, 1e-10),
      );
    });

    test('degenerate segment safe', () {
      const s = Segment(Vector3(2, 2), Vector3(2, 2));

      expect(
        () => distancePointToSegment(const Vector3(5, 5), s),
        returnsNormally,
      );
    });
  });

  // =========================
  // INTERSECTION
  // =========================
  group('intersection', () {
    test('crossing segments', () {
      const a = Segment(Vector3(0, 0), Vector3(4, 4));
      const b = Segment(Vector3(0, 4), Vector3(4, 0));

      final r = intersectSegments(a, b);

      expect(r.type, equals(IntersectionType.intersect));
      expect(r.point!.x, closeTo(2.0, 1e-10));
    });

    test('parallel segments', () {
      const a = Segment(Vector3(0, 0), Vector3(4, 0));
      const b = Segment(Vector3(0, 1), Vector3(4, 1));

      expect(intersectSegments(a, b).type, IntersectionType.parallel);
    });

    test('collinear segments', () {
      const a = Segment(Vector3(0, 0), Vector3(4, 0));
      const b = Segment(Vector3(2, 0), Vector3(6, 0));

      expect(intersectSegments(a, b).type, IntersectionType.collinear);
    });

    test('no intersection', () {
      const a = Segment(Vector3(0, 0), Vector3(1, 0));
      const b = Segment(Vector3(3, 1), Vector3(3, -1));

      expect(intersectSegments(a, b).type, IntersectionType.none);
    });
  });

  // =========================
  // PROJECTION
  // =========================
  group('projection', () {
    test('ponto projetado dentro do segmento', () {
      final r = Projection.pointToSegment(
        const Vector3(2, 3),
        const Vector3(0, 0),
        const Vector3(4, 0),
      );

      expect(r, equals(const Vector3(2, 0)));
    });

    test('clamp — ponto além do fim do segmento', () {
      final r = Projection.pointToSegment(
        const Vector3(10, 3),
        const Vector3(0, 0),
        const Vector3(4, 0),
      );

      expect(r, equals(const Vector3(4, 0)));
    });

    test('clamp — ponto antes do início do segmento', () {
      final r = Projection.pointToSegment(
        const Vector3(-2, 3),
        const Vector3(0, 0),
        const Vector3(4, 0),
      );

      expect(r, equals(const Vector3(0, 0)));
    });

    test('segmento degenerado retorna ponto de origem', () {
      final r = Projection.pointToSegment(
        const Vector3(5, 5),
        const Vector3(2, 2),
        const Vector3(2, 2),
      );

      expect(r, equals(const Vector3(2, 2)));
    });
  });

  // =========================
  // TOLERANCE
  // =========================
  group('tolerance', () {
    test('hitTestWorld scale inverse', () {
      expect(Tolerance.hitTestWorld(2.0), closeTo(3.0, 1e-10));
      expect(Tolerance.hitTestWorld(0.5), closeTo(12.0, 1e-10));
    });
  });
}
