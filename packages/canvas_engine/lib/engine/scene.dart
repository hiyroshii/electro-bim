// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 04 05 2026
// - CHG: Scene agora estende CadDocument para compatibilidade com Layers
// - DEP: Scene marcado como @Deprecated, usar CadDocument diretamente
//
// [1.1.2] - 04 05 2026
// - ADD: método insert(int index, Shape shape) para reinserção em comandos undo/redo
//
// [1.1.1] - 02 05 2026
// - FIX: substituído List.unmodifiable por UnmodifiableListView
// - CHG: melhora de performance (sem recriação de lista)
// - FIX: import utilitário adicionado

import 'package:canvas_engine/domain/documents/cad_document.dart';

@Deprecated('Use CadDocument directly. Scene is now a subclass of CadDocument.')
class Scene extends CadDocument {
  // Mantém toda a funcionalidade de CadDocument.
  // Futuramente será removida; migre os consumidores para CadDocument.
}