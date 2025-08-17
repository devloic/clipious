import 'package:flutter/material.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';

import '../../models/db/video_filter.dart';

class VideoFilterItem extends StatelessWidget {
  final VideoFilter filter;

  const VideoFilterItem({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    var locals = AppLocalizations.of(context)!;
    ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Container(
          decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(filter.localizedLabel(locals, context)),
          )),
    );
  }
}
