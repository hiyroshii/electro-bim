// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 04 05 2026
// - FIX: valor padrão da cor alterado para const Color (corrige erro non_constant_default_value)
//
// [1.0.1] - 04 05 2026
// - FIX: import de Color trocado para dart:ui (remove dependência de material.dart)
//
// [1.0.0] - 04 05 2026
// - ADD: Layer — contêiner de entidades com propriedades visuais e de controle

import 'dart:collection';
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:canvas_engine/domain/entities/shape.dart';

class Layer extends ChangeNotifier {
  final String _name;
  Color _color;
  bool _visible;
  bool _locked;
  int _order;
  final List<Shape> _shapes = [];

  Layer({
    required String name,
    Color color = const Color(0xFF000000), // const agora
    bool visible = true,
    bool locked = false,
    int order = 0,
  })  : _name = name,
        _color = color,
        _visible = visible,
        _locked = locked,
        _order = order;

  // --- Getters ---
  String get name => _name;
  Color get color => _color;
  bool get visible => _visible;
  bool get locked => _locked;
  int get order => _order;
  UnmodifiableListView<Shape> get shapes => UnmodifiableListView(_shapes);

  // --- Setters com notificação ---
  set color(Color c) {
    if (_color != c) {
      _color = c;
      notifyListeners();
    }
  }
  set visible(bool v) {
    if (_visible != v) {
      _visible = v;
      notifyListeners();
    }
  }
  set locked(bool l) {
    if (_locked != l) {
      _locked = l;
      notifyListeners();
    }
  }
  set order(int o) {
    if (_order != o) {
      _order = o;
      notifyListeners();
    }
  }

  // --- Manipulação de entidades ---
  void add(Shape shape) {
    _shapes.add(shape);
    notifyListeners();
  }

  void remove(Shape shape) {
    _shapes.remove(shape);
    notifyListeners();
  }

  void insert(int index, Shape shape) {
    if (index >= 0 && index <= _shapes.length) {
      _shapes.insert(index, shape);
    } else {
      _shapes.add(shape);
    }
    notifyListeners();
  }

  bool contains(Shape shape) => _shapes.contains(shape);

  int indexOf(Shape shape) => _shapes.indexOf(shape);
}