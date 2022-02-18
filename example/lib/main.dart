import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:stories/stories.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _images = [
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg'
  ];

  final List<String> _videos = [
    'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoriesView(
        storyPages: List.generate(4, (index) => index + 1).map((e) {
          var medias = ((_images..shuffle()).getRange(0, 3).toList() +
              (_videos..shuffle()).getRange(0, 3).toList());
          return StoryPage(
            items: medias.map((e) {
              var mime = lookupMimeType(e);
              if (mime?.contains("image") == true) {
                return StoryItem.networkImage(url: e);
              } else if (mime?.contains("video") == true) {
                return StoryItem.networkVideo(url: e);
              } else {
                return StoryItem(builder: (ctx) => Container());
              }
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
