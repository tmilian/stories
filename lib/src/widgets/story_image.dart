import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:stories/src/controller/story_controller.dart';

class StoryImage extends StatefulWidget {
  const StoryImage({
    Key? key,
    required this.url,
    required this.fit,
    required this.controller,
    this.cacheKey,
    this.headers,
  }) : super(key: key);

  final String url;
  final BoxFit fit;
  final StoryController controller;
  final String? cacheKey;
  final Map<String, String>? headers;

  @override
  State<StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<StoryImage> {
  late StoryController _storyController;

  @override
  void initState() {
    super.initState();
    _storyController = widget.controller;
    _setListeners();
  }

  @override
  void didUpdateWidget(covariant StoryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _storyController = widget.controller;
    _setListeners();
  }

  void _setListeners() {
    _storyController.preCache.listen((value) {
      if (!mounted) return;
      switch (value) {
        case PreCacheState.start:
          precacheImage(
            CachedNetworkImageProvider(widget.url, cacheKey: widget.cacheKey),
            context,
          );
          break;
        case PreCacheState.stop:
          break;
      }
    });
    _storyController.playController.listen((value) {
      if (!mounted) return;
      switch (value) {
        case PlayControls.pause:
          _storyController.paused();
          break;
        case PlayControls.start:
          _storyController.playing();
          break;
        case PlayControls.play:
          _storyController.playing();
          break;
        case PlayControls.stop:
          _storyController.paused();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.url,
      cacheKey: widget.cacheKey ?? widget.url,
      fit: widget.fit,
      httpHeaders: widget.headers,
    );
  }
}
