// REV: 1.0.1
// CHANGELOG:
// - ADD: isClosed para corrigir ghost grips nas bordas

import 'package:canvas_engine/canvas_engine.dart';

class RectangleShape extends Shape {
  Vector3 corner1;
  Vector3 corner2;

  RectangleShape(this.corner1, this.corner2);

  Vector3 get origin => Vector3(
        corner1.x < corner2.x ? corner1.x : corner2.x,
        corner1.y < corner2.y ? corner1.y : corner2.y,
        0,
      );

  Vector3 get opposite => Vector3(
        corner1.x > corner2.x ? corner1.x : corner2.x,
        corner1.y > corner2.y ? corner1.y : corner2.y,
        0,
      );

  double get width => (corner1.x - corner2.x).abs();
  double get height => (corner1.y - corner2.y).abs();

  @override
  bool get isClosed => true;

  @override
  void draw(RenderAdapter adapter) {
    adapter.drawRect(origin, width, height);
  }

  @override
  bool hitTest(Vector3 point, {double tolerance = Tolerance.geometric}) {
    final o = origin;
    final opp = opposite;
    final inside = point.x >= o.x - tolerance &&
        point.x <= opp.x + tolerance &&
        point.y >= o.y - tolerance &&
        point.y <= opp.y + tolerance;
    final onBorder = ((point.x >= o.x - tolerance && point.x <= opp.x + tolerance) &&
            ((point.y - o.y).abs() < tolerance || (point.y - opp.y).abs() < tolerance)) ||
        ((point.y >= o.y - tolerance && point.y <= opp.y + tolerance) &&
            ((point.x - o.x).abs() < tolerance || (point.x - opp.x).abs() < tolerance));
    return inside || onBorder;
  }

  @override
  List<Vector3> get gripPoints => [
        corner1,
        Vector3(corner2.x, corner1.y, 0),
        corner2,
        Vector3(corner1.x, corner2.y, 0),
      ];

  @override
  void moveGrip(int index, Vector3 newPosition) {
    switch (index) {
      case 0:
        corner1 = newPosition;
        break;
      case 1:
        corner1 = Vector3(corner1.x, newPosition.y, 0);
        corner2 = Vector3(newPosition.x, corner2.y, 0);
        break;
      case 2:
        corner2 = newPosition;
        break;
      case 3:
        corner1 = Vector3(newPosition.x, corner1.y, 0);
        corner2 = Vector3(corner2.x, newPosition.y, 0);
        break;
    }
  }

  @override
  Vector3 get centerGrip => Vector3(
        (corner1.x + corner2.x) / 2,
        (corner1.y + corner2.y) / 2,
        0,
      );

  @override
  void insertVertex(int segmentIndex, Vector3 position) {}
}