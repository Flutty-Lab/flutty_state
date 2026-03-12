import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/utils.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/data/data_submit_response.dart';

void main() {
  group('Type definitions', () {
    test('DataFetcher should be a function type', () {
      // ignore: prefer_function_declarations_over_variables
      DataFetcher<String> fetcher = () async {
        return DataFetchSucceed<String>(data: 'test');
      };

      expect(fetcher, isA<Function>());
    });

    test('DataSubmitter should be a function type', () {
      // ignore: prefer_function_declarations_over_variables
      DataSubmitter<String> submitter = () async {
        return DataSubmitSucceed<String>(data: 'test', message: 'ok');
      };

      expect(submitter, isA<Function>());
    });

    test('DataFetcher should return DataFetchingResponse', () async {
      // ignore: prefer_function_declarations_over_variables
      DataFetcher<String> fetcher = () async {
        return DataFetchSucceed<String>(data: 'test');
      };

      final result = await fetcher();
      expect(result, isA<DataFetchingResponse<String>>());
    });

    test('DataSubmitter should return DataSubmitResponse', () async {
      // ignore: prefer_function_declarations_over_variables
      DataSubmitter<String> submitter = () async {
        return DataSubmitSucceed<String>(data: 'test', message: 'ok');
      };

      final result = await submitter();
      expect(result, isA<DataSubmitResponse<String>>());
    });
  });
}
