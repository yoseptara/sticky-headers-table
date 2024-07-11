library table_sticky_headers;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'custom_properties/cell_alignments.dart';
import 'custom_properties/cell_dimensions.dart';
import 'custom_properties/custom_scroll_physics.dart';
import 'custom_properties/scroll_controllers.dart';

/// Table with sticky headers. Whenever you scroll content horizontally
/// or vertically - top and left headers always stay.
class StickyHeadersTable extends StatefulWidget {
  StickyHeadersTable({
    Key? key,

    /// Number of Columns (for content only)
    required this.columnsLength,

    /// Number of Rows (for content only)
    required this.rowsLength,

    /// Title for Top Left cell (always visible)
    this.legendCell = const Text(''),

    /// Builder for column titles. Takes index of content column as parameter
    /// and returns String for column title
    required this.columnsTitleBuilder,
    this.columnsTitlesLeftBorder,
    this.columnsTitlesTopLeftBorderRadius,

    /// Builder for row titles. Takes index of content row as parameter
    /// and returns String for row title
    required this.rowsTitleBuilder,

    /// Builder for content cell. Takes index for content column first,
    /// index for content row second and returns String for cell
    required this.contentCellBuilder,

    /// Table cell dimensions
    this.cellDimensions = CellDimensions.base,

    /// Alignments for cell contents
    this.cellAlignments = CellAlignments.base,

    /// Callbacks for when pressing a cell
    Function()? onStickyLegendPressed,

    this.onLeftCircleButtonPressed,
    this.onRightCircleButtonPressed,
    this.onTopCircleButtonPressed,
    this.onBottomCircleButtonPressed,

    Function(int columnIndex)? onColumnTitlePressed,
    Function(int rowIndex)? onRowTitlePressed,
    Function(int columnIndex, int rowIndex)? onContentCellPressed,

    /// Called when scrolling has ended, passing the current offset position
    this.onEndScrolling,

    /// Scroll controllers for the table. Make sure that you dispose ScrollControllers inside when you don't need table_sticky_headers anymore.
    ScrollControllers? scrollControllers,

    /// Custom Scroll physics for table
    CustomScrollPhysics? scrollPhysics,

    /// Table Direction to support RTL languages
    this.tableDirection = TextDirection.ltr,

    /// Initial scroll offsets in X and Y directions. Specified in points. Overrides scroll Offset in index if both are present.
    this.initialScrollOffsetX,
    this.initialScrollOffsetY,

    /// Initial scroll offsets in X and Y directions. Specified in index.
    this.scrollOffsetIndexX,
    this.scrollOffsetIndexY,

    /// Turn scrollbars
    this.showVerticalScrollbar,
    this.showHorizontalScrollbar,
  })  : this.shouldDisposeScrollControllers = scrollControllers == null,
        this.scrollControllers = scrollControllers ?? ScrollControllers(),
        this.onStickyLegendPressed = onStickyLegendPressed ?? (() {}),
        this.onColumnTitlePressed = onColumnTitlePressed ?? ((_) {}),
        this.onRowTitlePressed = onRowTitlePressed ?? ((_) {}),
        this.onContentCellPressed = onContentCellPressed ?? ((_, __) {}),
        this.scrollPhysics = scrollPhysics ?? CustomScrollPhysics(),
        super(key: key) {
    cellDimensions.runAssertions(rowsLength, columnsLength);
    cellAlignments.runAssertions(rowsLength, columnsLength);
  }

  final int rowsLength;
  final int columnsLength;
  final Widget legendCell;
  final Widget Function(int columnIndex) columnsTitleBuilder;
  final BorderSide? columnsTitlesLeftBorder;
  final Radius? columnsTitlesTopLeftBorderRadius;
  final Widget Function(int rowIndex) rowsTitleBuilder;
  final Widget Function(int columnIndex, int rowIndex) contentCellBuilder;
  final CellDimensions cellDimensions;
  final CellAlignments cellAlignments;
  final Function() onStickyLegendPressed;
  final Function()? onLeftCircleButtonPressed;
  final Function()? onRightCircleButtonPressed;
  final Function()? onTopCircleButtonPressed;
  final Function()? onBottomCircleButtonPressed;
  final Function(int columnIndex) onColumnTitlePressed;
  final Function(int rowIndex) onRowTitlePressed;
  final Function(int columnIndex, int rowIndex) onContentCellPressed;
  final Function(double x, double y)? onEndScrolling;
  final ScrollControllers scrollControllers;
  final CustomScrollPhysics scrollPhysics;
  final TextDirection tableDirection;
  final int? scrollOffsetIndexY;
  final int? scrollOffsetIndexX;
  final double? initialScrollOffsetX;
  final double? initialScrollOffsetY;
  final bool? showVerticalScrollbar;
  final bool? showHorizontalScrollbar;

  final bool shouldDisposeScrollControllers;

  @override
  _StickyHeadersTableState createState() => _StickyHeadersTableState();
}

class _StickyHeadersTableState extends State<StickyHeadersTable> {
  final globalRowTitleKeys = <int, GlobalKey>{};
  final globalColumnTitleKeys = <int, GlobalKey>{};

  late _SyncScrollController _horizontalSyncController;
  late _SyncScrollController _verticalSyncController;

  late double _scrollOffsetX;
  late double _scrollOffsetY;

  final ValueNotifier<bool> showLeftCircleButton = ValueNotifier(true);
  final ValueNotifier<bool> showRightCircleButton = ValueNotifier(false);
  final ValueNotifier<bool> showTopCircleButton = ValueNotifier(true);
  final ValueNotifier<bool> showBottomCircleButton = ValueNotifier(false);

  void _checkInitialScrollPositions() {
    final horizontalPosition = widget.scrollControllers.horizontalBodyController.position;
    final verticalPosition = widget.scrollControllers.verticalBodyController.position;

    showLeftCircleButton.value = horizontalPosition.pixels > horizontalPosition.minScrollExtent;
    showRightCircleButton.value = horizontalPosition.pixels < horizontalPosition.maxScrollExtent;

    showTopCircleButton.value = verticalPosition.pixels > verticalPosition.minScrollExtent;
    showBottomCircleButton.value = verticalPosition.pixels < verticalPosition.maxScrollExtent;
  }

  bool _onHorizontalScrollingNotification({
    required ScrollNotification notification,
    required ScrollController controller,
  }) {
    final didEndScrolling = _horizontalSyncController.processNotification(
      notification,
      controller,
    );

    final position = controller.position;
    final cellWidth = widget.cellDimensions.contentCellWidth ?? 0;

    if (position.hasPixels) {
      final newShowLeftCircleButton =
          position.pixels <= position.minScrollExtent;
      final newShowRightCircleButton =
          position.pixels >= position.maxScrollExtent;

      if (showLeftCircleButton != newShowLeftCircleButton)
        showLeftCircleButton.value = newShowLeftCircleButton;
      if (showRightCircleButton != newShowRightCircleButton)
        showRightCircleButton.value = newShowRightCircleButton;
    }

    // if (position.hasPixels) {
    //   final newShowLeftCircleButton =
    //       position.pixels > position.minScrollExtent;
    //   final newShowRightCircleButton =
    //       position.pixels < position.maxScrollExtent;
    //
    //   if (showLeftScroll != newShowLeftCircleButton)
    //     setState(() => showLeftScroll = newShowLeftCircleButton);
    //   if (showRightScroll != newShowRightCircleButton)
    //     setState(() => showRightScroll = newShowRightCircleButton);
    // }

    final onEndScrolling = widget.onEndScrolling;
    if (didEndScrolling && onEndScrolling != null) {
      _scrollOffsetX = controller.offset;
      onEndScrolling(_scrollOffsetX, _scrollOffsetY);
    }
    return true;
  }

  bool _onVerticalScrollingNotification({
    required ScrollNotification notification,
    required ScrollController controller,
  }) {
    final didEndScrolling = _verticalSyncController.processNotification(
      notification,
      controller,
    );

    final position = controller.position;
    final cellHeight = widget.cellDimensions.contentCellHeight ?? 0;


    if (position.hasPixels) {
      final newShowTopCircleButton =
          position.pixels <= position.minScrollExtent;
      final newShowBottomCircleButton =
          position.pixels >= position.maxScrollExtent;

      if (showTopCircleButton != newShowTopCircleButton)
        showTopCircleButton.value = newShowTopCircleButton;

      if (showBottomCircleButton != newShowBottomCircleButton)
        showBottomCircleButton.value = newShowBottomCircleButton;
    }
    
    // if (position.hasPixels) {
    //   final newShowTopCircleButton =
    //       position.pixels > position.minScrollExtent;
    //   final newShowBottomCircleButton =
    //       position.pixels < position.maxScrollExtent;
    //
    //   if (showTopScroll != newShowTopCircleButton)
    //     setState(() => showTopScroll = newShowTopCircleButton);
    //
    //   if (showBottomScroll != newShowBottomCircleButton)
    //     setState(() => showBottomScroll = newShowBottomCircleButton);
    // }

    final onEndScrolling = widget.onEndScrolling;
    if (didEndScrolling && onEndScrolling != null) {
      _scrollOffsetY = controller.offset;
      onEndScrolling(_scrollOffsetX, _scrollOffsetY);
    }
    return true;
  }

  void _shiftUsingOffsets() {
    void jumpToIndex(GlobalKey key) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context);
      }
    }

    final scrollOffsetX = widget.initialScrollOffsetX;
    if (scrollOffsetX != null) {
      // Try to use natural offset first
      widget.scrollControllers.horizontalTitleController.jumpTo(scrollOffsetX);
    } else {
      // Try to use index offset second
      final scrollOffsetIndexX = widget.scrollOffsetIndexX;
      final keyX = globalRowTitleKeys[scrollOffsetIndexX];
      if (scrollOffsetIndexX != null && keyX != null) jumpToIndex(keyX);
    }

    final scrollOffsetY = widget.initialScrollOffsetY;
    if (scrollOffsetY != null) {
      // Try to use natural offset first
      widget.scrollControllers.verticalTitleController.jumpTo(scrollOffsetY);
    } else {
      // Try to use index offset second
      final scrollOffsetIndexY = widget.scrollOffsetIndexY;
      final keyY = globalColumnTitleKeys[scrollOffsetIndexY];
      if (scrollOffsetIndexY != null && keyY != null) jumpToIndex(keyY);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollOffsetX = widget.initialScrollOffsetX ?? 0;
    _scrollOffsetY = widget.initialScrollOffsetY ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialScrollPositions();
    });
  }
  @override
  void dispose() {
    if (widget.shouldDisposeScrollControllers) {
      widget.scrollControllers.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _verticalSyncController = _SyncScrollController(
      widget.scrollControllers.verticalTitleController,
      widget.scrollControllers.verticalBodyController,
    );
    _horizontalSyncController = _SyncScrollController(
      widget.scrollControllers.horizontalTitleController,
      widget.scrollControllers.horizontalBodyController,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) => _shiftUsingOffsets());
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only( right: 32,bottom: 32,),
          child: Column(
            children: <Widget>[
              Row(
                textDirection: widget.tableDirection,
                children: <Widget>[
                  /// STICKY LEGEND
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onStickyLegendPressed,
                    child: Container(
                      width: widget.cellDimensions.stickyLegendWidth,
                      height: widget.cellDimensions.stickyLegendHeight,
                      alignment: widget.cellAlignments.stickyLegendAlignment,
                      child: widget.legendCell,
                    ),
                  ),

                  /// STICKY ROW
                  Expanded(
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (notification) =>
                              _onHorizontalScrollingNotification(
                            notification: notification,
                            controller:
                                widget.scrollControllers.horizontalTitleController,
                          ),
                          child: Scrollbar(
                            key: Key('Row ${widget.showVerticalScrollbar}'),
                            thumbVisibility: widget.showVerticalScrollbar ?? false,
                            controller:
                                widget.scrollControllers.horizontalTitleController,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: widget.columnsTitlesTopLeftBorderRadius ??
                                      Radius.zero,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 4),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                    color: Color(0xff333333).withOpacity(0.12),
                                  )
                                ],
                              ),
                              child: SingleChildScrollView(
                                reverse: widget.tableDirection == TextDirection.rtl,
                                physics: widget.scrollPhysics.stickyRow,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  textDirection: widget.tableDirection,
                                  children: List.generate(
                                    widget.columnsLength,
                                    (i) => GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => widget.onColumnTitlePressed(i),
                                      child: Container(
                                        // decoration: BoxDecoration(
                                        //   border: Border(
                                        //     left: BorderSide(
                                        //       width: 1.0,
                                        //       color: Color(0xffE1E7EA),
                                        //     ),
                                        //   ),
                                        // ),
                                        key: globalRowTitleKeys[i] ??= GlobalKey(),
                                        width: widget.cellDimensions.stickyWidth(i),
                                        height:
                                            widget.cellDimensions.stickyLegendHeight,
                                        alignment:
                                            widget.cellAlignments.rowAlignment(i),
                                        child: widget.columnsTitleBuilder(i),
                                      ),
                                    ),
                                  ),
                                ),
                                controller: widget
                                    .scrollControllers.horizontalTitleController,
                              ),
                            ),
                          ),
                        ),
                        // if (widget.columnsTitlesLeftBorder != null)
                        //   Positioned.fill(
                        //     left: -1 * (widget.columnsTitlesLeftBorder?.width ?? 0),
                        //     child: DecoratedBox(
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.only(
                        //           topLeft: widget.columnsTitlesTopLeftBorderRadius ??
                        //               Radius.zero,
                        //         ),
                        //         border: Border(
                        //           left: widget.columnsTitlesLeftBorder!,
                        //         ),
                        //       ),
                        //     ),
                        //   ),

                      ],
                    ),
                  )
                ],
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: widget.tableDirection,
                  children: <Widget>[
                    /// STICKY COLUMN
                    Stack(
                      alignment: AlignmentDirectional.center,
                      clipBehavior: Clip.none,
                      children: [
                        NotificationListener<ScrollNotification>(
                          child: Scrollbar(
                            // Key is required to avoid 'The Scrollbar's ScrollController has no ScrollPosition attached.
                            key: Key('Column ${widget.showHorizontalScrollbar}'),
                            thumbVisibility: widget.showHorizontalScrollbar ?? false,
                            controller:
                                widget.scrollControllers.verticalBodyController,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(4, -4),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                    color: Color(0xff333333).withOpacity(0.12),
                                  )
                                ],
                              ),
                              child: SingleChildScrollView(
                                physics: widget.scrollPhysics.stickyColumn,
                                child: Column(
                                  children: List.generate(
                                    widget.rowsLength,
                                    (i) => GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => widget.onRowTitlePressed(i),
                                      child: Container(
                                        key: globalColumnTitleKeys[i] ??= GlobalKey(),
                                        width:
                                            widget.cellDimensions.stickyLegendWidth,
                                        height: widget.cellDimensions.stickyHeight(i),
                                        alignment:
                                            widget.cellAlignments.columnAlignment(i),
                                        child: widget.rowsTitleBuilder(i),
                                      ),
                                    ),
                                  ),
                                ),
                                controller:
                                    widget.scrollControllers.verticalTitleController,
                              ),
                            ),
                          ),
                          onNotification: (notification) =>
                              _onVerticalScrollingNotification(
                            notification: notification,
                            controller:
                                widget.scrollControllers.verticalTitleController,
                          ),
                        ),

                      ],
                    ),
                    // CONTENT
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        child: SingleChildScrollView(
                          reverse: widget.tableDirection == TextDirection.rtl,
                          physics: widget.scrollPhysics.contentHorizontal,
                          scrollDirection: Axis.horizontal,
                          controller:
                              widget.scrollControllers.horizontalBodyController,
                          child: NotificationListener<ScrollNotification>(
                            child: SingleChildScrollView(
                              physics: widget.scrollPhysics.contentVertical,
                              controller:
                                  widget.scrollControllers.verticalBodyController,
                              child: Column(
                                children: List.generate(
                                  widget.rowsLength,
                                  (int rowIdx) => Row(
                                    textDirection: widget.tableDirection,
                                    children: List.generate(
                                      widget.columnsLength,
                                      (int columnIdx) => GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => widget.onContentCellPressed(
                                            columnIdx, rowIdx),
                                        child: Container(
                                          width: widget.cellDimensions
                                              .contentSize(rowIdx, columnIdx)
                                              .width,
                                          height: widget.cellDimensions
                                              .contentSize(rowIdx, columnIdx)
                                              .height,
                                          alignment: widget.cellAlignments
                                              .contentAlignment(rowIdx, columnIdx),
                                          child: widget.contentCellBuilder(
                                              columnIdx, rowIdx),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onNotification: (notification) =>
                                _onVerticalScrollingNotification(
                              notification: notification,
                              controller:
                                  widget.scrollControllers.verticalBodyController,
                            ),
                          ),
                        ),
                        onNotification: (notification) =>
                            _onHorizontalScrollingNotification(
                          notification: notification,
                          controller:
                              widget.scrollControllers.horizontalBodyController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(valueListenable: showLeftCircleButton, builder: (context, value, child) {
          if(value) {
            return    Positioned(
              top: (widget.cellDimensions.stickyLegendHeight / 2) - 32,
              left: widget.cellDimensions.stickyLegendWidth - 32,
              child: GestureDetector(
                onTap: widget.onLeftCircleButtonPressed,
                // onTap: () => widget
                //     .scrollControllers.horizontalBodyController
                //     .animateTo(
                //   widget.scrollControllers.horizontalBodyController
                //       .offset -
                //       (widget.cellDimensions.contentCellWidth ?? 0),
                //   duration: const Duration(milliseconds: 50),
                //   curve: Curves.easeInOut,
                // ),
                child: _ArrowCircle(),
              ),
            );
          }

          return SizedBox.shrink();
        }),

        ValueListenableBuilder<bool>(valueListenable: showRightCircleButton, builder: (context, value, child) {
          if(value){
            return Positioned(
              right: 0,
              child: GestureDetector(
                onTap: widget.onRightCircleButtonPressed,
                // onTap: () => widget
                //     .scrollControllers.horizontalBodyController
                //     .animateTo(
                //   widget.scrollControllers.horizontalBodyController
                //       .offset +
                //       (widget.cellDimensions.contentCellWidth ?? 0),
                //   duration: const Duration(milliseconds: 50),
                //   curve: Curves.easeInOut,
                // ),
                child: _ArrowCircle(),
              ),
            );
          }

          return SizedBox.shrink();
        }),

        ValueListenableBuilder<bool>(valueListenable: showTopCircleButton, builder: (context, value, child) {
          if(value) {
            return Positioned(
              top: widget.cellDimensions.stickyLegendHeight - 32,
              left: (widget.cellDimensions.stickyLegendWidth / 2) - 32,
              child: GestureDetector(
                onTap: widget.onTopCircleButtonPressed,
                // onTap: () => widget
                //     .scrollControllers.verticalBodyController
                //     .animateTo(
                //   widget.scrollControllers.verticalBodyController
                //       .offset -
                //       (widget.cellDimensions.contentCellHeight ?? 0),
                //   duration: const Duration(milliseconds: 50),
                //   curve: Curves.easeInOut,
                // ),
                child: _ArrowCircle(),
              ),
            );
          }
          return SizedBox.shrink();
        }),

        ValueListenableBuilder<bool>(valueListenable: showBottomCircleButton, builder: (context, value, child) {
          if(value) {
            return Positioned(
              bottom: 0,
              left: (widget.cellDimensions.stickyLegendWidth / 2) - 32,
              child: GestureDetector(
                onTap: widget.onBottomCircleButtonPressed,
                // onTap: () => widget
                //     .scrollControllers.verticalBodyController
                //     .animateTo(
                //   widget.scrollControllers.verticalBodyController
                //       .offset +
                //       (widget.cellDimensions.contentCellHeight ?? 0),
                //   duration: const Duration(milliseconds: 50),
                //   curve: Curves.easeInOut,
                // ),
                child: _ArrowCircle(),
              ),
            );
          }
          return SizedBox.shrink();
        }),

      ],
    );
  }
}

class _ArrowCircle extends StatelessWidget {
  const _ArrowCircle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 0,
                color: Color(0xff333333).withOpacity(0.12),
              )
            ]),
        child: Icon(Icons.circle),
      ),
    );
  }
}

/// SyncScrollController keeps scroll controllers in sync.
class _SyncScrollController {
  _SyncScrollController(
    this._titleController,
    this._bodyController,
  );

  final ScrollController _titleController;
  final ScrollController _bodyController;

  ScrollController? _scrollingController;
  bool _scrollingActive = false;

  /// Returns true if reached scroll end
  bool processNotification(
    ScrollNotification notification,
    ScrollController controller, {
    Function(double x, double y)? onEndScrolling,
  }) {
    if (notification is ScrollStartNotification && !_scrollingActive) {
      _scrollingController = controller;
      _scrollingActive = true;
      return false;
    }

    if (identical(controller, _scrollingController) && _scrollingActive) {
      if (notification is ScrollEndNotification) {
        _scrollingController = null;
        _scrollingActive = false;
        return true;
      }

      if (notification is ScrollUpdateNotification) {
        for (final controller in [_titleController, _bodyController]) {
          if (identical(_scrollingController, controller)) continue;
          if (controller.positions.isEmpty) continue;
          final offset = _scrollingController?.offset;
          if (offset != null) {
            controller.jumpTo(offset);
          }
        }
      }
    }
    return false;
  }
}
