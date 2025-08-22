import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';
import 'package:clipious/globals.dart';
import 'package:clipious/player/states/interfaces/media_player.dart';
import 'package:clipious/player/states/player.dart';
import 'package:clipious/player/views/components/video_queue.dart';

import '../../../comments/views/components/comments_container.dart';
import '../../../downloads/models/downloaded_video.dart';
import '../../../settings/states/settings.dart';
import '../../../videos/models/video.dart';
import '../../../videos/views/components/info.dart';
import '../../../videos/views/components/recommended_videos.dart';

class ExpandedSideBar extends StatelessWidget {
  const ExpandedSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locals = AppLocalizations.of(context)!;

    var player = context.read<PlayerCubit>();
    var controller = player.state;

    Video? video = controller.currentlyPlaying;
    DownloadedVideo? offlineVid = controller.offlineCurrentlyPlaying;
    var settings = context.watch<SettingsCubit>().state;

    bool isFullScreen =
        controller.fullScreenState == FullScreenState.fullScreen;
    var distractionFreeMode = settings.distractionFreeMode;
    return Builder(builder: (context) {
      var selectedIndex = context
          .select((PlayerCubit value) => value.state.selectedFullScreenIndex);
      return !isFullScreen &&
              !controller.isMini &&
              (video != null || offlineVid != null)
          ? video != null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    // If height is too constrained (during drag animation), show minimal or no content
                    if (constraints.maxHeight < 100) {
                      return const SizedBox.shrink();
                    }
                    
                    return DefaultTabController(
                      initialIndex: selectedIndex,
                      length: distractionFreeMode ? 2 : 4,
                      child: Column(children: [
                        TabBar(tabs: [
                          Tab(
                            icon: const Icon(Icons.info),
                            text: locals.info,
                          ),
                          if (!distractionFreeMode)
                            Tab(
                              icon: const Icon(Icons.chat_bubble),
                              text: locals.comments,
                            ),
                          if (!distractionFreeMode)
                            Tab(
                              icon: const Icon(Icons.schema),
                              text: locals.recommended,
                            ),
                          Tab(
                            icon: const Icon(Icons.playlist_play),
                            text: locals.videoQueue,
                          )
                        ]),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: innerHorizontalPadding),
                            child: TabBarView(children: <Widget>[
                              SingleChildScrollView(
                                child: VideoInfo(
                                  video: video,
                                  titleAndChannelInfo: false,
                                ),
                              ),
                              if (!distractionFreeMode)
                                SingleChildScrollView(
                                  child: CommentsContainer(
                                    video: video,
                                    key: ValueKey('comms-${video.videoId}'),
                                  ),
                                ),
                              if (!distractionFreeMode)
                                SingleChildScrollView(
                                    child: RecommendedVideos(video: video)),
                              const VideoQueue(),
                            ]),
                          ),
                        )
                      ]),
                    );
                  },
                )
              : const SizedBox.shrink()
          : const SizedBox.shrink();
    });
  }
}
