// REV: 1.1.1
// CHANGELOG:
// [1.1.1] - 02 05 2026
// - FIX: substituído List.unmodifiable por UnmodifiableListView
// - CHG: melhora de performance (sem recriação de lista)
// - FIX: import utilitário adicionado

import 'dart:collection';
import 'package:canvas_engine/domain/entities/shape.dart';

class Scene {
  final List<Shape> _elements = [];

  UnmodifiableListView<Shape> get elements =>
      UnmodifiableListView(_elements);

  void add(Shape shape) => _elements.add(shape);
  void remove(Shape shape) => _elements.remove(shape);
  void clear() => _elements.clear();
}