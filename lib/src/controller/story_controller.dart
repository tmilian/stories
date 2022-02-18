import 'package:rxdart/rxdart.dart';

enum PlayControls { start, play, pause, stop }

enum PlayState { loading, playing, paused }

enum PreCacheState { start, stop }

class StoryController {
  final playController = BehaviorSubject<PlayControls>();
  final playState = BehaviorSubject<PlayState>();
  final visibility = BehaviorSubject<bool>();
  final preCache = BehaviorSubject<PreCacheState>();
  Duration duration;

  StoryController({this.duration = const Duration(seconds: 5)});

  void startPreCache() {
    if (preCache.isClosed) return;
    preCache.add(PreCacheState.start);
  }

  void stopPreCache() {
    if (preCache.isClosed) return;
    preCache.add(PreCacheState.stop);
  }

  void start() {
    if (playController.isClosed) return;
    playController.add(PlayControls.start);
  }

  void play() {
    if (playController.isClosed) return;
    playController.add(PlayControls.play);
  }

  void pause() {
    if (playController.isClosed) return;
    playController.add(PlayControls.pause);
  }

  void stop() {
    if (playController.isClosed) return;
    playController.add(PlayControls.stop);
  }

  void loading() {
    if (playState.isClosed) return;
    playState.add(PlayState.playing);
  }

  void playing() {
    if (playState.isClosed) return;
    playState.add(PlayState.playing);
  }

  void paused() {
    if (playState.isClosed) return;
    playState.add(PlayState.paused);
  }

  void show() {
    if (visibility.isClosed) return;
    visibility.add(true);
  }

  void hide() {
    if (visibility.isClosed) return;
    visibility.add(false);
  }

  void dispose() {
    playController.close();
    playState.close();
    visibility.close();
    preCache.close();
  }
}
