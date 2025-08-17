import 'package:clipious/player/states/tv_player_controls.dart';
import 'package:clipious/player/views/tv/components/player_settings.dart';
import 'package:clipious/utils/views/components/thumbnail.dart';
import 'package:clipious/utils/views/tv/components/tv_button.dart';
import 'package:clipious/utils/views/tv/components/tv_horizontal_item_list.dart';
import 'package:clipious/utils/views/tv/components/tv_overscan.dart';
import 'package:clipious/videos/models/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';

import '../../../../globals.dart';
import '../../../../utils.dart';
import '../../../../utils/models/image_object.dart';
import '../../../../utils/models/paginated_list.dart';
import '../../../states/player.dart';

class TvPlayerControls extends StatelessWidget {
  const TvPlayerControls({super.key});

  onVideoQueueSelected(
      BuildContext context, TvPlayerControlsCubit cubit, Video video) {
    cubit.playFromQueue(video);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    var locals = AppLocalizations.of(context)!;
    var player = context.read<PlayerCubit>();
    return BlocProvider(
      create: (context) =>
          TvPlayerControlsCubit(const TvPlayerControlsState(), player),
      child: BlocBuilder<TvPlayerControlsCubit, TvPlayerControlsState>(
        builder: (context, playerState) {
          var cubit = context.read<TvPlayerControlsCubit>();
          var currentlyPlaying = context
              .select((PlayerCubit value) => value.state.currentlyPlaying);
          var videos =
              context.select((PlayerCubit value) => value.state.videos);
          var isPlaying =
              context.select((PlayerCubit value) => value.state.isPlaying);
          var position =
              context.select((PlayerCubit value) => value.state.position);

          return BlocListener<PlayerCubit, PlayerState>(
            listenWhen: (previous, current) =>
                previous.mediaEvent != current.mediaEvent,
            listener: (BuildContext context, state) {
              cubit.onStreamEvent(state.mediaEvent);
            },
            child: Focus(
              autofocus: true,
              onKeyEvent: (node, event) =>
                  cubit.handleRemoteEvents(node, event),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: playerState.controlsOpacity,
                      duration: animationDuration,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Colors.black.withOpacity(1),
                              Colors.black.withOpacity(0),
                              Colors.black.withOpacity(1)
                            ])),
                      ),
                    ),
                  ),
                  Positioned(
                      child: TvOverscan(
                    child: playerState.showSettings
                        ? const TvPlayerSettings()
                        : const SizedBox.shrink(),
                  )),
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: playerState.showSettings
                          ? const SizedBox.shrink()
                          : AnimatedOpacity(
                              opacity: playerState.controlsOpacity,
                              duration: animationDuration,
                              child: TvOverscan(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentlyPlaying?.title ?? '',
                                      style: textTheme.headlineLarge
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Thumbnail(
                                            thumbnails: ImageObject
                                                .getThumbnailUrlsByPreferredOrder(
                                                    currentlyPlaying
                                                        ?.authorThumbnails),
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 20),
                                            child: Text(
                                              currentlyPlaying?.author ?? '',
                                              style: textTheme.headlineSmall
                                                  ?.copyWith(
                                                      color: Colors.white),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: playerState.controlsOpacity,
                      duration: animationDuration,
                      child: TvOverscan(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            playerState.displayControls
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 16),
                                    child: FocusScope(
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: TvButton(
                                              onPressed: (context) =>
                                                  player.togglePlaying(),
                                              unfocusedColor:
                                                  Colors.transparent,
                                              autofocus: true,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  isPlaying
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: videos.length > 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16.0),
                                              child: TvButton(
                                                onPressed: (context) =>
                                                    player.playPrevious(),
                                                unfocusedColor:
                                                    Colors.transparent,
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.skip_previous,
                                                    size: 50,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: TvButton(
                                              unfocusedColor:
                                                  Colors.transparent,
                                              onPressed: (context) =>
                                                  cubit.fastRewind(),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.fast_rewind,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: TvButton(
                                              onPressed: (context) =>
                                                  cubit.fastForward(),
                                              unfocusedColor:
                                                  Colors.transparent,
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.fast_forward,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: videos.length > 1,
                                            child: TvButton(
                                              onPressed: (context) =>
                                                  player.playNext(),
                                              unfocusedColor:
                                                  Colors.transparent,
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.skip_next,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(child: Container()),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: TvButton(
                                              onPressed: (context) =>
                                                  cubit.displayQueue(),
                                              unfocusedColor:
                                                  Colors.transparent,
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.video_library,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: TvButton(
                                              onPressed: (context) =>
                                                  cubit.displaySettings(),
                                              unfocusedColor:
                                                  Colors.transparent,
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.settings,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                (currentlyPlaying?.liveNow ?? false)
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 2),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.podcasts,
                                                size: 15,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  locals.streamIsLive,
                                                  style: textTheme.bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: player.progress >= 0
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child:
                                                    AnimatedFractionallySizedBox(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  duration: animationDuration,
                                                  widthFactor: player.progress,
                                                  child: Container(
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                  ),
                                                ))
                                            : const SizedBox.shrink()),
                                if (!(currentlyPlaying?.liveNow ?? false))
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      '${prettyDurationCustom(position)} / ${prettyDurationCustom(player.duration)}',
                                      style: textTheme.titleLarge
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      left: 0,
                      bottom: 50,
                      right: 0,
                      child: AnimatedSwitcher(
                          duration: animationDuration,
                          child: playerState.showQueue
                              ? TvOverscan(
                                  child: FocusScope(
                                  autofocus: true,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        locals.videoQueue,
                                        style: textTheme.titleLarge,
                                      ),
                                      TvHorizontalVideoList(
                                          onSelect: (ctx, video) =>
                                              onVideoQueueSelected(
                                                  ctx, cubit, video),
                                          paginatedVideoList:
                                              FixedItemList(videos)),
                                    ],
                                  ),
                                ))
                              : const SizedBox.shrink()))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
