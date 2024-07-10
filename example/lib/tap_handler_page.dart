import 'package:flutter/material.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class TapHandlerPage extends StatefulWidget {
  TapHandlerPage({
    required this.data,
    required this.titleColumn,
    required this.titleRow,
  });

  final List<List<String>> data;
  final List<String> titleColumn;
  final List<String> titleRow;

  @override
  _TapHandlerPageState createState() => _TapHandlerPageState();
}

const _defaultBorderWidth = 1.0;
const _defaultBorderClr = Color(0xffE1E7EA);
const _defaultBorderSide =
    BorderSide(width: _defaultBorderWidth, color: _defaultBorderClr);

const _selectedBorderWidth = 1.5;
const _selectedBorderSide = BorderSide(width: _selectedBorderWidth, color: Color(0xff0D4689));
const _borderRadius = Radius.circular(4);

const _highlightClr = Color(0xffE3F4FD);
const _selectedClr = Color(0xff0D4689);

class _TapHandlerPageState extends State<TapHandlerPage> {
  int? selectedRow;
  int? selectedColumn;

  Color getContentColor(int i, int j) {
    if (i == selectedRow && j == selectedColumn) {
      return Colors.amber;
    } else if (i == selectedRow || j == selectedColumn) {
      return Colors.amberAccent;
    } else {
      return Colors.transparent;
    }
  }

  void clearState() => setState(() {
        selectedRow = null;
        selectedColumn = null;
      });

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'Tap handler example: highlight selected cell with row & column',
              maxLines: 2,
            ),
            backgroundColor: Colors.amber,
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(16, 60, 0, 0),
            child: StickyHeadersTable(
              columnsLength: widget.titleColumn.length,
              rowsLength: widget.titleRow.length,
              cellDimensions: CellDimensions.fixed(
                contentCellWidth: 88,
                contentCellHeight: 68,
                stickyLegendWidth: 97,
                stickyLegendHeight: 64,
              ),
              columnsTitleBuilder: (i) {
                final isLastRow =
                    (selectedRow ?? 0) + 1 == widget.titleColumn.length;
                final isAnyColumnCellSelected = selectedRow == i;
                return Stack(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                          border: isLastRow
                              ? null
                              : Border(
                                  right: _defaultBorderSide,
                                )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Thu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 18 / 12,
                              color: Color(0xff333333),
                            ),
                          ),
                          const Text(
                            '11 Jun',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              height: 18 / 12,
                              color: Color(0xff333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isAnyColumnCellSelected)
                      Positioned.fill(
                        left: (isAnyColumnCellSelected ? _selectedBorderWidth : _defaultBorderWidth) * -1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: _borderRadius,
                              topRight: _borderRadius,
                            ),
                            border: isAnyColumnCellSelected
                                ? Border(
                                    top: _selectedBorderSide,
                                    left: _selectedBorderSide,
                                    right: _selectedBorderSide,
                                  )
                                : Border.all(width: 1, color: Color(0xffE1E7EA)),
                          ),
                        ),
                      ),
                  ],
                );
              },
              rowsTitleBuilder: (i) {
                final isAnyRowCellSelected = selectedColumn == i;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: _borderRadius,
                      bottomLeft: _borderRadius,
                    ),
                    border: isAnyRowCellSelected
                        ? Border(
                            top: _selectedBorderSide,
                            left: _selectedBorderSide,
                            bottom: _selectedBorderSide,
                          )
                        : Border.all(width: 1, color: Color(0xffE1E7EA)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Thu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 18 / 12,
                          color: Color(0xff333333),
                        ),
                      ),
                      const Text(
                        '11 Jun',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          height: 18 / 12,
                          color: Color(0xff333333),
                        ),
                      ),
                    ],
                  ),
                );
              },
              contentCellBuilder: (i, j) {
                final selectedRowValue = selectedRow ?? -1;
                final selectedColumnValue = selectedColumn ?? -1;

                final isSelected = selectedRow == i && selectedColumn == j;
                final isRowHighlighted =
                    (selectedColumn == j && selectedRowValue >= i);
                final isColumnHighlighted =
                    selectedRow == i && selectedColumnValue >= j;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                selectedColumn = j;
                                selectedRow = i;
                              }),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: getCellColor(isSelected,
                                      isRowHighlighted || isColumnHighlighted),
                                  borderRadius: isSelected
                                      ? BorderRadius.only(
                                          bottomRight: _borderRadius)
                                      : null,
                                  border: getBorder(
                                    isRowHighlighted: isRowHighlighted,
                                    isColumnHighlighted: isColumnHighlighted,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'From MYR',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        height: 14 / 12,
                                        color: Color(0xffA7B6BF),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    const Text(
                                      '3.5k',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                        height: 18 / 12,
                                        color: Color(0xffA7B6BF),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      '4.8k',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                        height: 18 / 12,
                                        color: isSelected
                                            ? Colors.white
                                            : Color(0xff333333),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: _defaultBorderWidth,
                            height: double.infinity,
                            color: _defaultBorderClr,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: _defaultBorderWidth,
                      color: _defaultBorderClr,
                    ),
                  ],
                );
              },
              // legendCell: TextButton(
              //   child: Text('Sticky Legend'),
              //   onPressed: clearState,
              // ),
            ),
          ),
        ),
      );

  Color? getCellColor(bool isSelected, bool isHighlighted) {
    if (isSelected) {
      return _selectedClr;
    }

    if (isHighlighted) {
      return _highlightClr;
    }

    return null;
  }

  Border getBorder({
    required bool isRowHighlighted,
    required bool isColumnHighlighted,
  }) {
    return Border(
      left: isColumnHighlighted ? _selectedBorderSide : _defaultBorderSide,
      top: isRowHighlighted ? _selectedBorderSide : _defaultBorderSide,
      right: isColumnHighlighted ? _selectedBorderSide : _defaultBorderSide,
      bottom: isRowHighlighted ? _selectedBorderSide : _defaultBorderSide,
    );
  }
}
