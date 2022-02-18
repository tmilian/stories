import 'package:flutter/widgets.dart';
import 'package:stories/src/model/story_item.dart';

typedef ChildBuilder<T> = Widget Function(BuildContext context);

class StoryPage {
  final List<StoryItem> items;
  final ChildBuilder? builder;

  StoryPage({required this.items, this.builder});
}
