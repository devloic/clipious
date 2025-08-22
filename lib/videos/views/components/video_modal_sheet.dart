import 'package:clipious/videos/models/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';
import 'package:clipious/player/states/player.dart';
import 'package:clipious/utils.dart';
import 'package:clipious/videos/views/components/add_to_playlist_button.dart';
import 'package:clipious/videos/views/components/download_modal_sheet.dart';

import '../../../main.dart';
import 'add_to_queue_button.dart';

class VideoModalSheet extends StatelessWidget {
  final Video video;

  const VideoModalSheet({super.key, required this.video});

  static void showVideoModalSheet(BuildContext context, Video video) {
    showSafeModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          return SafeArea(
            child: VideoModalSheet(
              video: video,
            ),
          );
        });
  }

  void playNext(BuildContext context) {
    var player = context.read<PlayerCubit>();
    var locals = AppLocalizations.of(context)!;
    Navigator.of(context).pop();
    player.playVideoNext(video);

    final ScaffoldMessengerState? scaffold = scaffoldKey.currentState;
    scaffold?.showSnackBar(SnackBar(
      content: Text(locals.playNextAddedToQueue),
      duration: const Duration(seconds: 1),
    ));
  }

  void addToQueue(BuildContext context) {
    var player = context.read<PlayerCubit>();
    var locals = AppLocalizations.of(context)!;
    Navigator.of(context).pop();
    player.queueVideos([video]);

    final ScaffoldMessengerState? scaffold = scaffoldKey.currentState;
    scaffold?.showSnackBar(SnackBar(
      content: Text(locals.videoAddedToQueue),
      duration: const Duration(seconds: 1),
    ));
  }

  void downloadVideo(BuildContext context) {
    Navigator.of(context).pop();
    DownloadModalSheet.showVideoModalSheet(context, video);
  }

  void _showSharingSheet(BuildContext context) {
    Navigator.of(context).pop();
    showSharingSheet(context, video);
  }

  @override
  Widget build(BuildContext context) {
    var locals = AppLocalizations.of(context)!;
    return FractionallySizedBox(
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            AddToPlayListButton(
              videoId: video.videoId,
              type: AddToPlayListButtonType.modalSheet,
              afterAdd: () => Navigator.pop(context),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                    onPressed: AddToQueueButton.canAddToQueue(context, [video])
                        ? () => addToQueue(context)
                        : null,
                    icon: const Icon(Icons.playlist_play)),
                Text(locals.addToQueueList)
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                    onPressed: () => playNext(context),
                    icon: const Icon(Icons.play_arrow)),
                Text(locals.playNext)
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                    onPressed: () => downloadVideo(context),
                    icon: const Icon(Icons.download)),
                Text(locals.download)
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                    onPressed: () => _showSharingSheet(context),
                    icon: const Icon(Icons.share)),
                Text(locals.share)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
