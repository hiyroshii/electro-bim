// REV: 1.1.0
// CHANGELOG:
// - ADD: ferramentas Rectangle e Circle ao enum e toolbar

import 'package:flutter/material.dart';

enum ToolbarTool {
  select('Select', Icons.touch_app_outlined),
  pan('Pan', Icons.pan_tool_outlined),
  line('Line', Icons.show_chart),
  pline('Pline', Icons.polyline),
  rectangle('Rectangle', Icons.rectangle_outlined),
  circle('Circle', Icons.circle_outlined);

  final String modeDisplay;
  final IconData icon;
  const ToolbarTool(this.modeDisplay, this.icon);
}

class CanvasToolbar extends StatelessWidget {
  final ToolbarTool activeTool;
  final void Function(ToolbarTool tool) onToolSelected;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const CanvasToolbar({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolButton(
            icon: ToolbarTool.line.icon,
            tooltip: 'Line (L)',
            isActive: activeTool == ToolbarTool.line,
            onTap: () => onToolSelected(ToolbarTool.line),
          ),
          _ToolButton(
            icon: ToolbarTool.pline.icon,
            tooltip: 'Polyline',
            isActive: activeTool == ToolbarTool.pline,
            onTap: () => onToolSelected(ToolbarTool.pline),
          ),
          _ToolButton(
            icon: ToolbarTool.rectangle.icon,
            tooltip: 'Rectangle (R)',
            isActive: activeTool == ToolbarTool.rectangle,
            onTap: () => onToolSelected(ToolbarTool.rectangle),
          ),
          _ToolButton(
            icon: ToolbarTool.circle.icon,
            tooltip: 'Circle (C)',
            isActive: activeTool == ToolbarTool.circle,
            onTap: () => onToolSelected(ToolbarTool.circle),
          ),
          const SizedBox(height: 8),
          _ToolButton(
            icon: ToolbarTool.select.icon,
            tooltip: 'Select (V)',
            isActive: activeTool == ToolbarTool.select,
            onTap: () => onToolSelected(ToolbarTool.select),
          ),
          _ToolButton(
            icon: ToolbarTool.pan.icon,
            tooltip: 'Pan (N)',
            isActive: activeTool == ToolbarTool.pan,
            onTap: () => onToolSelected(ToolbarTool.pan),
          ),
          const SizedBox(height: 8),
          _ToolButton(
            icon: Icons.undo,
            tooltip: 'Undo (Ctrl+Z)',
            isActive: false,
            enabled: canUndo,
            onTap: onUndo,
          ),
          _ToolButton(
            icon: Icons.redo,
            tooltip: 'Redo (Ctrl+Y)',
            isActive: false,
            enabled: canRedo,
            onTap: onRedo,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;
  final bool enabled;

  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? Colors.blueGrey.shade700 : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? (isActive ? Colors.white : Colors.white70)
                : Colors.white30,
          ),
        ),
      ),
    );
  }
}