import 'package:video_player/video_player.dart';

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
