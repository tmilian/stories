import 'package:flutter/widgets.dart';
import 'package:stories/src/controller/story_controller.dart';
import 'package:stories/src/model/story_page.dart';
import 'package:stories/src/widgets/story_image.dart';
import 'package:stories/src/widgets/story_video.dart';

class StoryItem {
  final ChildBuilder builder;
  final Duration duration;
  bool shown;
  final StoryController controller;

  StoryItem({
    required this.builder,
    StoryController? controller,
    this.duration = const Duration(seconds: 10),
    this.shown = false,
  }) : controller = controller ?? StoryController(duration: duration);

  static StoryItem networkImage({
    required String url,
    Key? key,
    BoxFit fit = BoxFit.fitWidth,
    String? cacheKey,
    bool shown = false,
    Map<String, String>? requestHeaders,
    Duration duration = const Duration(seconds: 5),
  }) {
    var controller = StoryController(duration: duration);
    return StoryItem(
      builder: (context) => StoryImage(
        key: key,
        url: url,
        cacheKey: cacheKey,
        controller: controller,
        fit: fit,
        headers: requestHeaders,
      ),
      shown: shown,
      duration: duration,
      controller: controller,
    );
  }

  static StoryItem networkVideo({
    Key? key,
    required String url,
    BoxFit fit = BoxFit.fitWidth,
    String? cacheKey,
    bool shown = false,
    Map<String, String>? requestHeaders,
    Duration duration = const Duration(seconds: 5),
  }) {
    var controller = StoryController(duration: duration);
    return StoryItem(
      builder: (context) => StoryVideo(
        key: key,
        url: url,
        cacheKey: cacheKey,
        controller: controller,
        fit: fit,
        headers: requestHeaders,
      ),
      shown: shown,
      duration: duration,
      controller: controller,
    );
  }
}
