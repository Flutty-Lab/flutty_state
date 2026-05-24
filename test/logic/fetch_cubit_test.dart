import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/logic/fetch_cubit.dart';

void main() {
  group('FetchCubit error handling', () {
    test('onFetchError is optional', () async {
      final cubit = FetchCubit<String>();
      await cubit.fetch(dataFetcher: () async => throw Exception('boom'));
      expect(cubit.state, isA<FetchFailed<String>>());
      await cubit.close();
    });
  });
}
