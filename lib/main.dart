import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const GetMaterialApp(
    home: StoryPlayer(),
  ));
}

class StoryPlayer extends StatefulWidget {
  const StoryPlayer({super.key});

  @override
  State<StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<StoryPlayer> {
  late CarouselSliderController _sliderController;
  int currentPage = 0;
  final Controller c = Get.put(Controller());
  int lastTapTime = 0;

  @override
  void initState() {
    super.initState();
    _sliderController = CarouselSliderController();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      c.currentState["currentTime"] = c.stopwatch.elapsedMilliseconds;
      // if current story duration exceeds change story
      if ((c.currentState["currentTime"] as int) >=
          c
              .stories[c.currentStoryGroupId.value]
                  [c.currentState["currentStoryId"]! as int]
              .duration) {
        bool res = c.rightTap();
        if (res) _sliderController.nextPage();
        c.stopwatch.reset();
      }
    });
    for (var groups in c.stories) {
      for (var element in groups) {
        if (element.type == StoryType.video) {
          if (element.videoController != null) {
            element.videoController!.initialize().then((_) {
              setState(() {});
              element.duration =
                  element.videoController!.value.duration.inMilliseconds;
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _sliderController.dispose();
    for (var groups in c.stories) {
      for (var element in groups) {
        if (element.type == StoryType.video) {
          if (element.videoController != null) {
            element.videoController!.dispose();
          }
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CarouselSlider.builder(
          controller: _sliderController,
          autoSliderTransitionTime: const Duration(milliseconds: 500),
          slideBuilder: (index) {
            return Obx(() => Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) => _onTapDown(details),
                    onTapUp: (TapUpDetails details) => _onTapUp(details),
                    child: SizedBox(
                      height: double.infinity,
                      child: Stack(
                        children: [
                          Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.black,
                          ),
                          const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                          c.stories[index][c.visitedStoriesIds[index]].type ==
                                  StoryType.video
                              ? (c.stories[index][c.visitedStoriesIds[index]]
                                      .videoController!.value.isInitialized
                                  ? Center(
                                      child: AspectRatio(
                                        aspectRatio: c
                                            .stories[index]
                                                [c.visitedStoriesIds[index]]
                                            .videoController!
                                            .value
                                            .aspectRatio,
                                        child: VideoPlayer(c
                                            .stories[index]
                                                [c.visitedStoriesIds[index]]
                                            .videoController!),
                                      ),
                                    )
                                  : Container())
                              : Image.network(
                                  c.stories[index][c.visitedStoriesIds[index]]
                                      .url,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                ),
                          SafeArea(
                              child: Row(
                                  children: c.stories[index]
                                      .asMap()
                                      .entries
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: (Get.width -
                                                      16 *
                                                          c.stories[index]
                                                              .length) /
                                                  c.stories[index].length,
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(1)),
                                                child: LinearProgressIndicator(
                                                  value: e.key ==
                                                          c.visitedStoriesIds[
                                                              index]
                                                      ? (c.currentState[
                                                                  'currentTime']
                                                              as int) /
                                                          c
                                                              .stories[index][
                                                                  c.visitedStoriesIds[
                                                                      index]]
                                                              .duration
                                                      : e.key >
                                                              c.visitedStoriesIds[
                                                                  index]
                                                          ? 0
                                                          : 1,
                                                  minHeight: 5,
                                                  color: Colors.white,
                                                  backgroundColor:
                                                      Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList())),
                        ],
                      ),
                    ),
                  ),
                ));
          },
          slideTransform: const CubeTransform(),
          onSlideChanged: (value) {
            if (value > c.currentStoryGroupId.value) {
              c.rightSwipe();
            } else if (value < c.currentStoryGroupId.value) {
              c.leftSwipe();
            }
          },
          onSlideEnd: () => c.start(),
          onSlideStart: () => c.stop(),
          itemCount: c.stories.length),
    );
  }

  _onTapDown(TapDownDetails details) {
    lastTapTime = DateTime.now().millisecondsSinceEpoch;
    c.stop();
  }

  _onTapUp(TapUpDetails details) {
    var x = details.globalPosition.dx;

    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastTapTime < 300) {
      if (x < Get.width / 2) {
        bool res = c.leftTap();
        if (res) {
          _sliderController.previousPage();
        } else {
          c.start();
        }
      } else {
        bool res = c.rightTap();
        if (res) {
          _sliderController.nextPage();
        } else {
          c.start();
        }
      }
    } else {
      c.start(true);
    }
  }
}

class Controller extends GetxController {
  final stopwatch = Stopwatch();

  var stories = [
    [
      Story(
          StoryType.image, "https://picsum.photos/720/1280?random=1", 5 * 1000)
    ],
    [
      Story(
          StoryType.image, "https://picsum.photos/720/1280?random=2", 5 * 1000),
      Story(
          StoryType.image, "https://picsum.photos/720/1280?random=3", 5 * 1000)
    ],
    [
      Story(
          StoryType.image, "https://picsum.photos/720/1280?random=4", 5 * 1000),
      Story(
          StoryType.video,
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
          5 * 1000,
          VideoPlayerController.network(
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')),
      Story(
          StoryType.image, "https://picsum.photos/720/1280?random=5", 5 * 1000),
      Story(
          StoryType.image, "https://picsum.photos/720/1280?random=6", 5 * 1000)
    ],
    [
      Story(
          StoryType.video,
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
          5 * 1000,
          VideoPlayerController.network(
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
    ],
    [
      Story(
          StoryType.image,
          "https://w0.peakpx.com/wallpaper/204/418/HD-wallpaper-iphone-xs-iphone-x-xd-xs-max-apple-black-thumbnail.jpg",
          5 * 1000)
    ],
  ].obs;
  var currentStoryGroupId = 0.obs;
  var currentState = {
    "currentStoryId": 0,
    "currentTime": 0,
    "isPlaying": false,
  }.obs;

  var visitedStoriesIds = List.filled(5, 0).obs;

  stop() {
    if ((currentState["isPlaying"]! as bool) &&
        stories[currentStoryGroupId.value]
                    [currentState["currentStoryId"] as int]
                .videoController !=
            null &&
        stories[currentStoryGroupId.value]
                [currentState["currentStoryId"] as int]
            .videoController!
            .value
            .isPlaying) {
      stories[currentStoryGroupId.value][currentState["currentStoryId"] as int]
          .videoController!
          .pause();
    }
    currentState["isPlaying"] = false;
    stopwatch.stop();
  }

  start([bool? notResetVideo]) {
    if (!(currentState["isPlaying"]! as bool) &&
        stories[currentStoryGroupId.value]
                    [currentState["currentStoryId"] as int]
                .videoController !=
            null &&
        !stories[currentStoryGroupId.value]
                [currentState["currentStoryId"] as int]
            .videoController!
            .value
            .isPlaying) {
      if (notResetVideo == null)
        stories[currentStoryGroupId.value]
                [currentState["currentStoryId"] as int]
            .videoController!
            .seekTo(Duration.zero);
      stories[currentStoryGroupId.value][currentState["currentStoryId"] as int]
          .videoController!
          .play();
    }
    currentState["isPlaying"] = true;
    stopwatch.start();
  }

  leftTap() {
    if (currentState["currentStoryId"] == 0) {
      if (currentStoryGroupId.value == 0) {
        return false;
      } else {
        currentStoryGroupId.value = currentStoryGroupId.value - 1;
        currentState["currentStoryId"] =
            stories[currentStoryGroupId.value].length - 1;
        visitedStoriesIds[currentStoryGroupId.value] =
            currentState["currentStoryId"]! as int;
        stopwatch.reset();
        return true;
      }
    } else {
      currentState["currentStoryId"] =
          (currentState["currentStoryId"]! as int) - 1;
    }
    visitedStoriesIds[currentStoryGroupId.value] =
        currentState["currentStoryId"]! as int;
    stopwatch.reset();
    return false;
  }

  rightTap() {
    if (currentState["currentStoryId"] ==
        stories[currentStoryGroupId.value].length - 1) {
      if (currentStoryGroupId.value == stories.length - 1) {
        return false;
      } else {
        currentStoryGroupId.value = (currentStoryGroupId.value) + 1;
        currentState["currentStoryId"] = 0;
        visitedStoriesIds[currentStoryGroupId.value] =
            currentState["currentStoryId"]! as int;
        stopwatch.reset();
        return true;
      }
    } else {
      currentState["currentStoryId"] =
          (currentState["currentStoryId"]! as int) + 1;
    }
    visitedStoriesIds[currentStoryGroupId.value] =
        currentState["currentStoryId"]! as int;
    stopwatch.reset();
    return false;
  }

  leftSwipe() {
    if (currentStoryGroupId.value == 0) {
      return;
    } else {
      currentStoryGroupId.value = (currentStoryGroupId.value) - 1;
      currentState["currentStoryId"] =
          visitedStoriesIds[currentStoryGroupId.value];
    }
    stopwatch.reset();
  }

  rightSwipe() {
    if (currentStoryGroupId.value == stories.length - 1) {
      return;
    } else {
      currentStoryGroupId.value = (currentStoryGroupId.value) + 1;
      currentState["currentStoryId"] =
          visitedStoriesIds[currentStoryGroupId.value];
    }
    stopwatch.reset();
  }
}

class Story {
  final StoryType type;
  final String url;
  int duration;
  VideoPlayerController? videoController;

  Story(this.type, this.url, this.duration, [this.videoController]);
}

enum StoryType {
  image,
  video,
}
