import 'package:test/test.dart';
import 'package:canvas_engine/domain/value_objects/vector2.dart';
import 'package:canvas_engine/services/snap/snap_service.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';

void main() {
  test('snap retorna none quando não há providers', () {
    final service = SnapService([]);

    final result = service.snap(
      point: const Vector2(0, 0),
      shapes: [],
      zoom: 1.0,
    );

    expect(result.type, SnapType.none);
    expect(result.point, const Vector2(0, 0));
  });
}