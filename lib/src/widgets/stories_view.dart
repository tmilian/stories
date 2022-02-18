import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stories/src/extension.dart';
import 'package:stories/src/model/story_page.dart';
import 'package:stories/src/widgets/story_view.dart';

class StoriesView extends StatefulWidget {
  const StoriesView({
    Key? key,
    required this.storyPages,
    this.preCache = true,
    this.preCacheCount = 2,
    this.indicatorHeight = 5,
    this.indicatorSpacing = 5,
    this.indicatorPadding = const EdgeInsets.all(10),
    this.indicatorColor = const Color.fromRGBO(255, 255, 255, 1),
    this.onComplete,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 1),
  }) : super(key: key);

  final List<StoryPage> storyPages;
  final bool preCache;
  final int preCacheCount;
  final double indicatorHeight;
  final double indicatorSpacing;
  final EdgeInsets indicatorPadding;
  final Color indicatorColor;
  final VoidCallback? onComplete;
  final Color backgroundColor;

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  final PageController _controller = PageController(keepPage: false);
  final _ignorePointer = BehaviorSubject<bool>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: widget.backgroundColor,
      child: StreamBuilder<bool>(
          stream: _ignorePointer.stream,
          builder: (context, snapshot) {
            return PageView.builder(
              controller: _controller,
              physics: snapshot.data == true
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                var storyPage = widget.storyPages[index];
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double value = !_controller.position.haveDimensions
                        ? index.toDouble()
                        : _controller.page ?? 0;
                    final isLeaving = (index - value) <= 0;
                    final t = (index - value);
                    final rotationY = lerpDouble(0, 90, t) ?? 0;
                    final opacity =
                        lerpDouble(0, 1, t.abs())?.clamp(0.0, 1.0) ?? 1;
                    final transform = Matrix4.identity();
                    transform.setEntry(3, 2, 0.001);
                    transform.rotateY(-degToRad(rotationY));
                    return Transform(
                      alignment: isLeaving
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      transform: transform,
                      child: Stack(
                        children: [
                          IgnorePointer(
                            ignoring: opacity != 0,
                            child: child ?? Container(),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  color: const Color.fromRGBO(0, 0, 0, 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: StoryView(
                    storyPage: storyPage,
                    index: index,
                    preCache: widget.preCache,
                    preCacheCount: widget.preCacheCount,
                    indicatorHeight: widget.indicatorHeight,
                    indicatorSpacing: widget.indicatorSpacing,
                    indicatorPadding: widget.indicatorPadding,
                    indicatorColor: widget.indicatorColor,
                    onNextPage: () async {
                      var currentIndex = _controller.page?.toInt() ?? 0;
                      if (currentIndex == widget.storyPages.length - 1) {
                        widget.onComplete?.call();
                      } else {
                        _ignorePointer.add(true);
                        await _controller.animateToPage(
                          currentIndex + 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                        _ignorePointer.add(false);
                      }
                    },
                    onPreviousPage: () async {
                      var currentIndex = _controller.page?.toInt() ?? 0;
                      var previousIndex = (currentIndex - 1).min(0);
                      _ignorePointer.add(true);
                      await _controller.animateToPage(
                        previousIndex,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      _ignorePointer.add(false);
                    },
                    backgroundColor: widget.backgroundColor,
                  ),
                );
              },
              itemCount: widget.storyPages.length,
            );
          }),
    );
  }
}

double degToRad(double deg) => deg * (pi / 180.0);
