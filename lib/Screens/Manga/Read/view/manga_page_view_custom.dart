import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
enum MangaPageViewMode { continuous, paged }
enum MangaPageViewDirection {
  up,
  down,
  left,
  right;
  Axis get axis =>
      (this == MangaPageViewDirection.up || this == MangaPageViewDirection.down)
      ? Axis.vertical
      : Axis.horizontal;
  bool get reversed =>
      (this == MangaPageViewDirection.up ||
      this == MangaPageViewDirection.left);
}
class EdgeDragInfo {
  final bool isTriggered;
  EdgeDragInfo({required this.isTriggered});
}
class MangaPageViewOptions {
  final bool mainAxisOverscroll;
  final bool crossAxisOverscroll;
  final double minZoomLevel;
  final double maxZoomLevel;
  final double pageWidthLimit;
  final double edgeIndicatorContainerSize;
  final bool zoomOvershoot;
  final Size initialPageSize;
  final int precacheAhead;
  final int precacheBehind;
  const MangaPageViewOptions({
    this.mainAxisOverscroll = false,
    this.crossAxisOverscroll = false,
    this.minZoomLevel = 1.0,
    this.maxZoomLevel = 8.0,
    this.pageWidthLimit = double.infinity,
    this.edgeIndicatorContainerSize = 240,
    this.zoomOvershoot = true,
    this.initialPageSize = const Size(300, 300),
    this.precacheAhead = 0,
    this.precacheBehind = 0,
  });
}
class MangaPageViewController {
  PreloadPageController? pagedController;
  ItemScrollController? continuousController;
  final List<void Function(int)> _listeners = [];
  void addPageChangeListener(void Function(int) listener) {
    _listeners.add(listener);
  }
  void notifyPageChange(int index) {
    for (final listener in _listeners) {
      listener(index);
    }
  }
  void moveToPage(
    int page, {
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (pagedController != null && pagedController!.hasClients) {
      pagedController!.animateToPage(page, duration: duration, curve: curve);
    }
    if (continuousController != null) {
      continuousController!.scrollTo(
        index: page,
        duration: duration,
        curve: curve,
      );
    }
  }
  void jumpToPage(int page) {
    if (pagedController != null && pagedController!.hasClients) {
      pagedController!.jumpToPage(page);
    }
    if (continuousController != null) {
      continuousController!.jumpTo(index: page);
    }
  }
  void dispose() {
    _listeners.clear();
  }
}
class MangaPageView extends StatefulWidget {
  final int pageCount;
  final MangaPageViewController controller;
  final MangaPageViewMode mode;
  final MangaPageViewOptions options;
  final void Function(int) onPageChange;
  final MangaPageViewDirection direction;
  final Widget Function(BuildContext, int) pageBuilder;
  final Widget Function(BuildContext, EdgeDragInfo)?
  startEdgeDragIndicatorBuilder;
  final Widget Function(BuildContext, EdgeDragInfo)?
  endEdgeDragIndicatorBuilder;
  final VoidCallback? onStartEdgeDrag;
  final VoidCallback? onEndEdgeDrag;
  final VoidCallback? onTap;
  const MangaPageView({
    super.key,
    required this.pageCount,
    required this.controller,
    required this.mode,
    required this.options,
    required this.onPageChange,
    required this.direction,
    required this.pageBuilder,
    this.startEdgeDragIndicatorBuilder,
    this.endEdgeDragIndicatorBuilder,
    this.onStartEdgeDrag,
    this.onEndEdgeDrag,
    this.onTap,
  });
  @override
  State<MangaPageView> createState() => _MangaPageViewState();
}
class _MangaPageViewState extends State<MangaPageView>
    with TickerProviderStateMixin {
  late PhotoViewController _photoViewController;
  late PhotoViewScaleStateController _photoViewScaleStateController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _animation;
  final List<double> _doubleTapScales = [1.0, 2.0];
  Alignment _scalePosition = Alignment.center;
  bool _isCtrlPressed = false;
  Offset? _lastTapPosition;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener _scrollOffsetListener =
      ScrollOffsetListener.create();
  late PreloadPageController _preloadPageController;
  int _internalCurrentPage = 0;
  double _dragOffset = 0.0;
  bool _isTriggered = false;
  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _photoViewScaleStateController = PhotoViewScaleStateController();
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(curve: Curves.ease, parent: _scaleAnimationController),
    );
    _animation.addListener(() {
      _photoViewController.scale = _animation.value;
    });
    _preloadPageController = PreloadPageController(
      initialPage: _internalCurrentPage,
    );
    widget.controller.pagedController = _preloadPageController;
    widget.controller.continuousController = _itemScrollController;
    _itemPositionsListener.itemPositions.addListener(_onPositionsChanged);
  }
  @override
  void didUpdateWidget(MangaPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.pagedController = _preloadPageController;
    widget.controller.continuousController = _itemScrollController;
  }
  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    _photoViewController.dispose();
    _photoViewScaleStateController.dispose();
    _scaleAnimationController.dispose();
    _preloadPageController.dispose();
    _itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }
  void _onPositionsChanged() {
    if (widget.mode != MangaPageViewMode.continuous) return;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final firstItemPosition = positions.firstWhere(
      (pos) => pos.index == 0,
      orElse: () => positions.first,
    );
    final lastItemPosition = positions.firstWhere(
      (pos) => pos.index == widget.pageCount - 1,
      orElse: () => positions.first,
    );
    final isAtStart =
        firstItemPosition.index == 0 &&
        firstItemPosition.itemLeadingEdge >= -0.01;
    final isAtEnd =
        lastItemPosition.index == widget.pageCount - 1 &&
        lastItemPosition.itemTrailingEdge <= 1.01;
    ItemPosition? mostVisibleItem;
    if (isAtStart) {
      mostVisibleItem = firstItemPosition;
    } else if (isAtEnd) {
      mostVisibleItem = lastItemPosition;
    } else {
      double minDistance = double.infinity;
      for (final position in positions) {
        final leadingEdge = position.itemLeadingEdge;
        final trailingEdge = position.itemTrailingEdge;
        final itemCenter = (leadingEdge + trailingEdge) / 2;
        final distance = (itemCenter - 0.5).abs();
        if (distance < minDistance) {
          minDistance = distance;
          mostVisibleItem = position;
        }
      }
    }
    if (mostVisibleItem == null) return;
    final index = mostVisibleItem.index;
    if (index != _internalCurrentPage) {
      _internalCurrentPage = index;
      widget.onPageChange(index);
      widget.controller.notifyPageChange(index);
    }
  }
  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight ||
          event.logicalKey == LogicalKeyboardKey.metaLeft ||
          event.logicalKey == LogicalKeyboardKey.metaRight) {
        setState(() => _isCtrlPressed = true);
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight ||
          event.logicalKey == LogicalKeyboardKey.metaLeft ||
          event.logicalKey == LogicalKeyboardKey.metaRight) {
        setState(() => _isCtrlPressed = false);
      }
    }
    return false;
  }
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (_isCtrlPressed) {
        final delta = event.scrollDelta.dy;
        final currentScale = _photoViewController.scale ?? 1.0;
        final newScale = (currentScale - (delta * 0.002)).clamp(1.0, 8.0);
        if (newScale != currentScale) {
          _photoViewController.scale = newScale;
        }
      }
    }
  }
  Alignment _computeAlignmentByTapOffset(Offset offset) {
    final size = MediaQuery.sizeOf(context);
    return Alignment(
      (offset.dx - size.width / 2) / (size.width / 2),
      (offset.dy - size.height / 2) / (size.height / 2),
    );
  }
  void _toggleScale(Offset tapPosition) {
    if (mounted) {
      setState(() {
        if (_scaleAnimationController.isAnimating) {
          return;
        }
        final currentScale = _photoViewController.scale ?? 1.0;
        if (currentScale == _doubleTapScales[0]) {
          _scalePosition = _computeAlignmentByTapOffset(tapPosition);
          if (_scaleAnimationController.isCompleted) {
            _scaleAnimationController.reset();
          }
          _animation =
              Tween(
                begin: _doubleTapScales[0],
                end: _doubleTapScales[1],
              ).animate(
                CurvedAnimation(
                  curve: Curves.ease,
                  parent: _scaleAnimationController,
                ),
              );
          _scaleAnimationController.forward();
          return;
        }
        if (currentScale >= _doubleTapScales[1]) {
          _animation = Tween(begin: currentScale, end: _doubleTapScales[0])
              .animate(
                CurvedAnimation(
                  curve: Curves.ease,
                  parent: _scaleAnimationController,
                ),
              );
          if (_scaleAnimationController.isCompleted) {
            _scaleAnimationController.reset();
          }
          _scaleAnimationController.forward();
          return;
        }
        _photoViewScaleStateController.reset();
      });
    }
  }
  void _onScaleEnd(
    BuildContext context,
    ScaleEndDetails details,
    PhotoViewControllerValue controllerValue,
  ) {
    if (controllerValue.scale! < 1) {
      _photoViewScaleStateController.reset();
    }
  }
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification) {
      final overscroll = notification.overscroll;
      final isStart = overscroll < 0;
      final isEnd = overscroll > 0;
      if ((isStart && widget.onStartEdgeDrag != null) ||
          (isEnd && widget.onEndEdgeDrag != null)) {
        setState(() {
          _dragOffset += overscroll;
          final threshold = widget.options.edgeIndicatorContainerSize;
          _isTriggered = _dragOffset.abs() > threshold;
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_isTriggered) {
        if (_dragOffset < 0 && widget.onStartEdgeDrag != null) {
          widget.onStartEdgeDrag!();
        } else if (_dragOffset > 0 && widget.onEndEdgeDrag != null) {
          widget.onEndEdgeDrag!();
        }
      }
      setState(() {
        _dragOffset = 0.0;
        _isTriggered = false;
      });
    }
    return false;
  }
  Widget _buildPagedView() {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: PreloadPageView.builder(
        itemCount: widget.pageCount,
        controller: _preloadPageController,
        physics: const BouncingScrollPhysics(),
        scrollDirection: widget.direction.axis,
        reverse: widget.direction.reversed,
        onPageChanged: (index) {
          _internalCurrentPage = index;
          widget.onPageChange(index);
          widget.controller.notifyPageChange(index);
        },
        itemBuilder: (context, index) {
          return Center(
            child: SizedBox(
              width: widget.direction.axis == Axis.horizontal
                  ? (Platform.isAndroid || Platform.isIOS
                        ? double.infinity
                        : widget.options.pageWidthLimit)
                  : double.infinity,
              child: widget.pageBuilder(context, index),
            ),
          );
        },
      ),
    );
  }
  Widget _buildContinuousView() {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ScrollablePositionedList.builder(
        itemCount: widget.pageCount,
        itemScrollController: _itemScrollController,
        scrollOffsetController: _scrollOffsetController,
        itemPositionsListener: _itemPositionsListener,
        scrollOffsetListener: _scrollOffsetListener,
        physics: const BouncingScrollPhysics(),
        scrollDirection: widget.direction.axis,
        reverse: widget.direction.reversed,
        itemBuilder: (context, index) {
          return Center(
            child: SizedBox(
              width: Platform.isAndroid || Platform.isIOS
                  ? double.infinity
                  : widget.options.pageWidthLimit,
              child: widget.pageBuilder(context, index),
            ),
          );
        },
      ),
    );
  }
  Widget _buildEdgeIndicator() {
    final isStart = _dragOffset < 0;
    final builder = isStart
        ? widget.startEdgeDragIndicatorBuilder
        : widget.endEdgeDragIndicatorBuilder;
    if (builder == null) return const SizedBox.shrink();
    final info = EdgeDragInfo(isTriggered: _isTriggered);
    final indicator = builder(context, info);
    final isHorizontal = widget.direction.axis == Axis.horizontal;
    return Positioned(
      left: isHorizontal ? (isStart ? 0 : null) : 0,
      right: isHorizontal ? (isStart ? null : 0) : 0,
      top: isHorizontal ? 0 : (isStart ? 0 : null),
      bottom: isHorizontal ? 0 : (isStart ? null : 0),
      width: isHorizontal
          ? widget.options.edgeIndicatorContainerSize
          : MediaQuery.sizeOf(context).width,
      height: isHorizontal
          ? MediaQuery.sizeOf(context).height
          : widget.options.edgeIndicatorContainerSize,
      child: Center(
        child: Container(color: Colors.black54, child: indicator),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: 1,
            builder: (_, e) => PhotoViewGalleryPageOptions.customChild(
              controller: _photoViewController,
              scaleStateController: _photoViewScaleStateController,
              basePosition: _scalePosition,
              minScale: PhotoViewComputedScale.contained * 1.0,
              maxScale: PhotoViewComputedScale.covered * 8.0,
              onScaleEnd: _onScaleEnd,
              gestureDetectorBehavior: HitTestBehavior.translucent,
              child: GestureDetector(
                onTap: widget.onTap,
                onTapDown: (details) =>
                    _lastTapPosition = details.globalPosition,
                onDoubleTapDown: (details) =>
                    _toggleScale(details.globalPosition),
                onDoubleTap: () {},
                child: widget.mode == MangaPageViewMode.continuous
                    ? _buildContinuousView()
                    : _buildPagedView(),
              ),
            ),
            scrollPhysics: const NeverScrollableScrollPhysics(),
            enableRotation: false,
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
          if (_dragOffset.abs() > 0) _buildEdgeIndicator(),
        ],
      ),
    );
  }
}
