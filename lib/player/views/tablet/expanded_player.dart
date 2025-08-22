import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/globals.dart';
import 'package:clipious/player/states/interfaces/media_player.dart';
import 'package:clipious/player/states/player.dart';
import '../../../downloads/models/downloaded_video.dart';
import '../../../videos/models/video.dart';
import '../../../videos/views/components/info.dart';
import '../components/mini_player_controls.dart';

class TabletExpandedPlayer extends StatelessWidget {
  const TabletExpandedPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    var player = context.read<PlayerCubit>();
    var controller = player.state;

    Video? video = controller.currentlyPlaying;
    DownloadedVideo? offlineVid = controller.offlineCurrentlyPlaying;

    bool isFullScreen =
        controller.fullScreenState == FullScreenState.fullScreen;

    return !isFullScreen &&
            !controller.isMini &&
            (video != null || offlineVid != null)
        ? LayoutBuilder(
            builder: (context, constraints) {
              // If height is too constrained (during drag animation), show minimal or no content
              if (constraints.maxHeight < 100) {
                return const SizedBox.shrink();
              }
              
              return Column(children: [
                MiniPlayerControls(
                  videoId: video?.videoId ?? offlineVid?.videoId ?? '',
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: innerHorizontalPadding),
                    child: Builder(builder: (context) {
                      return video != null
                          ? SingleChildScrollView(
                              child: VideoInfo(
                                video: video,
                                descriptionAndTags: false,
                              ),
                            )
                          : const SizedBox.shrink();
                    }),
                  ),
                )
              ]);
            },
          )
        : const SizedBox.shrink();
  }
}
