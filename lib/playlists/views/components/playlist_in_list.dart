import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';
import 'package:clipious/globals.dart';
import 'package:clipious/playlists/models/playlist.dart';
import 'package:clipious/playlists/states/playlist_in_list.dart';
import 'package:clipious/playlists/views/components/playlist_thumbnail.dart';
import 'package:clipious/router.dart';
import 'package:clipious/utils.dart';

import '../../states/playlist_list.dart';

const smallPlaylistAspectRatio = 1.54;

class PlaylistInList extends StatelessWidget {
  final Playlist playlist;
  final bool canDeleteVideos;
  final bool isTv;
  final bool small;
  final bool isTablet;
  final double thumbnailsHeight;

  const PlaylistInList(
      {super.key,
      required this.playlist,
      required this.canDeleteVideos,
      this.isTv = false,
      this.small = false,
      this.thumbnailsHeight = 95,
      this.isTablet = false});

  openPlayList(BuildContext context) {
    var cubit = context.read<PlaylistListCubit>();
    AutoRouter.of(context)
        .push(PlaylistViewRoute(
            playlist: playlist, canDeleteVideos: canDeleteVideos))
        .then((value) => cubit.refreshPlaylists());
  }

  openTvPlaylist(BuildContext context) {
    AutoRouter.of(context)
        .push(TvPlaylistRoute(playlist: playlist, canDeleteVideos: false));
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var locals = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => PlaylistInListCubit(playlist),
      child: BlocBuilder<PlaylistInListCubit, Playlist>(
        builder: (context, state) {
          if (isTablet) {
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => openPlayList(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        height: thumbnailsHeight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlaylistThumbnails(
                            videos: state.videos,
                          ),
                        )),
                    Text(
                      playlist.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(color: colors.primary),
                    ),
                    Text(locals.nVideos(playlist.videoCount)),
                  ],
                ),
              ),
            );
          } else if (isTv) {
            return Focus(
              onKeyEvent: (node, event) =>
                  onTvSelect(event, context, (_) => openTvPlaylist(context)),
              autofocus: false,
              child: AspectRatio(
                aspectRatio: 16 / 13,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(builder: (ctx) {
                      final bool hasFocus = Focus.of(ctx).hasFocus;

                      return GestureDetector(
                        child: AnimatedScale(
                            curve: Curves.easeInOutQuad,
                            duration: animationDuration ~/ 2,
                            scale: hasFocus ? 1 : 0.9,
                            child: AnimatedContainer(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: hasFocus
                                    ? colors.primaryContainer
                                    : colors.surface,
                              ),
                              duration: animationDuration,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height: 140,
                                        child: PlaylistThumbnails(
                                          videos: state.videos,
                                        )),
                                    Expanded(
                                        child: Text(
                                      playlist.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleLarge
                                          ?.copyWith(color: colors.primary),
                                    )),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(locals
                                            .nVideos(playlist.videoCount))),
                                  ],
                                ),
                              ),
                            )),
                      );
                    })),
              ),
            );
          } else if (small) {
            return AspectRatio(
              aspectRatio: smallPlaylistAspectRatio,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => openPlayList(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PlaylistThumbnails(
                      videos: state.videos,
                    ),
                    Text(
                      playlist.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                          textTheme.labelSmall?.copyWith(color: colors.primary),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => openPlayList(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 95,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlaylistThumbnails(
                            videos: state.videos,
                          ),
                        )),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            playlist.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(color: colors.primary),
                          ),
                          Text(locals.nVideos(playlist.videoCount)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
