import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:stories/src/controller/story_controller.dart';
import 'package:stories/src/extension.dart';
import 'package:stories/src/model/story_item.dart';
import 'package:stories/src/model/story_page.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StoryView extends StatefulWidget {
  const StoryView({
    Key? key,
    required this.storyPage,
    this.index = 0,
    this.preCache = true,
    this.preCacheCount = 2,
    this.indicatorHeight = 5,
    this.indicatorSpacing = 5,
    this.indicatorPadding = const EdgeInsets.all(10),
    this.indicatorColor = const Color.fromRGBO(255, 255, 255, 1),
    this.onNextPage,
    this.onPreviousPage,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 1),
  }) : super(key: key);

  final StoryPage storyPage;
  final bool preCache;
  final int preCacheCount;
  final double indicatorHeight;
  final double indicatorSpacing;
  final EdgeInsets indicatorPadding;
  final Color indicatorColor;
  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;
  final Color backgroundColor;
  final int index;

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  late PageController _pageController;

  List<StoryItem> _items = [];
  ChildBuilder? _builder;
  AnimationController? _animationController;
  Animation<double>? _indicatorAnimation;
  StreamSubscription? _playStateSubscription;
  bool _visible = false;

  int get index => _pageController.positions.isNotEmpty &&
          _pageController.position.haveDimensions
      ? _pageController.page?.toInt() ?? 0
      : _pageController.initialPage;

  @override
  void initState() {
    super.initState();
    _items = widget.storyPage.items;
    _builder = widget.storyPage.builder;
    final firstItem = _items.firstWhereOrNull((it) => !it.shown);
    var index = firstItem != null ? _items.indexOf(firstItem) : 0;
    _items = _items.sublist(0, index) +
        _items.sublist(index).map((e) {
          e.shown = false;
          return e;
        }).toList();
    _pageController = PageController(initialPage: index);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('story-view-${widget.index}'),
      onVisibilityChanged: (info) {
        var visiblePercentage = info.visibleFraction * 100;
        if (visiblePercentage == 100 && !_visible) {
          _visible = true;
          _startStories();
        } else if (visiblePercentage < 100 && _visible) {
          _visible = false;
          _stopStories();
        }
      },
      child: Container(
        color: widget.backgroundColor,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) {
                return VisibilityDetector(
                  key: Key('story-item-view-$index'),
                  onVisibilityChanged: (info) {},
                  child: _items[index].builder(ctx),
                );
              },
              itemCount: _items.length,
              allowImplicitScrolling: true,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: widget.indicatorPadding,
                  child: PageBar(
                    items: _items,
                    currentIndex: index,
                    animation:
                        _indicatorAnimation ?? AnimationController(vsync: this),
                    indicatorHeight: widget.indicatorHeight,
                    indicatorColor: widget.indicatorColor,
                    spacing: widget.indicatorSpacing,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _previous,
                      onLongPressDown: (details) => _pause(),
                      onLongPressEnd: (details) => _play(),
                      onPanEnd: (details) => _play(),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: _next,
                      onLongPressDown: (details) => _pause(),
                      onLongPressEnd: (details) => _play(),
                      onPanEnd: (details) => _play(),
                    ),
                  )
                ],
              ),
            ),
            if (_builder != null) _builder!.call(context),
          ],
        ),
      ),
    );
  }

  void _startStories() {
    _start();
    _items[index].shown = false;
    _items[index].controller.show();
  }

  void _stopStories() {
    _stop();
  }

  void _previous() async {
    await _removePlayStateSubscription();
    setState(() {
      var previousIndex = (index - 1).min(0);
      _items[index].controller.hide();
      _items[index].shown = false;
      if (index == previousIndex) {
        _stop();
        widget.onPreviousPage?.call();
      } else {
        _pageController.jumpToPage(previousIndex);
        _start();
        _items[previousIndex].shown = false;
        _items[previousIndex].controller.show();
      }
    });
  }

  void _next() async {
    await _removePlayStateSubscription();
    setState(() {
      var nextIndex = (index + 1).max(_items.length - 1);
      _items[index].controller.hide();
      _items[index].shown = true;
      if (index == nextIndex) {
        _stop();
        widget.onNextPage?.call();
      } else {
        _pageController.jumpToPage(nextIndex);
        _start();
        _items[nextIndex].shown = false;
        _items[nextIndex].controller.show();
      }
    });
  }

  void _resetPagingAnimation() {
    _animationController?.reset();
    _animationController?.dispose();
    _animationController = null;
  }

  void _initPagingAnimation() {
    _animationController = AnimationController(
      duration: _items[index].controller.duration,
      vsync: this,
    );
    _animationController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _next();
      }
    });
    _indicatorAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController!);
  }

  void _pause() {
    _items[index].controller.pause();
  }

  void _start() {
    _resetPagingAnimation();
    _manageCache();
    _setPlayStateSubscription();
    _items[index].controller.start();
  }

  void _play() {
    _items[index].controller.play();
  }

  void _stop() {
    _resetPagingAnimation();
    _stopCache();
    _items[index].controller.stop();
  }

  void _manageCache() {
    for (int i in List.generate(widget.preCacheCount, (index) => index + 1)) {
      if (index + i < _items.length) {
        _items[index + i].controller.startPreCache();
      }
    }
  }

  void _stopCache() {
    for (int i in List.generate(widget.preCacheCount, (idx) => idx + 1)) {
      if (index + i < _items.length && index - i > 0) {
        _items[index + i].controller.stopPreCache();
      }
    }
  }

  void _setPlayStateSubscription() {
    _playStateSubscription = _items[index].controller.playState.listen((value) {
      if (!mounted) return;
      switch (value) {
        case PlayState.loading:
          break;
        case PlayState.playing:
          if (_animationController == null) {
            setState(() {
              _initPagingAnimation();
            });
          }
          _animationController?.forward();
          break;
        case PlayState.paused:
          _animationController?.stop(canceled: false);
          break;
      }
    });
  }

  Future<void> _removePlayStateSubscription() async {
    await _playStateSubscription?.cancel();
  }
}

class PageBar extends StatelessWidget {
  final List<StoryItem> items;
  final Animation<double> animation;
  final int currentIndex;
  final double indicatorHeight;
  final Color indicatorColor;
  final double spacing;

  const PageBar({
    Key? key,
    required this.items,
    required this.animation,
    required this.currentIndex,
    required this.indicatorHeight,
    required this.indicatorColor,
    required this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.mapIndexed((index, e) {
        Widget child = StoryProgressIndicator(
          value: e.shown ? 1 : 0,
          indicatorHeight: 5,
          indicatorColor: indicatorColor,
        );
        if (index == currentIndex) {
          child = AnimatedBuilder(
            animation: animation,
            builder: (context, child) => StoryProgressIndicator(
              value: e.shown
                  ? 1
                  : index == currentIndex
                      ? animation.value
                      : 0,
              indicatorHeight: 5,
              indicatorColor: indicatorColor,
            ),
          );
        }
        return Expanded(
          child: Container(
            padding: EdgeInsets.only(
              right: items.last == e ? 0 : spacing,
            ),
            child: child,
          ),
        );
      }).toList(),
    );
  }
}

class StoryProgressIndicator extends StatelessWidget {
  final double value;
  final double indicatorHeight;
  final Color indicatorColor;

  const StoryProgressIndicator({
    Key? key,
    required this.value,
    required this.indicatorColor,
    this.indicatorHeight = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(indicatorHeight),
      ),
      child: CustomPaint(
        size: Size.fromHeight(indicatorHeight),
        foregroundPainter: IndicatorPainter(
          indicatorColor.withOpacity(0.8),
          value,
        ),
        painter: IndicatorPainter(
          indicatorColor.withOpacity(0.4),
          1.0,
        ),
      ),
    );
  }
}

class IndicatorPainter extends CustomPainter {
  final Color color;
  final double widthFactor;

  IndicatorPainter(this.color, this.widthFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * widthFactor, size.height),
        Radius.circular(size.height),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
