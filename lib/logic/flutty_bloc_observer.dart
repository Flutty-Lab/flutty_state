import 'package:bloc/bloc.dart';
import 'package:flutty_state/logic/fetch_cubit.dart';
import 'package:flutty_state/logic/submit_cubit.dart';

class FluttyBlocObserver extends BlocObserver {
  const FluttyBlocObserver({required this.onErrorCallback});

  final void Function(
    String message, {
    String? eventName,
    Map<String, dynamic>? parameters,
  }) onErrorCallback;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    final nextState = change.nextState;
    final (errorState, exception) = switch (nextState) {
      FetchFailed() => (
          'FetchFailed=>${nextState.failedMessage}',
          nextState.exception,
        ),
      RefreshFailed() => (
          'RefreshFailed=>${nextState.failedMessage}',
          nextState.exception,
        ),
      SubmitFailed() => (
          'SubmitFailed=>${nextState.failedMessage}',
          nextState.exception,
        ),
      _ => (null, null),
    };

    if (errorState != null) {
      onErrorCallback(
        '${bloc.runtimeType}',
        parameters: {
          'bloc': '${bloc.runtimeType}',
          'state': errorState,
          'exception': exception.toString(),
        },
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    onErrorCallback(
      '${bloc.runtimeType}',
      eventName: error.toString(),
      parameters: {
        'stackTrace': stackTrace.toString(),
        'bloc': '${bloc.runtimeType}',
      },
    );
    super.onError(bloc, error, stackTrace);
  }
}
