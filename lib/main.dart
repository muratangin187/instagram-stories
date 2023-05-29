import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:instagram_story/controller.dart';
import 'package:instagram_story/model.dart';
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
                    onTapDown: _onTapDown,
                    onTapUp: _onTapUp,
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
                          renderPlayer(index),
                          SafeArea(
                              child: Row(
                                  children: c.stories[index]
                                      .asMap()
                                      .entries
                                      .map((e) => getIndicator(index, e))
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

  Padding getIndicator(int index, MapEntry<int, Story> e) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: (Get.width - 16 * c.stories[index].length) /
            c.stories[index].length,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(1)),
          child: LinearProgressIndicator(
            value: e.key == c.visitedStoriesIds[index]
                ? (c.currentState['currentTime'] as int) /
                    c.stories[index][c.visitedStoriesIds[index]].duration
                : e.key > c.visitedStoriesIds[index]
                    ? 0
                    : 1,
            minHeight: 5,
            color: Colors.white,
            backgroundColor: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  renderPlayer(index) {
    var current = c.stories[index][c.visitedStoriesIds[index]];
    if (current.type == StoryType.video) {
      if (current.videoController!.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: c.stories[index][c.visitedStoriesIds[index]]
                .videoController!.value.aspectRatio,
            child: VideoPlayer(
                c.stories[index][c.visitedStoriesIds[index]].videoController!),
          ),
        );
      } else {
        return Container();
      }
    } else {
      return Image.network(
        c.stories[index][c.visitedStoriesIds[index]].url,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      );
    }
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
