import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/utils.dart';

part 'fetch_state.dart';

class FetchCubit<F> extends Cubit<FetchState<F>> {
  FetchCubit({
    this.timeoutMessage,
    this.unexpectedExceptionMessage,
    Stream<F>? dataUpdatedStream,
  }) : super(FetchInitial()) {
    _streamSubscription = dataUpdatedStream?.listen(_onDataUpdated);
  }

  final String? timeoutMessage;
  final String? unexpectedExceptionMessage;
  StreamSubscription<F>? _streamSubscription;

  Future<void> _onDataUpdated(F data) async {
    if (state is! Fetching) {
      emit(RefreshFetching());
      emit(FetchSucceed(data: data));
    }
  }

  Future<void> fetch({
    required DataFetcher<F> dataFetcher,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    emit(Fetching());
    final result = await _fetch(dataFetcher: dataFetcher, timeout: timeout);
    if (!isClosed) {
      emit(switch (result) {
        DataFetchSucceed<F>() => FetchSucceed(data: result.data),
        DataFetchFailed<F>() => FetchFailed(result.message),
      });
    }
  }

  Future<void> refresh({
    required DataFetcher<F> dataFetcher,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    emit(RefreshFetching());
    final result = await _fetch(dataFetcher: dataFetcher, timeout: timeout);
    if (!isClosed) {
      emit(switch (result) {
        DataFetchSucceed<F>() => FetchSucceed(data: result.data),
        DataFetchFailed<F>() => RefreshFailed(result.message),
      });
    }
  }

  Future<DataFetchingResponse<F>> _fetch({
    required DataFetcher<F> dataFetcher,
    required Duration timeout,
  }) async {
    try {
      return await dataFetcher().timeout(timeout);
    } on TimeoutException catch (e) {
      return DataFetchFailed(
        message: timeoutMessage ?? 'Timeout',
        exception: e,
      );
    } catch (e) {
      return DataFetchFailed(
        message: unexpectedExceptionMessage ?? 'Unexpected error',
        exception: e,
      );
    }
  }

  void refreshWithoutFetch({required F data}) {
    emit(FetchSucceed(data: data));
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
