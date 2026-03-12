import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/data/data_submit_response.dart';

void main() {
  group('DataSubmitResponse', () {
    test('DataSubmitSucceedEmpty should store message', () {
      const message = 'Success';
      final response = DataSubmitSucceedEmpty(message: message);

      expect(response.message, message);
      expect(response, isA<DataSubmitResponse<void>>());
    });

    test('DataSubmitSucceed should store data and message', () {
      const message = 'Success';
      const data = 'result data';
      final response = DataSubmitSucceed<String>(
        data: data,
        message: message,
      );

      expect(response.message, message);
      expect(response.data, data);
      expect(response, isA<DataSubmitResponse<String>>());
    });

    test('DataSubmitSucceed should work with different types', () {
      final intResponse = DataSubmitSucceed<int>(
        data: 42,
        message: 'Success',
      );
      expect(intResponse.data, 42);

      final listResponse = DataSubmitSucceed<List<int>>(
        data: [1, 2, 3],
        message: 'Success',
      );
      expect(listResponse.data, [1, 2, 3]);
    });

    test('DataSubmitFailed should store message and exception', () {
      const message = 'Failed to submit';
      final exception = Exception('Network error');
      final response = DataSubmitFailed<String>(
        message: message,
        exception: exception,
      );

      expect(response.message, message);
      expect(response.exception, exception);
      expect(response, isA<DataSubmitResponse<String>>());
    });

    test('DataSubmitFailed should work without exception', () {
      const message = 'Failed to submit';
      final response = DataSubmitFailed<String>(message: message);

      expect(response.message, message);
      expect(response.exception, isNull);
    });

    test('DataSubmitResponse should be sealed', () {
      final empty = DataSubmitSucceedEmpty(message: 'ok');
      final succeed = DataSubmitSucceed<int>(data: 1, message: 'ok');
      final failed = DataSubmitFailed<int>(message: 'error');

      expect(empty, isA<DataSubmitResponse<void>>());
      expect(succeed, isA<DataSubmitResponse<int>>());
      expect(failed, isA<DataSubmitResponse<int>>());
    });

    test('should support pattern matching for empty success', () {
      final DataSubmitResponse<void> response =
          DataSubmitSucceedEmpty(message: 'done');

      final result = switch (response) {
        DataSubmitSucceedEmpty(:final message) => 'Empty: $message',
        DataSubmitSucceed(:final message) => 'Data: $message',
        DataSubmitFailed(:final message) => 'Error: $message',
      };

      expect(result, 'Empty: done');
    });

    test('should support pattern matching for success with data', () {
      final DataSubmitResponse<String> response =
          DataSubmitSucceed<String>(data: 'result', message: 'done');

      final result = switch (response) {
        DataSubmitSucceedEmpty(:final message) => 'Empty: $message',
        DataSubmitSucceed(:final data, :final message) =>
          'Data: $data, $message',
        DataSubmitFailed(:final message) => 'Error: $message',
      };

      expect(result, 'Data: result, done');
    });

    test('should support pattern matching for failed case', () {
      final DataSubmitResponse<String> response =
          DataSubmitFailed<String>(message: 'network error');

      final result = switch (response) {
        DataSubmitSucceedEmpty(:final message) => 'Empty: $message',
        DataSubmitSucceed(:final message) => 'Data: $message',
        DataSubmitFailed(:final message) => 'Error: $message',
      };

      expect(result, 'Error: network error');
    });
  });
}
