import 'package:get/get.dart';
import 'package:instagram_story/model.dart';
import 'package:video_player/video_player.dart';

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
