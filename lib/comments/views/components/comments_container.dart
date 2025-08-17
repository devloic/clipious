import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';
import 'package:clipious/comments/states/comments_container.dart';
import 'package:clipious/videos/models/video.dart';

import 'comments.dart';

class CommentsContainer extends StatelessWidget {
  final Video video;

  const CommentsContainer({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    var locals = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (context) =>
          CommentsContainerCubit(const CommentsContainerState()),
      child: BlocBuilder<CommentsContainerCubit, CommentsContainerState>(
        builder: (context, state) {
          var cubit = context.read<CommentsContainerCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      locals.comments,
                      style: textTheme.titleMedium
                          ?.copyWith(color: colorScheme.secondary),
                    ),
                  ),
                  DropdownButton<String>(
                    value: state.sortBy,
                    onChanged: cubit.changeSorting,
                    items: [
                      DropdownMenuItem(
                        value: 'top',
                        child: Text(locals.topSorting),
                      ),
                      DropdownMenuItem(
                        value: 'new',
                        child: Text(locals.newSorting),
                      ),
                    ],
                  )
/*
                  DropdownButton<String>(
                    value: source,
                    onChanged: (String? value) {
                      if (value != source) {
                        setState(() {
                          source = value ?? 'youtube';
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'youtube',
                        child: Text('Youtube'),
                      ),
                      DropdownMenuItem(
                        value: 'reddit',
                        child: Text('Reddit'),
                      ),
                    ],
                  )
*/
                ],
              ),
              CommentsView(
                  key: ValueKey<String>(
                      'comments-${state.sortBy}-${state.source}'),
                  video: video,
                  source: state.source,
                  sortBy: state.sortBy),
            ],
          );
        },
      ),
    );
  }
}
