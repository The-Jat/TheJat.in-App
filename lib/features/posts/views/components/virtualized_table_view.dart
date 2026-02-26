import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:html/dom.dart' as dom;

class VirtualizedTableView extends StatefulWidget {
  final dom.Element element;

  const VirtualizedTableView({super.key, required this.element});

  @override
  State<VirtualizedTableView> createState() => _VirtualizedTableViewState();
}

class _VirtualizedTableViewState extends State<VirtualizedTableView> {
  late final List<dom.Element> _rows;
  late final int _columnCount;
  late final List<bool> _isHeaderRow;
  final ScrollController _scrollController = ScrollController();
  static const double _rowHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _initializeTableData();
  }

  void _initializeTableData() {
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
            !['H', 'A'].contains(text); // Filter out single letter placeholders
      });

      return hasContent;
    }).toList();

    _isHeaderRow =
        _rows.map((row) => row.parent?.localName == 'thead').toList();
    _columnCount = _rows.isNotEmpty ? _rows.first.children.length : 0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rows.isEmpty) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Header row (always visible)
            if (_rows.isNotEmpty && _isHeaderRow.isNotEmpty)
              _buildHeaderGrid(context, constraints.maxWidth),
            // Virtualized body
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: _buildBodyGrid(context, constraints.maxWidth),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderGrid(BuildContext context, double maxWidth) {
    final headerRow = _rows.firstWhere(
      (row) => _isHeaderRow[_rows.indexOf(row)],
      orElse: () => _rows.first,
    );

    final columnWidth = maxWidth / _columnCount;
    final columnSizes = List.generate(
      _columnCount,
      (index) => columnWidth.px,
    );

    return Container(
      width: maxWidth,
      height: _rowHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: LayoutGrid(
        columnSizes: columnSizes,
        rowSizes: [_rowHeight.px],
        columnGap: 0,
        rowGap: 0,
        children: _buildHeaderCells(context, headerRow),
      ),
    );
  }

  Widget _buildBodyGrid(BuildContext context, double maxWidth) {
    final bodyRows =
        _rows.where((row) => !_isHeaderRow[_rows.indexOf(row)]).toList();

    if (bodyRows.isEmpty) return const SizedBox();

    final columnWidth = maxWidth / _columnCount;
    final columnSizes = List.generate(
      _columnCount,
      (index) => columnWidth.px,
    );

    final rowSizes = List.generate(
      bodyRows.length,
      (index) => _rowHeight.px,
    );

    return Container(
      width: maxWidth,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: LayoutGrid(
        columnSizes: columnSizes,
        rowSizes: rowSizes,
        columnGap: 0,
        rowGap: 0,
        children: _buildBodyCells(context, bodyRows),
      ),
    );
  }

  List<Widget> _buildHeaderCells(BuildContext context, dom.Element headerRow) {
    final cells = <Widget>[];

    for (int colIndex = 0; colIndex < _columnCount; colIndex++) {
      String cellText = '';
      if (colIndex < headerRow.children.length) {
        cellText = headerRow.children[colIndex].text.trim();
      }

      cells.add(
        GridPlacement(
          columnStart: colIndex,
          columnSpan: 1,
          rowStart: 0,
          rowSpan: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Text(
              cellText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    return cells;
  }

  List<Widget> _buildBodyCells(
      BuildContext context, List<dom.Element> bodyRows) {
    final cells = <Widget>[];

    for (int rowIndex = 0; rowIndex < bodyRows.length; rowIndex++) {
      final row = bodyRows[rowIndex];

      for (int colIndex = 0; colIndex < _columnCount; colIndex++) {
        String cellText = '';
        if (colIndex < row.children.length) {
          cellText = row.children[colIndex].text.trim();
        }

        cells.add(
          GridPlacement(
            columnStart: colIndex,
            columnSpan: 1,
            rowStart: rowIndex,
            rowSpan: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text(
                cellText,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
    }

    return cells;
  }
}
