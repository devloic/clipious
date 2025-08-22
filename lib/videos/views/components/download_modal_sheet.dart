import 'package:clipious/utils.dart';
import 'package:clipious/videos/models/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:clipious/globals.dart';
import 'package:clipious/main.dart';
import 'package:clipious/utils/pretty_bytes.dart';
import 'package:clipious/videos/states/download_modal_sheet.dart';

import '../../../downloads/states/download_manager.dart';

class DownloadModalSheet extends StatelessWidget {
  final Video video;

  // called when the download is triggerd
  final Function()? onDownload;

  // called when we know whether we can start downloading stuff
  final Function(bool isDownloadStarted)? onDownloadStarted;

  const DownloadModalSheet(
      {super.key,
      required this.video,
      this.onDownloadStarted,
      this.onDownload});

  static void showVideoModalSheet(BuildContext context, Video video,
      {Function(bool isDownloadStarted)? onDownloadStarted,
      Function()? onDownload}) {
    showSafeModalBottomSheet<void>(
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (BuildContext context) {
          return DownloadModalSheet(
            video: video,
            onDownload: onDownload,
            onDownloadStarted: onDownloadStarted,
          );
        });
  }

  void downloadVideo(
      BuildContext context, DownloadModalSheetState state) async {
    var downloadManager = context.read<DownloadManagerCubit>();
    if (onDownload != null) {
      onDownload!();
    }
    var locals = AppLocalizations.of(context)!;
    Navigator.of(context).pop();
    scaffoldKey.currentState
        ?.showSnackBar(SnackBar(content: Text(locals.videoDownloadStarted)));
    bool canDownload = await downloadManager.addDownload(video.videoId,
        audioOnly: state.audioOnly, quality: state.quality);
    if (!canDownload) {
      scaffoldKey.currentState?.showSnackBar(
          SnackBar(content: Text(locals.videoAlreadyDownloaded)));
    }
    if (onDownloadStarted != null) {
      onDownloadStarted!(canDownload);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locals = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (BuildContext context) =>
          DownloadModalSheetCubit(const DownloadModalSheetState(), video),
      child: BlocBuilder<DownloadModalSheetCubit, DownloadModalSheetState>(
          builder: (context, state) {
        var cubit = context.read<DownloadModalSheetCubit>();
        return AnimatedSwitcher(
          duration: animationDuration,
          switchInCurve: animationCurve,
          switchOutCurve: animationCurve,
          child: state.loading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Text(locals.quality),
                                const Gap(10),
                                DropdownButton<String>(
                                  value: state.availableQualities
                                      .map((e) => e.qualityLabel)
                                      .where((e) => e == state.quality)
                                      .firstOrNull,
                                  onChanged: state.audioOnly
                                      ? null
                                      : (value) => cubit.setQuality(value),
                                  items: state.availableQualities
                                      .map((e) => DropdownMenuItem<String>(
                                          value: e.qualityLabel,
                                          child: Text(
                                              '${e.qualityLabel ?? ''} (~${prettyBytes(double.parse(e.clen))})')))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => cubit.setAudioOnly(!state.audioOnly),
                            child: Row(
                              children: [
                                Text(locals.videoDownloadAudioOnly),
                                const Gap(10),
                                Switch(
                                  value: state.audioOnly,
                                  onChanged: cubit.setAudioOnly,
                                )
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => downloadVideo(context, state),
                            icon: const Icon(Icons.download),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
        );
      }),
    );
  }
}
