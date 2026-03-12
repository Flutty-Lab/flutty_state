sealed class DataFetchingResponse<T> {
  DataFetchingResponse();
}

class DataFetchSucceed<T> extends DataFetchingResponse<T> {
  DataFetchSucceed({required this.data});

  final T data;
}

class DataFetchFailed<T> extends DataFetchingResponse<T> {
  DataFetchFailed({required this.message, this.exception});

  final dynamic exception;
  final String message;
}
