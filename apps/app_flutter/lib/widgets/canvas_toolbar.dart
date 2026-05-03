// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 02 05 2026
// - ADD: botões Undo (Ctrl+Z) e Redo (Ctrl+Y) na toolbar
// - ADD: parâmetros canUndo / canRedo / onUndo / onRedo
// - CHG: layout com grupos separados (Edit, Navigation, Drawing)
//
// [1.1.0] - 02 05 2026
// - ADD: divisão por categoria: Navigation Tools e Drawing Tools
// - ADD: VerticalDivider entre grupos
//
// [1.0.0] - 02 05 2026
// - ADD: CanvasToolbar widget desacoplado da CanvasView

import 'package:flutter/material.dart';

enum ToolCategory { navigation, drawing, edit }

enum ToolbarTool {
  pan('Pan', Icons.pan_tool_outlined, ToolCategory.navigation),
  select('Select', Icons.near_me_outlined, ToolCategory.navigation),
  line('Line', Icons.show_chart, ToolCategory.drawing),
  pline('Pline', Icons.polyline, ToolCategory.drawing);

  final String label;
  final IconData icon;
  final ToolCategory category;

  const ToolbarTool(this.label, this.icon, this.category);

  static List<ToolbarTool> get navigationTools =>
      values.where((t) => t.category == ToolCategory.navigation).toList();

  static List<ToolbarTool> get drawingTools =>
      values.where((t) => t.category == ToolCategory.drawing).toList();

  String get modeDisplay => switch (this) {
        ToolbarTool.pan => 'PAN',
        ToolbarTool.select => 'SELECT',
        ToolbarTool.line || ToolbarTool.pline => 'DRAW',
      };
}

class CanvasToolbar extends StatelessWidget {
  final ToolbarTool activeTool;
  final ValueChanged<ToolbarTool> onToolSelected;
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
    return Card(
      elevation: 2,
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Edit Tools (Undo/Redo) ---
            _ToolGroup(
              children: [
                _IconButton(
                  icon: Icons.undo,
                  tooltip: 'Undo (Ctrl+Z)',
                  enabled: canUndo,
                  onTap: onUndo,
                ),
                const SizedBox(width: 4),
                _IconButton(
                  icon: Icons.redo,
                  tooltip: 'Redo (Ctrl+Y)',
                  enabled: canRedo,
                  onTap: onRedo,
                ),
              ],
              backgroundColor: Colors.grey[800],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            // --- Navigation Tools ---
            _ToolGroup(
              children: ToolbarTool.navigationTools.map((tool) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: tool == ToolbarTool.navigationTools.first ? 0 : 4,
                  ),
                  child: _ToolButton(
                    tool: tool,
                    active: activeTool == tool,
                    onTap: () => onToolSelected(tool),
                  ),
                );
              }).toList(),
              backgroundColor: Colors.grey[850],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            // --- Drawing Tools ---
            _ToolGroup(
              children: ToolbarTool.drawingTools.map((tool) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: tool == ToolbarTool.drawingTools.first ? 0 : 4,
                  ),
                  child: _ToolButton(
                    tool: tool,
                    active: activeTool == tool,
                    onTap: () => onToolSelected(tool),
                  ),
                );
              }).toList(),
              backgroundColor: Colors.grey[900],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolGroup extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;

  const _ToolGroup({
    required this.children,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final ToolbarTool tool;
  final bool active;
  final VoidCallback onTap;

  const _ToolButton({
    required this.tool,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tool.icon,
              size: 16,
              color: active ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              tool.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: enabled
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? Colors.white : Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}