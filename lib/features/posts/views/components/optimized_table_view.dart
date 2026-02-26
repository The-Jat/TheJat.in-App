import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:html/dom.dart' as dom;

class OptimizedTableView extends StatefulWidget {
  final dom.Element element;

  const OptimizedTableView({super.key, required this.element});

  @override
  State<OptimizedTableView> createState() => _OptimizedTableViewState();
}

class _OptimizedTableViewState extends State<OptimizedTableView> {
  late final List<dom.Element> _rows;
  late final int _columnCount;
  late final List<bool> _isHeaderRow;

  @override
  void initState() {
    super.initState();
    _initializeTableData();
  }

  void _initializeTableData() {
    // Cache DOM queries to avoid repeated calls
    final allRows = widget.element.querySelectorAll('tr');

    // Filter out empty or placeholder rows
    _rows = allRows.where((row) {
      final cells = row.children;
      if (cells.isEmpty) return false;

      // Check if row has meaningful content
      final hasContent = cells.any((cell) {
        final text = cell.text.trim();
        return text.isNotEmpty &&
            text.length > 1 &&
            !['H', 'A', 'h', 'a']
                .contains(text) && // Filter out single letter placeholders
            !text.contains('&nbsp;') && // Filter out non-breaking spaces
            text != '&nbsp;';
      });

      return hasContent;
    }).toList();

    _isHeaderRow =
        _rows.map((row) => row.parent?.localName == 'thead').toList();

    // Get column count from first valid row
    _columnCount = _rows.isNotEmpty ? _rows.first.children.length : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_rows.isEmpty) return const SizedBox();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          child: _buildLayoutGrid(context, constraints.maxWidth - 4, isDark),
        );
      },
    );
  }

  Widget _buildLayoutGrid(BuildContext context, double maxWidth, bool isDark) {
    // Create grid template columns
    final columnWidth = maxWidth / _columnCount;
    final columnSizes = List.generate(
      _columnCount,
      (index) => columnWidth.px,
    );

    // Create grid template rows
    final rowSizes = List.generate(
      _rows.length,
      (index) => auto,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: LayoutGrid(
        columnSizes: columnSizes,
        rowSizes: rowSizes,
        columnGap: 0,
        rowGap: 0,
        children: _buildGridCells(context, isDark),
      ),
    );
  }

  List<Widget> _buildGridCells(BuildContext context, bool isDark) {
    final cells = <Widget>[];

    for (int rowIndex = 0; rowIndex < _rows.length; rowIndex++) {
      final tr = _rows[rowIndex];
      final isHeader = _isHeaderRow[rowIndex];

      for (int colIndex = 0; colIndex < _columnCount; colIndex++) {
        String cellText = '';
        if (colIndex < tr.children.length) {
          cellText = tr.children[colIndex].text.trim();
        }

        cells.add(
          GridPlacement(
            columnStart: colIndex,
            columnSpan: 1,
            rowStart: rowIndex,
            rowSpan: 1,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isHeader
                    ? isDark
                        ? Colors.grey.shade700
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: .3)
                    : isDark
                        ? Colors.grey.shade900
                        : Colors.white,
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              child: TableCell(
                text: cellText,
                isHeader: isHeader,
              ),
            ),
          ),
        );
      }
    }

    return cells;
  }
}

class TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const TableCell({
    super.key,
    required this.text,
    required this.isHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
        fontSize: 14,
        color: isHeader
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: .8),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
