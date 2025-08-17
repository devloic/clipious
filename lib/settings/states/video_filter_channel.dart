import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:clipious/channels/models/channel.dart';
import 'package:clipious/globals.dart';

import '../models/db/video_filter.dart';

part 'video_filter_channel.freezed.dart';

const String allChannels = 'all';

class VideoFilterChannelCubit extends Cubit<VideoFilterChannelState> {
  VideoFilterChannelCubit(super.initialState) {
    onReady();
  }

  onReady() {
    getChannel();
  }

  bool hasChannel() {
    return state.filters.isNotEmpty &&
        state.filters[0].channelId != null &&
        state.filters[0].channelId != allChannels;
  }

  Future<void> getChannel() async {
    if (state.filters.isNotEmpty &&
        state.filters[0].channelId != null &&
        state.filters[0].channelId != allChannels) {
      emit(state.copyWith(loading: true));

      var channel = await service.getChannel(state.filters[0].channelId!);
      emit(state.copyWith(channel: channel, loading: false));
    }
  }

  Future<void> deleteFilter(VideoFilter filter) async {
    var state = this.state.copyWith();
    await db.deleteFilter(filter);
    emit(state);
  }
}

@freezed
sealed class VideoFilterChannelState with _$VideoFilterChannelState {
  const factory VideoFilterChannelState(
      {required List<VideoFilter> filters,
      Channel? channel,
      @Default(false) bool loading}) = _VideoFilterChannelState;
}
