// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 06 05 2026
// - ADD: testes de integração — CadDocument, Commands, UndoManager
// - ADD: AddShapeCommand, RemoveShapeCommand, MoveGripCommand, MoveEntityCommand
// - ADD: cadeia de undo/redo com múltiplos commands

import 'package:flutter_test/flutter_test.dart';

import 'package:canvas_engine/domain/documents/cad_document.dart';
import 'package:canvas_engine/domain/entities/layer.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/domain/entities/circle_shape.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/commands/add_shape_command.dart';
import 'package:canvas_engine/commands/remove_shape_command.dart';
import 'package:canvas_engine/commands/move_entity_command.dart';
import 'package:canvas_engine/commands/move_grip_command.dart';
import 'package:canvas_engine/controllers/undo_manager.dart';

void main() {
  // =========================
  // CAD DOCUMENT
  // =========================
  group('CadDocument', () {
    late CadDocument document;

    setUp(() => document = CadDocument());

    test('inicia com layer padrão "0"', () {
      expect(document.layers.length, 1);
      expect(document.layers.first.name, '0');
      expect(document.activeLayer.name, '0');
    });

    test('add insere shape na layer ativa', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      document.add(shape);

      expect(document.allShapes, contains(shape));
    });

    test('remove elimina shape do documento', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      document.add(shape);
      document.remove(shape);

      expect(document.allShapes, isEmpty);
    });

    test('contains retorna true para shape presente', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      document.add(shape);

      expect(document.contains(shape), isTrue);
    });

    test('contains retorna false para shape ausente', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));

      expect(document.contains(shape), isFalse);
    });

    test('layerOf retorna layer correto', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      document.add(shape);

      expect(document.layerOf(shape), equals(document.activeLayer));
    });

    test('layer bloqueada excluída de allShapes mas visível em allVisibleShapes', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      document.add(shape);
      document.activeLayer.locked = true;

      expect(document.allShapes, isEmpty);
      expect(document.allVisibleShapes, contains(shape));
    });

    test('layer invisível excluída de allShapes e allVisibleShapes', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      document.add(shape);
      document.activeLayer.visible = false;

      expect(document.allShapes, isEmpty);
      expect(document.allVisibleShapes, isEmpty);
    });

    test('múltiplas layers — allShapes agrega shapes de layers distintas', () {
      final shapeA = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      final shapeB = LineShape(const Vector3(20, 0), const Vector3(30, 0));

      document.add(shapeA);

      final layerB = Layer(name: '1');
      document.addLayer(layerB);
      document.setActiveLayer(layerB);
      document.add(shapeB);

      expect(document.allShapes, containsAll([shapeA, shapeB]));
    });
  });

  // =========================
  // ADD SHAPE COMMAND
  // =========================
  group('AddShapeCommand + UndoManager', () {
    late CadDocument document;
    late UndoManager undoManager;

    setUp(() {
      document = CadDocument();
      undoManager = UndoManager();
    });

    test('execute adiciona shape ao documento', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      undoManager.execute(
        AddShapeCommand(document: document, shape: shape, layerIndex: 0),
      );

      expect(document.allShapes, contains(shape));
    });

    test('undo remove shape do documento', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      undoManager.execute(
        AddShapeCommand(document: document, shape: shape, layerIndex: 0),
      );
      undoManager.undo();

      expect(document.allShapes, isEmpty);
    });

    test('redo readiciona shape ao documento', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      undoManager.execute(
        AddShapeCommand(document: document, shape: shape, layerIndex: 0),
      );
      undoManager.undo();
      undoManager.redo();

      expect(document.allShapes, contains(shape));
    });

    test('canUndo e canRedo refletem estado correto', () {
      expect(undoManager.canUndo, isFalse);
      expect(undoManager.canRedo, isFalse);

      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      undoManager.execute(
        AddShapeCommand(document: document, shape: shape, layerIndex: 0),
      );

      expect(undoManager.canUndo, isTrue);
      expect(undoManager.canRedo, isFalse);

      undoManager.undo();

      expect(undoManager.canUndo, isFalse);
      expect(undoManager.canRedo, isTrue);
    });
  });

  // =========================
  // REMOVE SHAPE COMMAND
  // =========================
  group('RemoveShapeCommand + UndoManager', () {
    late CadDocument document;
    late UndoManager undoManager;

    setUp(() {
      document = CadDocument();
      undoManager = UndoManager();
    });

    test('execute remove shape do documento', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      document.add(shape);

      final shapeIndex = document.activeLayer.indexOf(shape);
      undoManager.execute(RemoveShapeCommand(
        document: document,
        shape: shape,
        layerIndex: 0,
        shapeIndex: shapeIndex,
      ));

      expect(document.allShapes, isEmpty);
    });

    test('undo restaura shape na posição original', () {
      final shapeA = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      final shapeB = LineShape(const Vector3(20, 0), const Vector3(30, 0));
      document.add(shapeA);
      document.add(shapeB);

      final indexA = document.activeLayer.indexOf(shapeA);
      undoManager.execute(RemoveShapeCommand(
        document: document,
        shape: shapeA,
        layerIndex: 0,
        shapeIndex: indexA,
      ));

      expect(document.allShapes, isNot(contains(shapeA)));

      undoManager.undo();

      expect(document.allShapes, contains(shapeA));
      expect(document.activeLayer.indexOf(shapeA), equals(0));
    });

    test('redo remove novamente após undo', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      document.add(shape);

      final shapeIndex = document.activeLayer.indexOf(shape);
      undoManager.execute(RemoveShapeCommand(
        document: document,
        shape: shape,
        layerIndex: 0,
        shapeIndex: shapeIndex,
      ));
      undoManager.undo();
      undoManager.redo();

      expect(document.allShapes, isEmpty);
    });
  });

  // =========================
  // MOVE GRIP COMMAND
  // =========================
  group('MoveGripCommand + UndoManager', () {
    late UndoManager undoManager;

    setUp(() => undoManager = UndoManager());

    test('execute move grip para nova posição', () {
      final line = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      undoManager.execute(MoveGripCommand(
        shape: line,
        gripIndex: 1,
        from: const Vector3(10, 0),
        to: const Vector3(20, 0),
      ));

      expect(line.end, equals(const Vector3(20, 0)));
    });

    test('undo restaura grip para posição original', () {
      final line = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      undoManager.execute(MoveGripCommand(
        shape: line,
        gripIndex: 1,
        from: const Vector3(10, 0),
        to: const Vector3(20, 0),
      ));
      undoManager.undo();

      expect(line.end, equals(const Vector3(10, 0)));
    });

    test('redo reaaplica movimento do grip', () {
      final line = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      undoManager.execute(MoveGripCommand(
        shape: line,
        gripIndex: 1,
        from: const Vector3(10, 0),
        to: const Vector3(20, 0),
      ));
      undoManager.undo();
      undoManager.redo();

      expect(line.end, equals(const Vector3(20, 0)));
    });
  });

  // =========================
  // MOVE ENTITY COMMAND
  // =========================
  group('MoveEntityCommand + UndoManager', () {
    late UndoManager undoManager;

    setUp(() => undoManager = UndoManager());

    test('undo desfaz translação já aplicada', () {
      final line = LineShape(const Vector3(10, 0), const Vector3(20, 0));
      const delta = Vector3(5, 0);

      // Simula o controller: move a shape antes de registrar o comando
      line.start = line.start + delta;
      line.end = line.end + delta;

      // execute() não move de novo (_executed=true inicialmente)
      undoManager.execute(MoveEntityCommand(shape: line, delta: delta));
      expect(line.start, equals(const Vector3(15, 0)));

      undoManager.undo();
      expect(line.start, equals(const Vector3(10, 0)));
      expect(line.end, equals(const Vector3(20, 0)));
    });

    test('redo reaaplica translação após undo', () {
      final line = LineShape(const Vector3(10, 0), const Vector3(20, 0));
      const delta = Vector3(5, 0);

      line.start = line.start + delta;
      line.end = line.end + delta;

      undoManager.execute(MoveEntityCommand(shape: line, delta: delta));
      undoManager.undo();
      undoManager.redo();

      expect(line.start, equals(const Vector3(15, 0)));
      expect(line.end, equals(const Vector3(25, 0)));
    });
  });

  // =========================
  // CADEIA UNDO / REDO
  // =========================
  group('cadeia de undo/redo', () {
    late CadDocument document;
    late UndoManager undoManager;

    setUp(() {
      document = CadDocument();
      undoManager = UndoManager();
    });

    test('múltiplos undos desfazem em ordem inversa', () {
      final shapeA = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      final shapeB = CircleShape(const Vector3(50, 50), 10);

      undoManager.execute(
        AddShapeCommand(document: document, shape: shapeA, layerIndex: 0),
      );
      undoManager.execute(
        AddShapeCommand(document: document, shape: shapeB, layerIndex: 0),
      );

      undoManager.undo(); // desfaz B
      expect(document.allShapes, isNot(contains(shapeB)));
      expect(document.allShapes, contains(shapeA));

      undoManager.undo(); // desfaz A
      expect(document.allShapes, isEmpty);
    });

    test('novo command limpa pilha de redo', () {
      final shapeA = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      final shapeB = LineShape(const Vector3(20, 0), const Vector3(30, 0));
      final shapeC = CircleShape(const Vector3(50, 50), 5);

      undoManager.execute(
        AddShapeCommand(document: document, shape: shapeA, layerIndex: 0),
      );
      undoManager.execute(
        AddShapeCommand(document: document, shape: shapeB, layerIndex: 0),
      );
      undoManager.undo(); // gera redo de B

      expect(undoManager.canRedo, isTrue);

      undoManager.execute(
        AddShapeCommand(document: document, shape: shapeC, layerIndex: 0),
      );

      expect(undoManager.canRedo, isFalse);
    });

    test('undo sem histórico não lança exceção', () {
      expect(() => undoManager.undo(), returnsNormally);
    });

    test('redo sem histórico não lança exceção', () {
      expect(() => undoManager.redo(), returnsNormally);
    });

    test('clear limpa ambas as pilhas', () {
      final shape = LineShape(const Vector3(0, 0), const Vector3(10, 0));
      undoManager.execute(
        AddShapeCommand(document: document, shape: shape, layerIndex: 0),
      );
      undoManager.undo();

      undoManager.clear();

      expect(undoManager.canUndo, isFalse);
      expect(undoManager.canRedo, isFalse);
    });
  });
}
