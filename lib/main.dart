import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(GetMaterialApp(
    home: const StoryPlayer(),
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
  ));
}

class StoryPlayer extends StatelessWidget {
  const StoryPlayer({super.key});

  @override
  Widget build(context) {
    final Controller c = Get.put(Controller());

    return Scaffold(
        appBar: AppBar(title: const Text("Stories")),
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
                child: const Text("Init"), onPressed: () => c.init()),
            ElevatedButton(
                child: const Text("Stop"), onPressed: () => c.stop()),
            ElevatedButton(
                child: const Text("Start"), onPressed: () => c.start()),
            ElevatedButton(
                child: const Text("Left Tap"), onPressed: () => c.leftTap()),
            ElevatedButton(
                child: const Text("Left Swipe"),
                onPressed: () => c.leftSwipe()),
            ElevatedButton(
                child: const Text("Right Swipe"),
                onPressed: () => c.rightSwipe()),
            ElevatedButton(
                child: const Text("Right Tap"), onPressed: () => c.rightTap()),
            Obx(() => Text(
                "Current Story Group Id: ${c.currentState["currentStoryGroupId"]!}")),
            Obx(() =>
                Text("Current Story Id: ${c.currentState["currentStoryId"]!}")),
            Obx(() => Text("Current Time: ${c.currentState["currentTime"]!}")),
            Obx(() => Text("Is Playing: ${c.currentState["isPlaying"]!}")),
            // Expanded(
            //   child: Obx(() => ListView.builder(
            //       itemCount: c.stories[c.currentState["currentStoryGroupId"]! as int].length,
            //       itemBuilder: (context, index) {
            //         final story = c.stories[c.currentState["currentStoryGroupId"]! as int][index];
            //         return Obx(() => AnimatedContainer(
            //               duration: Duration(milliseconds: 300),
            //               curve: Curves.easeInOut,
            //               height: c.currentState["currentStoryId"] == index ? 200 : 100,
            //               child: Image.network(story.url),
            //             ));
            //       })),
            // ),
          ],
        )));
  }
}

class Controller extends GetxController {
  final stopwatch = Stopwatch();
  Timer? timer;

  var stories = [
    [
      Story(
          StoryType.image,
          "https://imgv3.fotor.com/images/gallery/Spotify-Song-Instagram-Story.jpg",
          5 * 1000)
    ],
    [
      Story(
          StoryType.image,
          "https://images.unsplash.com/photo-1559583985-c80d8ad9b29f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxjb2xsZWN0aW9uLXBhZ2V8MXwxMDY1OTc2fHxlbnwwfHx8fHw%3D&w=1000&q=80",
          5 * 1000),
      Story(
          StoryType.image,
          "https://imgv3.fotor.com/images/gallery/Spotify-Song-Instagram-Story.jpg",
          5 * 1000)
    ],
    [
      Story(
          StoryType.image,
          "https://imgv3.fotor.com/images/gallery/Spotify-Song-Instagram-Story.jpg",
          5 * 1000)
    ],
  ].obs;
  var currentState = {
    "currentStoryGroupId": 0,
    "currentStoryId": 0,
    "currentTime": 0,
    "isPlaying": false,
  }.obs;

  var visitedStoriesIds = <int>[0, 0, 0].obs;

  init() {
    if (timer != null) {
      return;
    }
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentState["currentTime"] = stopwatch.elapsedMilliseconds;
      // if current story duration exceeds change story
      if ((currentState["currentTime"] as int) >=
          stories[currentState["currentStoryGroupId"]! as int]
                  [currentState["currentStoryId"]! as int]
              .duration) {
        rightTap();
        stopwatch.reset();
      }
    });
  }

  stop() {
    currentState["isPlaying"] = false;
    stopwatch.stop();
  }

  start() {
    currentState["isPlaying"] = true;
    stopwatch.start();
  }

  leftTap() {
    if (currentState["currentStoryId"] == 0) {
      if (currentState["currentStoryGroupId"] == 0) {
        return;
      } else {
        currentState["currentStoryGroupId"] =
            (currentState["currentStoryGroupId"]! as int) - 1;
        currentState["currentStoryId"] =
            stories[currentState["currentStoryGroupId"]! as int].length - 1;
      }
    } else {
      currentState["currentStoryId"] =
          (currentState["currentStoryId"]! as int) - 1;
    }
    visitedStoriesIds[currentState["currentStoryGroupId"]! as int] =
        currentState["currentStoryId"]! as int;
    stopwatch.reset();
  }

  rightTap() {
    if (currentState["currentStoryId"] ==
        stories[currentState["currentStoryGroupId"]! as int].length - 1) {
      if (currentState["currentStoryGroupId"] == stories.length - 1) {
        return;
      } else {
        currentState["currentStoryGroupId"] =
            (currentState["currentStoryGroupId"]! as int) + 1;
        currentState["currentStoryId"] = 0;
      }
    } else {
      currentState["currentStoryId"] =
          (currentState["currentStoryId"]! as int) + 1;
    }
    visitedStoriesIds[currentState["currentStoryGroupId"]! as int] =
        currentState["currentStoryId"]! as int;
    stopwatch.reset();
  }

  leftSwipe() {
    if (currentState["currentStoryGroupId"] == 0) {
      return;
    } else {
      currentState["currentStoryGroupId"] =
          (currentState["currentStoryGroupId"]! as int) - 1;
      currentState["currentStoryId"] =
          visitedStoriesIds[currentState["currentStoryGroupId"]! as int];
    }
    stopwatch.reset();
  }

  rightSwipe() {
    if (currentState["currentStoryGroupId"] == stories.length - 1) {
      return;
    } else {
      currentState["currentStoryGroupId"] =
          (currentState["currentStoryGroupId"]! as int) + 1;
      currentState["currentStoryId"] =
          visitedStoriesIds[currentState["currentStoryGroupId"]! as int];
    }
    stopwatch.reset();
  }
}

class Story {
  final StoryType type;
  final String url;
  final double duration;

  Story(this.type, this.url, this.duration);
}

enum StoryType {
  image,
  video,
}
