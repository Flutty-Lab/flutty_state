sealed class DataSubmitResponse<T> {
  DataSubmitResponse({required this.message});

  final String message;
}

class DataSubmitSucceedEmpty extends DataSubmitResponse<void> {
  DataSubmitSucceedEmpty({required super.message});
}

class DataSubmitSucceed<T> extends DataSubmitResponse<T> {
  DataSubmitSucceed({required this.data, required super.message});

  final T data;
}

class DataSubmitFailed<T> extends DataSubmitResponse<T> {
  DataSubmitFailed({required super.message, this.exception});

  final dynamic exception;
}
