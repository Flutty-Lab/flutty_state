part of 'fetch_cubit.dart';

sealed class FetchState<T> extends Equatable {
  const FetchState();

  @override
  List<Object> get props => [];
}

class FetchInitial<T> extends FetchState<T> {}

/// Fetch stats

class Fetching<T> extends FetchState<T> {}

class FetchSucceed<T> extends FetchState<T> {
  const FetchSucceed({required this.data});

  final T data;

  @override
  List<Object> get props => [data as Object];
}

class FetchFailed<T> extends FetchState<T> {
  const FetchFailed(this.failedMessage, {this.exception});

  final String failedMessage;
  final dynamic exception;

  @override
  List<Object> get props => [failedMessage];
}

/// Refresh stats
sealed class RefreshState<T> extends FetchState<T> {
  const RefreshState();
}

class RefreshFetching<T> extends RefreshState<T> {}

class RefreshFailed<T> extends RefreshState<T> {
  const RefreshFailed(this.failedMessage, {this.exception});

  final String failedMessage;
  final dynamic exception;

  @override
  List<Object> get props => [failedMessage];
}
