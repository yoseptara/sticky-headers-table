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
const _selectedBorderSide =
    BorderSide(width: _selectedBorderWidth, color: Color(0xff0D4689));
const _borderRadius = Radius.circular(4);

const _highlightClr = Color(0xffE3F4FD);
const _selectedClr = Color(0xff0D4689);

const _selectedItemIndex = 3;

class _TapHandlerPageState extends State<TapHandlerPage> {
  int? selectedRow;
  int? selectedColumn;
  int? scrollOffsetIndexX;
  int? scrollOffsetIndexY;

  int pageAdder = 0;

  Color getContentColor(int i, int j) {
    if (i == selectedRow && j == selectedColumn) {
      return Colors.amber;
    } else if (i == selectedRow || j == selectedColumn) {
      return Colors.amberAccent;
    } else {
      return Colors.transparent;
    }
  }

  void clearSelectedCell() {
    selectedRow = null;
    selectedColumn = null;
  }

  @override
  void initState() {
    selectedRow = _selectedItemIndex;
    selectedColumn = _selectedItemIndex;
    scrollOffsetIndexX = _selectedItemIndex - 1;
    scrollOffsetIndexY = _selectedItemIndex - 3;
    super.initState();
  }

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
              scrollOffsetIndexX: scrollOffsetIndexX,
              scrollOffsetIndexY: scrollOffsetIndexY,
              onLeftCircleButtonPressed: () => setState(() {
                clearSelectedCell();
                pageAdder -= 1;
              }),
              onRightCircleButtonPressed: () => setState(() {
                clearSelectedCell();
                pageAdder += 1;
              }),
              onTopCircleButtonPressed: () => setState(() {
                clearSelectedCell();
                pageAdder -= 1;
              }),
              onBottomCircleButtonPressed: () => setState(() {
                clearSelectedCell();
                pageAdder += 1;
              }),
              cellDimensions: CellDimensions.fixed(
                contentCellWidth: 88,
                contentCellHeight: 68,
                stickyLegendWidth: 97,
                stickyLegendHeight: 64,
              ),
              columnsTitleBuilder: (i) {
                final isLastRow = i + 1 >= widget.titleColumn.length;
                final isAnyColumnCellSelected = selectedRow == i;
                return Stack(
                  children: [
                    DecoratedBox(
                      decoration: buildColumnsTitleDecoration(
                        isAnyColumnCellSelected: isAnyColumnCellSelected,
                        isLastRow: isLastRow,
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
                          Text(
                            '${15 + pageAdder} Jun',
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
                    // if (buildBorder(isAnyColumnCellSelected))
                    //   Positioned.fill(
                    //     left: (buildBorder(isAnyColumnCellSelected)
                    //             ? _selectedBorderWidth
                    //             : _defaultBorderWidth) *
                    //         -1,
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.only(
                    //           topLeft: _borderRadius,
                    //           topRight: _borderRadius,
                    //         ),
                    //         border: buildBorder(isAnyColumnCellSelected)
                    //             ? Border(
                    //                 top: _selectedBorderSide,
                    //                 left: _selectedBorderSide,
                    //                 right: _selectedBorderSide,
                    //               )
                    //             : Border.all(
                    //                 width: 1, color: Color(0xffE1E7EA)),
                    //       ),
                    //     ),
                    //   ),
                  ],
                );
              },
              rowsTitleBuilder: (i) {
                final isLastColumn = i + 1 >= widget.titleRow.length;
                final isAnyRowCellSelected = selectedColumn == i;
                return DecoratedBox(
                  decoration: buildRowsTitleDecoration(
                    isAnyRowCellSelected: isAnyRowCellSelected,
                    isLastColumn: isLastColumn,
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
                      Text(
                        '${15 + pageAdder} Jun',
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

                final isLastRow = i + 1 >= widget.titleColumn.length;
                final isLastColumn = j + 1 >= widget.titleRow.length;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                scrollOffsetIndexX = null;
                                scrollOffsetIndexY = null;

                                setState(() {
                                  selectedColumn = j;
                                  selectedRow = i;
                                });
                              },
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: getCellColor(isSelected,
                                      isRowHighlighted || isColumnHighlighted),
                                  borderRadius: isSelected
                                      ? BorderRadius.only(
                                          bottomRight: _borderRadius,
                                        )
                                      : null,
                                  border: getBorder(
                                    isRowHighlighted: isRowHighlighted,
                                    isColumnHighlighted: isColumnHighlighted,
                                    isLastRow: isLastRow,
                                    isLastColumn: isLastColumn,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                    Text(
                                      '3.${15 + pageAdder}k',
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
                                      '4.${15 + pageAdder}k',
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
                        ],
                      ),
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

  BoxDecoration buildRowsTitleDecoration({
    required bool isAnyRowCellSelected,
    required bool isLastColumn,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: isAnyRowCellSelected ? _borderRadius : Radius.zero,
        bottomLeft: isAnyRowCellSelected ? _borderRadius : Radius.zero,
      ),
      border: Border(
        top: isAnyRowCellSelected ? _selectedBorderSide : BorderSide.none,
        left: isAnyRowCellSelected ? _selectedBorderSide : BorderSide.none,
        bottom: buildRowTitleBottomBorder(
          isAnyRowCellSelected: isAnyRowCellSelected,
          isLastColumn: isLastColumn,
        ),
      ),
    );
  }

  BorderSide buildRowTitleBottomBorder({
    required bool isAnyRowCellSelected,
    required bool isLastColumn,
  }) {
    if (isAnyRowCellSelected) return _selectedBorderSide;

    if (!isLastColumn) return _defaultBorderSide;

    return BorderSide.none;
  }

  BoxDecoration buildColumnsTitleDecoration({
    required bool isAnyColumnCellSelected,
    required bool isLastRow,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: isAnyColumnCellSelected ? _borderRadius : Radius.zero,
        topRight: isAnyColumnCellSelected ? _borderRadius : Radius.zero,
      ),
      border: Border(
        top: isAnyColumnCellSelected ? _selectedBorderSide : BorderSide.none,
        left: isAnyColumnCellSelected ? _selectedBorderSide : BorderSide.none,
        right: buildColumnTitleRightBorder(
          isAnyColumnCellSelected: isAnyColumnCellSelected,
          isLastRow: isLastRow,
        ),
      ),
    );
  }

  BorderSide buildColumnTitleRightBorder({
    required bool isAnyColumnCellSelected,
    required bool isLastRow,
  }) {
    if (isAnyColumnCellSelected) return _selectedBorderSide;

    if (!isLastRow) return _defaultBorderSide;

    return BorderSide.none;
  }

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
    required bool isLastRow,
    required bool isLastColumn,
  }) {
    return Border(
      left: isColumnHighlighted ? _selectedBorderSide : BorderSide.none,
      top: isRowHighlighted ? _selectedBorderSide : BorderSide.none,
      right: buildCellRightOrBottomBorder(
        isHighlighted: isColumnHighlighted,
        isLast: isLastRow,
      ),
      bottom: buildCellRightOrBottomBorder(
        isHighlighted: isRowHighlighted,
        isLast: isLastColumn,
      ),
    );
  }

  BorderSide buildCellRightOrBottomBorder({
    required bool isHighlighted,
    required isLast,
  }) {
    if (isHighlighted) return _selectedBorderSide;

    // if (!isLast) return _defaultBorderSide;

    return _defaultBorderSide;
  }
}
