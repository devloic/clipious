import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';
import 'package:clipious/extensions.dart';
import 'package:clipious/router.dart';
import 'package:clipious/settings/states/video_filter.dart';
import 'package:clipious/settings/views/tv/screens/settings.dart';
import 'package:clipious/utils/views/tv/components/tv_overscan.dart';

import '../../../models/db/video_filter.dart';
import '../../../states/video_filter_channel.dart';

@RoutePage()
class TvFilterListSettingsScreen extends StatelessWidget {
  const TvFilterListSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locals = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocProvider(
        create: (context) => VideoFilterCubit(const VideoFilterState()),
        child: BlocBuilder<VideoFilterCubit, VideoFilterState>(
          builder: (context, state) {
            var cubit = context.read<VideoFilterCubit>();

            // sorting filters by channel
            Map<String, List<VideoFilter>> mappedFilters =
                state.filters.groupBy(
              (p0) => p0.channelId ?? allChannels,
            );
            List<String> keys = mappedFilters.keys.toList();
            keys.sort(cubit.sortChannels);

            return TvOverscan(
              child: ListView(
                children: [
                  SettingsTitle(title: locals.videoFiltersExplanation),
                  ...(keys.map((e) => VideoFilterChannel(
                      key: ValueKey(Random().nextInt(10000000)),
                      filters: mappedFilters[e] ?? []))),
                  SettingsTile(
                    title: locals.addVideoFilter,
                    leading: const Icon(Icons.add),
                    onSelected: (context) => AutoRouter.of(context)
                        .push(TvFilterEditSettingsRoute())
                        .then((value) => cubit.refreshFilters()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class VideoFilterChannel extends StatelessWidget {
  final List<VideoFilter> filters;

  const VideoFilterChannel({super.key, required this.filters});

  editFilter(BuildContext context, {required VideoFilter filter}) {
    var cubit = context.read<VideoFilterCubit>();

    AutoRouter.of(context)
        .push(TvFilterEditSettingsRoute(
            channelId: filter.channelId, filter: filter))
        .then((value) => cubit.refreshFilters());
  }

  @override
  Widget build(BuildContext context) {
    var locals = AppLocalizations.of(context)!;

    return BlocProvider(
        create: (context) =>
            VideoFilterChannelCubit(VideoFilterChannelState(filters: filters)),
        child: BlocBuilder<VideoFilterChannelCubit, VideoFilterChannelState>(
            builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.loading)
                const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator()),
              if (!state.loading && state.channel == null)
                SettingsTitle(title: locals.videoFilterAllChannels),
              if (!state.loading && state.channel != null)
                SettingsTitle(title: state.channel?.author ?? ''),
              ...state.filters.map((e) => SettingsTile(
                  key: ValueKey(e.uuid),
                  title: e.localizedLabel(locals, context),
                  onSelected: (context) => editFilter(context, filter: e)))
            ],
          );
        }));
  }
}
