import 'package:test/test.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/services/snap/snap_service.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';

void main() {
  test('snap retorna none quando não há providers', () {
    final service = SnapService();

    final result = service.snap(
      mousePoint: const Vector3(0, 0),
      sceneShapes: [],
      zoom: 1.0,
    );

    expect(result.type, SnapType.none);
    expect(result.point, const Vector3(0, 0));
  });
}
