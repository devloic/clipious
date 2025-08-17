import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:clipious/channels/models/channel_sort_by.dart';

import '../../globals.dart';
import '../models/channel.dart';

part 'channel.freezed.dart';

class ChannelCubit extends Cubit<ChannelController> {
  ChannelCubit(super.initialState) {
    onReady();
  }

  Future<void> onReady() async {
    var state = this.state.copyWith();
    bool isSubscribed = await service.isSubscribedToChannel(state.channelId);
    Channel channel = await service.getChannel(state.channelId);

    emit(state.copyWith(
        channel: channel, loading: false, isSubscribed: isSubscribed));
  }

/*
  @override
  close() async {
    state.controller?.dispose();
    super.close();
  }
*/

  toggleSubscription() async {
    var state = this.state.copyWith();
    if (state.channel != null) {
      if (state.isSubscribed) {
        await service.unSubscribe(state.channel!.authorId);
      } else {
        await service.subscribe(state.channel!.authorId);
      }
      bool isSubscribed =
          await service.isSubscribedToChannel(state.channel!.authorId);

      emit(state.copyWith(isSubscribed: isSubscribed));
    }
  }

  void onSortByChanged(ChannelSortBy newValue) {
    emit(state.copyWith(sortBy: newValue));
  }
}

@freezed
sealed class ChannelController with _$ChannelController {
  const factory ChannelController(
          {required String channelId,
          @Default(false) bool isSubscribed,
          Channel? channel,
          @Default(true) bool loading,
          @Default(false) bool smallHeader,
          @Default(200) double barHeight,
          @Default(1) double barOpacity,
          @Default(ChannelSortBy.newest) ChannelSortBy sortBy}) =
      _ChannelController;
}
