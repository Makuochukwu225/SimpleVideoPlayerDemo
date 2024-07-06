import 'dart:async';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _pageController = PageController();
  List<CachedVideoPlayerPlusController> _controllers = [];
  List<String> videoUrls = [
    "https://streamlivr-bucket.s3.us-west-2.amazonaws.com/stream_videos/17_9ZGZWID?AWSAccessKeyId=AKIA2AIQSY3EPY3HICOL&Signature=RwOH0JWyLgKA6Is%2BUOLQIO2JHeU%3D&Expires=1720269618",
    "https://res.cloudinary.com/dk39yn5ll/video/upload/v1720084701/JAXLAB/qif6wnw1wla8fxpnyqic.mp4",
    "https://res.cloudinary.com/dk39yn5ll/video/upload/v1719917273/JAXLAB/hjd4c3hjqkbapcrazael.mp4",
    "https://res.cloudinary.com/dk39yn5ll/video/upload/v1720260430/JAXLAB/nxe1stthdlj28lmspikx.mp4",
    "https://res.cloudinary.com/dk39yn5ll/video/upload/v1720260796/JAXLAB/pibd57texaeov9icnvr0.mp4",
    "https://firebasestorage.googleapis.com/v0/b/fir-messaging-43a48.appspot.com/o/fifth.mp4?alt=media&token=e6a15d70-9b30-4f2c-a33a-4255faadcc6c",
    "https://firebasestorage.googleapis.com/v0/b/fir-messaging-43a48.appspot.com/o/fist.mp4?alt=media&token=74418f91-4fe5-4e9c-8ac9-8c610a6d7cee",
    "https://firebasestorage.googleapis.com/v0/b/fir-messaging-43a48.appspot.com/o/fourth.mp4?alt=media&token=ece2051d-02af-422d-be46-215b0285c25e",
    "https://firebasestorage.googleapis.com/v0/b/fir-messaging-43a48.appspot.com/o/jappa.mp4?alt=media&token=c859625a-8c82-4c1a-8f9a-03d84febc6e5",
    "https://firebasestorage.googleapis.com/v0/b/fir-messaging-43a48.appspot.com/o/queen.mp4?alt=media&token=41ba0f75-d0d5-453c-bf98-1e9fb7cd0d83",
    "https://firebasestorage.googleapis.com/v0/b/fir-messaging-43a48.appspot.com/o/second.mp4?alt=media&token=aa7a0136-2164-4574-9b7f-1861a8168071",
    "https://firebasestorage.googleapis.com/v0/b/fir-messaging-43a48.appspot.com/o/third.mp4?alt=media&token=d668a23d-2b25-4540-a1e8-3bd04825b488",
    // Add more video URLs here
  ];
  int index = 0;

  @override
  void initState() {
    super.initState();
    for (String url in videoUrls) {
      _controllers.add(CachedVideoPlayerPlusController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions()));
    }

    _initializeVideo(0);

    _pageController.addListener(_pageListener);
  }

  void _pageListener() {
    int newIndex = _pageController.page!.round();
    if (index != newIndex) {
      _controllers[index].pause();
      setState(() {
        index = newIndex;
      });
      _initializeVideo(index);
      // Preload the next video if it exists
      if (index + 1 < _controllers.length) {
        _initializeVideo(index + 1);
      }
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (!_controllers[index].value.isInitialized) {
      try {
        await _controllers[index].initialize();
        if (this.index == index) {
          _controllers[index].play();
        }
      } catch (error) {
        print("Error initializing video at index $index: $error");
      }
    } else {
      // If the video is already initialized, play it directly
      if (this.index == index) {
        _controllers[index].play();
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    for (CachedVideoPlayerPlusController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _controllers.length,
          itemBuilder: (context, index) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: AspectRatio(
                aspectRatio: _controllers[index].value.aspectRatio,
                child: InkWell(
                  onTap: () {
                    var current = _controllers[index];
                    if (current.value.isPlaying) {
                      current.pause();
                    } else {
                      current.play();
                    }
                  },
                  child: CachedVideoPlayerPlus(
                      key: ValueKey(_controllers[index]), _controllers[index]),
                ),
              ),
            );
          },
        ));
  }
}
