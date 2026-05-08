// REV: 1.1.0
// CHANGELOG:
// - FIX: delay ao trancar/destrancar resolvido (tiles ouvem o layer diretamente)
// - ADD: AnimatedSwitcher nos ícones de visibilidade e bloqueio para transição suave
// - CHG: onChanged agora só é chamado quando visibilidade ou ordem mudam (repaint real)

import 'package:flutter/material.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;
import 'package:app_flutter/widgets/color_palette.dart';

class LayerPanel extends StatefulWidget {
  final engine.CadDocument document;
  final VoidCallback onChanged; // agora apenas para mudanças de visibilidade/ordem

  const LayerPanel({
    super.key,
    required this.document,
    required this.onChanged,
  });

  @override
  State<LayerPanel> createState() => _LayerPanelState();
}

class _LayerPanelState extends State<LayerPanel> {
  @override
  void initState() {
    super.initState();
    widget.document.addListener(_onDocumentChanged);
  }

  @override
  void dispose() {
    widget.document.removeListener(_onDocumentChanged);
    super.dispose();
  }

  void _onDocumentChanged() {
    setState(() {});
    // O onChanged ainda é chamado, pois o documento mudou (layers adicionados/removidos, ordem, etc.)
    // Mas cada tile agora é responsável por sua própria atualização.
    widget.onChanged();
  }

  void _addLayer() {
    final count = widget.document.layers.length;
    final newLayer = engine.Layer(
      name: 'Layer $count',
      order: count,
    );
    widget.document.addLayer(newLayer);
    widget.document.setActiveLayer(newLayer);
  }

  void _removeLayer(engine.Layer layer) {
    if (widget.document.layers.length <= 1) return;
    widget.document.removeLayer(layer);
  }

  void _toggleVisibility(engine.Layer layer) {
    layer.visible = !layer.visible;
    // Dispara onChanged porque a renderização precisa ser atualizada
    widget.onChanged();
  }

  void _toggleLock(engine.Layer layer) {
    layer.locked = !layer.locked;
    // Não precisa de onChanged; o próprio tile se atualiza.
  }

  Future<void> _pickColor(engine.Layer layer) async {
    final color = await showColorPickerDialog(context, layer.color);
    if (color != null) {
      layer.color = color;
      widget.onChanged(); // repintura necessária
    }
  }

  @override
  Widget build(BuildContext context) {
    final layers = widget.document.layers.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(right: BorderSide(color: Colors.grey.shade700)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Layers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: 'Nova Layer',
                  onPressed: _addLayer,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: layers.length,
              itemBuilder: (context, index) {
                final layer = layers[index];
                final isActive = layer == widget.document.activeLayer;
                return _LayerTile(
                  layer: layer,
                  isActive: isActive,
                  onTap: () => widget.document.setActiveLayer(layer),
                  onToggleVisibility: () => _toggleVisibility(layer),
                  onToggleLock: () => _toggleLock(layer),
                  onPickColor: () => _pickColor(layer),
                  onRemove: () => _removeLayer(layer),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerTile extends StatefulWidget {
  final engine.Layer layer;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;
  final VoidCallback onToggleLock;
  final VoidCallback onPickColor;
  final VoidCallback onRemove;

  const _LayerTile({
    required this.layer,
    required this.isActive,
    required this.onTap,
    required this.onToggleVisibility,
    required this.onToggleLock,
    required this.onPickColor,
    required this.onRemove,
  });

  @override
  State<_LayerTile> createState() => _LayerTileState();
}

class _LayerTileState extends State<_LayerTile> {
  @override
  void initState() {
    super.initState();
    widget.layer.addListener(_onLayerChanged);
  }

  @override
  void dispose() {
    widget.layer.removeListener(_onLayerChanged);
    super.dispose();
  }

  void _onLayerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: widget.isActive ? Colors.blue.shade800.withValues(alpha: 0.5) : Colors.transparent,
        child: Row(
          children: [
            // Indicador de cor
            GestureDetector(
              onTap: widget.onPickColor,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: layer.color,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Nome
            Expanded(
              child: Text(
                layer.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Visibilidade com animação
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: IconButton(
                key: ValueKey('vis_${layer.visible}'),
                icon: Icon(
                  layer.visible ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: Colors.white70,
                ),
                onPressed: widget.onToggleVisibility,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            // Bloqueio com animação
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: IconButton(
                key: ValueKey('lock_${layer.locked}'),
                icon: Icon(
                  layer.locked ? Icons.lock : Icons.lock_open,
                  size: 16,
                  color: Colors.white70,
                ),
                onPressed: widget.onToggleLock,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            // Remover
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white70),
              onPressed: widget.onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}