import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/logic/submit_cubit.dart';

void main() {
  group('SubmitCubit error handling', () {
    test('onSubmitError is optional', () async {
      final cubit = SubmitCubit<void>();
      await cubit.submit(dataSubmitter: () async => throw Exception('boom'));
      expect(cubit.state, isA<SubmitFailed>());
      await cubit.close();
    });
  });
}
