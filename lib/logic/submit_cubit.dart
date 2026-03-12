import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutty_state/data/data_submit_response.dart';
import 'package:flutty_state/logic/fetch_cubit.dart';
import 'package:flutty_state/utils.dart';

part 'submit_state.dart';

class SubmitCubit<F> extends Cubit<SubmitState> {
  SubmitCubit({
    this.timeoutMessage,
    this.unexpectedExceptionMessage,
    this.technicalErrorMessage,
    this.fetchCubit,
    this.dataFetcher,
  }) : super(SubmitInitial());

  final String? timeoutMessage;
  final String? unexpectedExceptionMessage;
  final String? technicalErrorMessage;
  final FetchCubit<F>? fetchCubit;
  final DataFetcher<F>? dataFetcher;

  Future<void> submit({
    required DataSubmitter<void> dataSubmitter,
    DataOnResponseReceived<void>? onResponseReceived,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final result = await _submit(dataSubmitter: dataSubmitter);

    if (!isClosed) {
      switch (result) {
        case DataSubmitSucceedEmpty() || DataSubmitSucceed<void>():
          emit(SubmitSucceed(result.message));
          onResponseReceived?.call(result);
        case DataSubmitFailed():
          emit(SubmitFailed(result.message, exception: result.exception));
      }
    }
  }

  Future<void> submitAndFetch({
    required DataSubmitter<void> dataSubmitter,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (fetchCubit == null || dataFetcher == null) {
      emit(
        SubmitFailed(
          '${technicalErrorMessage ?? 'Technical error'} : fetchCubit = null || dataFetcher = null',
        ),
      );
      return;
    }

    final result = await _submit(dataSubmitter: dataSubmitter);

    if (!isClosed) {
      emit(switch (result) {
        DataSubmitSucceed() ||
        DataSubmitSucceedEmpty() =>
          SubmitSucceed(result.message),
        DataSubmitFailed() => SubmitFailed(
            result.message,
            exception: result.exception,
          ),
      });

      if (result is DataSubmitSucceed || result is DataSubmitSucceedEmpty) {
        await fetchCubit!.refresh(dataFetcher: dataFetcher!);
      }
    }
  }

  Future<void> submitAndRefresh({
    required DataSubmitter<F> dataSubmitter,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (fetchCubit == null) {
      emit(SubmitFailed('$technicalErrorMessage : fetchCubit = null'));
      return;
    }

    final result = await _submit(dataSubmitter: dataSubmitter);
    if (!isClosed) {
      emit(switch (result) {
        DataSubmitSucceed() ||
        DataSubmitSucceedEmpty() =>
          SubmitSucceed(result.message),
        DataSubmitFailed() => SubmitFailed(
            result.message,
            exception: result.exception,
          ),
      });

      if (result is DataSubmitSucceed<F>) {
        fetchCubit!.refreshWithoutFetch(data: result.data);
      }
    }
  }

  Future<DataSubmitResponse<void>> _submit({
    required DataSubmitter<void> dataSubmitter,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    emit(Submitting());
    try {
      return await dataSubmitter().timeout(timeout);
    } on TimeoutException catch (e) {
      return DataSubmitFailed(
        message: timeoutMessage ?? 'Timeout',
        exception: e,
      );
    } catch (e) {
      return DataSubmitFailed(
        message: unexpectedExceptionMessage ?? 'Unexpected error',
        exception: e,
      );
    }
  }
}
