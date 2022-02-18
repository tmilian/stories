import 'package:better_player/better_player.dart';
import 'package:flutter/widgets.dart';
import 'package:stories/src/controller/story_controller.dart';

class StoryVideo extends StatefulWidget {
  const StoryVideo({
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
  State<StoryVideo> createState() => _StoryVideoState();
}

class _StoryVideoState extends State<StoryVideo> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerDataSource _betterPlayerDataSource;
  late StoryController _storyController;

  @override
  void initState() {
    super.initState();
    _storyController = widget.controller;
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 10 * 1024 * 1024,
        maxCacheSize: 50 * 1024 * 1024,
        maxCacheFileSize: 50 * 1024 * 1024,
        key: widget.cacheKey,
      ),
    );
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        autoDispose: false,
        fit: widget.fit,
      ),
      betterPlayerDataSource: _betterPlayerDataSource,
    );
    _setListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }

  void _setListeners() {
    _storyController.preCache.listen((value) async {
      if (!mounted) return;
      switch (value) {
        case PreCacheState.start:
          // TODO: Manage video pre caching
          // _betterPlayerController.setupDataSource(_betterPlayerDataSource);
          // _betterPlayerController.preCache(_betterPlayerDataSource);
          break;
        case PreCacheState.stop:
          // TODO: Manage video pre caching
          // _betterPlayerController.stopPreCache(_betterPlayerDataSource);
          break;
      }
    });
    _storyController.playController.listen((value) async {
      if (!mounted) return;
      if (_betterPlayerController.videoPlayerController?.value.initialized !=
          true) return;
      switch (value) {
        case PlayControls.pause:
          _betterPlayerController.pause();
          return;
        case PlayControls.start:
          await _betterPlayerController.seekTo(Duration.zero);
          _betterPlayerController.play();
          return;
        case PlayControls.play:
          _betterPlayerController.play();
          break;
        case PlayControls.stop:
          _betterPlayerController.pause();
          await _betterPlayerController.seekTo(Duration.zero);
      }
    });
    _betterPlayerController.addEventsListener((event) async {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        _storyController.duration =
            _betterPlayerController.videoPlayerController?.value.duration ??
                _storyController.duration;
        if ([PlayControls.play, PlayControls.start]
                .contains(_storyController.playController.valueOrNull) &&
            _betterPlayerController.isPlaying() != true) {
          await _betterPlayerController.seekTo(Duration.zero);
          _betterPlayerController.play();
        }
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        _storyController.playing();
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
        _storyController.paused();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _storyController.visibility.stream,
      builder: (context, snapshot) {
        var visible = snapshot.data;
        if (visible != true) {
          return Container();
        }
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        );
      },
    );
  }
}
