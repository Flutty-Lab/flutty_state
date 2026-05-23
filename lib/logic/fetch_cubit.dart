import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/utils.dart';

part 'fetch_state.dart';

class FetchCubit<F> extends Cubit<FetchState<F>> {
  FetchCubit({
    this.timeoutMessage,
    this.unexpectedExceptionMessage,
    this.onFetchError,
    Stream<F>? dataUpdatedStream,
  }) : super(FetchInitial()) {
    _streamSubscription = dataUpdatedStream?.listen(_onDataUpdated);
  }

  final String? timeoutMessage;
  final String? unexpectedExceptionMessage;

  /// Optional callback invoked whenever [fetch] / [refresh] catches an
  /// exception, after the failure has been logged.
  final OnFetchError? onFetchError;

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
        DataFetchFailed<F>() =>
          FetchFailed(result.message, exception: result.exception),
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
        DataFetchFailed<F>() =>
          RefreshFailed(result.message, exception: result.exception),
      });
    }
  }

  Future<DataFetchingResponse<F>> _fetch({
    required DataFetcher<F> dataFetcher,
    required Duration timeout,
  }) async {
    try {
      return await dataFetcher().timeout(timeout);
    } on TimeoutException catch (e, stackTrace) {
      _reportError(e, stackTrace, timeoutMessage ?? 'Timeout');
      return DataFetchFailed(
        message: timeoutMessage ?? 'Timeout',
        exception: e,
      );
    } catch (e, stackTrace) {
      _reportError(
        e,
        stackTrace,
        unexpectedExceptionMessage ?? 'Unexpected error',
      );
      return DataFetchFailed(
        message: unexpectedExceptionMessage ?? 'Unexpected error',
        exception: e,
      );
    }
  }

  void _reportError(Object error, StackTrace stackTrace, String message) {
    developer.log(
      message,
      name: 'flutty_state.FetchCubit<$F>',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    onFetchError?.call(error, stackTrace);
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
