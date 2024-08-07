import 'package:flutter/material.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class DecoratedTablePage extends StatefulWidget {
  DecoratedTablePage({
    required this.data,
    required this.titleColumn,
    required this.titleRow,
  });

  final List<List<String>> data;
  final List<String> titleColumn;
  final List<String> titleRow;

  @override
  State<DecoratedTablePage> createState() => _DecoratedTablePageState();
}

class _DecoratedTablePageState extends State<DecoratedTablePage> {
  var isHorizontalScrollbar = false;
  var isVerticalScrollbar = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sticky Headers Two-Dimension  Table decorated',
          maxLines: 2,
        ),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Expanded(
            child: StickyHeadersTable(
              columnsLength: widget.titleColumn.length,
              rowsLength: widget.titleRow.length,
              columnsTitleBuilder: (i) => TableCell.stickyRow(
                widget.titleColumn[i],
                textStyle: textTheme.labelLarge!.copyWith(fontSize: 15.0),
              ),
              rowsTitleBuilder: (i) => TableCell.stickyColumn(
                widget.titleRow[i],
                textStyle: textTheme.labelLarge!.copyWith(fontSize: 15.0),
              ),
              contentCellBuilder: (i, j) => TableCell.content(
                widget.data[i][j],
                textStyle: textTheme.bodyMedium!.copyWith(fontSize: 12.0),
              ),
              legendCell: TableCell.legend(
                'Sticky Legend',
                textStyle: textTheme.labelLarge!.copyWith(fontSize: 16.5),
              ),
              showVerticalScrollbar: isVerticalScrollbar,
              showHorizontalScrollbar: isHorizontalScrollbar,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Checkbox(
                  value: isHorizontalScrollbar,
                  onChanged: (bool? value) {
                    setState(() {
                      isHorizontalScrollbar = !isHorizontalScrollbar;
                    });
                  },
                ),
                Text('Horizontal scrollbar'),
                const SizedBox(width: 16),
                Checkbox(
                  value: isVerticalScrollbar,
                  onChanged: (bool? value) {
                    setState(() {
                      isVerticalScrollbar = !isVerticalScrollbar;
                    });
                  },
                ),
                Text('Vertical scrollbar'),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TableCell extends StatelessWidget {
  TableCell.content(
    this.text, {
    this.textStyle,
    this.cellDimensions = CellDimensions.base,
    this.colorBg = Colors.white,
    this.onTap,
  })  : cellWidth = cellDimensions.contentCellWidth,
        cellHeight = cellDimensions.contentCellHeight,
        _colorHorizontalBorder = Colors.amber,
        _colorVerticalBorder = Colors.black38,
        _textAlign = TextAlign.center,
        _padding = EdgeInsets.zero;

  TableCell.legend(
    this.text, {
    this.textStyle,
    this.cellDimensions = CellDimensions.base,
    this.colorBg = Colors.amber,
    this.onTap,
  })  : cellWidth = cellDimensions.stickyLegendWidth,
        cellHeight = cellDimensions.stickyLegendHeight,
        _colorHorizontalBorder = Colors.white,
        _colorVerticalBorder = Colors.amber,
        _textAlign = TextAlign.start,
        _padding = EdgeInsets.only(left: 24.0);

  TableCell.stickyRow(
    this.text, {
    this.textStyle,
    this.cellDimensions = CellDimensions.base,
    this.colorBg = Colors.amber,
    this.onTap,
  })  : cellWidth = cellDimensions.contentCellWidth,
        cellHeight = cellDimensions.stickyLegendHeight,
        _colorHorizontalBorder = Colors.white,
        _colorVerticalBorder = Colors.amber,
        _textAlign = TextAlign.center,
        _padding = EdgeInsets.zero;

  TableCell.stickyColumn(
    this.text, {
    this.textStyle,
    this.cellDimensions = CellDimensions.base,
    this.colorBg = Colors.white,
    this.onTap,
  })  : cellWidth = cellDimensions.stickyLegendWidth,
        cellHeight = cellDimensions.contentCellHeight,
        _colorHorizontalBorder = Colors.amber,
        _colorVerticalBorder = Colors.black38,
        _textAlign = TextAlign.start,
        _padding = EdgeInsets.only(left: 24.0);

  final CellDimensions cellDimensions;

  final String text;
  final Function()? onTap;

  final double? cellWidth;
  final double? cellHeight;

  final Color colorBg;
  final Color _colorHorizontalBorder;
  final Color _colorVerticalBorder;

  final TextAlign _textAlign;
  final EdgeInsets _padding;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cellWidth,
        height: cellHeight,
        padding: _padding,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  text,
                  style: textStyle,
                  maxLines: 2,
                  textAlign: _textAlign,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 1.1,
              color: _colorVerticalBorder,
            ),
          ],
        ),
        decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: _colorHorizontalBorder),
              right: BorderSide(color: _colorHorizontalBorder),
            ),
            color: colorBg),
      ),
    );
  }
}
