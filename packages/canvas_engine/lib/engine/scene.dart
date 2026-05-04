// REV: 1.1.2
// CHANGELOG:
// [1.1.2] - 04 05 2026
// - ADD: método insert(int index, Shape shape) para reinserção em comandos undo/redo
//
// [1.1.1] - 02 05 2026
// - FIX: substituído List.unmodifiable por UnmodifiableListView
// ...

import 'dart:collection';
import 'package:canvas_engine/domain/entities/shape.dart';

class Scene {
  final List<Shape> _elements = [];

  UnmodifiableListView<Shape> get elements =>
      UnmodifiableListView(_elements);

  void add(Shape shape) => _elements.add(shape);
  void remove(Shape shape) => _elements.remove(shape);
  void insert(int index, Shape shape) {
    if (index >= 0 && index <= _elements.length) {
      _elements.insert(index, shape);
    } else {
      _elements.add(shape);
    }
  }
  void clear() => _elements.clear();
}