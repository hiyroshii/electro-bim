// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 04 05 2026
// - ADD: CadDocument — gerencia múltiplos layers, layer ativa, iteração plana
// - ADD: allShapes: shapes visíveis e desbloqueadas (snap, hit test)
// - ADD: allVisibleShapes: shapes visíveis (renderização)
// - ADD: compatibilidade com Scene via métodos add/remove/insert
// - ADD: notifica listeners (ChangeNotifier) ao alterar layers ou entidades

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/entities/layer.dart';

class CadDocument extends ChangeNotifier {
  final List<Layer> _layers = [];
  late Layer activeLayer;

  CadDocument() {
    // Cria uma layer padrão "0"
    final defaultLayer = Layer(name: '0');
    _layers.add(defaultLayer);
    activeLayer = defaultLayer;
  }

  UnmodifiableListView<Layer> get layers => UnmodifiableListView(_layers);

  /// Todas as entidades visíveis e não bloqueadas (para snap, hit test).
  List<Shape> get allShapes {
    final List<Shape> all = [];
    final sorted = List<Layer>.from(_layers)..sort((a, b) => a.order.compareTo(b.order));
    for (final layer in sorted) {
      if (layer.visible && !layer.locked) {
        all.addAll(layer.shapes);
      }
    }
    return all;
  }

  /// Todas as entidades visíveis, independente de bloqueio (para renderização).
  List<Shape> get allVisibleShapes {
    final List<Shape> all = [];
    final sorted = List<Layer>.from(_layers)..sort((a, b) => a.order.compareTo(b.order));
    for (final layer in sorted) {
      if (layer.visible) {
        all.addAll(layer.shapes);
      }
    }
    return all;
  }

  // --- Gerenciamento de layers ---
  void addLayer(Layer layer) {
    _layers.add(layer);
    notifyListeners();
  }

  void removeLayer(Layer layer) {
    if (_layers.length <= 1) return;
    _layers.remove(layer);
    if (activeLayer == layer) {
      activeLayer = _layers.first;
    }
    notifyListeners();
  }

  void setActiveLayer(Layer layer) {
    if (_layers.contains(layer)) {
      activeLayer = layer;
      notifyListeners();
    }
  }

  // --- Atalhos para compatibilidade com Scene ---
  void add(Shape shape) => activeLayer.add(shape);

  void remove(Shape shape) {
    for (final layer in _layers) {
      if (layer.contains(shape)) {
        layer.remove(shape);
        notifyListeners();
        return;
      }
    }
  }

  void insert(int layerIndex, int shapeIndex, Shape shape) {
    if (layerIndex >= 0 && layerIndex < _layers.length) {
      _layers[layerIndex].insert(shapeIndex, shape);
      notifyListeners();
    }
  }

  bool contains(Shape shape) => _layers.any((l) => l.contains(shape));

  void clear() {
    for (final layer in _layers) {
      layer.shapes.toList().forEach(layer.remove);
    }
    notifyListeners();
  }

  /// Retorna o layer que contém a shape (para comandos undo/redo).
  Layer? layerOf(Shape shape) {
    for (final layer in _layers) {
      if (layer.contains(shape)) return layer;
    }
    return null;
  }
}