import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipious/l10n/generated/app_localizations.dart';
import 'package:clipious/home/models/db/home_layout.dart';
import 'package:clipious/settings/states/settings.dart';
import 'package:clipious/settings/views/tv/screens/settings.dart';
import 'package:clipious/utils/views/tv/components/tv_overscan.dart';

@RoutePage()
class TvAppLayoutSettingsScreen extends StatelessWidget {
  const TvAppLayoutSettingsScreen({super.key});

  toggleDataSource(BuildContext context, HomeDataSource ds) async {
    var settings = context.read<SettingsCubit>();
    var current = settings.state.appLayout;
    var defaults = HomeDataSource.defaultSettings();

    // we want to keep the original order
    // so we take the existing settings, remove or add what we need
    if (current.contains(ds)) {
      current.remove(ds);
    } else {
      current.add(ds);
    }
    // use defaaults to keep original order
    await settings.setAppLayout(
        defaults.where((element) => current.contains(element)).toList());
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locals = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return TvOverscan(
            child: ListView(
                children: HomeDataSource.defaultSettings()
                    .map((e) => SettingsTile(
                          title: e.getLabel(locals),
                          onSelected: (context) => toggleDataSource(context, e),
                          trailing: Switch(
                              onChanged: (value) {},
                              value: state.appLayout.contains(e)),
                        ))
                    .toList()),
          );
        },
      ),
    );
  }
}
