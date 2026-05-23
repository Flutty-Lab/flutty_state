import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/data/data_submit_response.dart';
import 'package:flutty_state/logic/submit_cubit.dart';

void main() {
  group('SubmitCubit error handling', () {
    test('submit emits SubmitFailed and invokes onSubmitError on exception',
        () async {
      final captured = <Object>[];
      final cubit = SubmitCubit<void>(
        onSubmitError: (error, _) => captured.add(error),
      );
      final boom = Exception('boom');

      await cubit.submit(dataSubmitter: () async => throw boom);

      expect(cubit.state, isA<SubmitFailed>());
      final state = cubit.state as SubmitFailed;
      expect(state.failedMessage, 'Unexpected error');
      expect(state.exception, boom);
      expect(captured, [boom]);

      await cubit.close();
    });

    test('submit propagates timeout with custom message', () async {
      final captured = <Object>[];
      final cubit = SubmitCubit<void>(
        timeoutMessage: 'Custom timeout',
        onSubmitError: (error, _) => captured.add(error),
      );

      await cubit.submit(
        dataSubmitter: () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return DataSubmitSucceedEmpty(message: 'unreached');
        },
        timeout: const Duration(milliseconds: 1),
      );

      expect(cubit.state, isA<SubmitFailed>());
      final state = cubit.state as SubmitFailed;
      expect(state.failedMessage, 'Custom timeout');
      expect(state.exception, isA<TimeoutException>());
      expect(captured.single, isA<TimeoutException>());

      await cubit.close();
    });

    test('onSubmitError is optional', () async {
      final cubit = SubmitCubit<void>();
      await cubit.submit(dataSubmitter: () async => throw Exception('boom'));
      expect(cubit.state, isA<SubmitFailed>());
      await cubit.close();
    });
  });
}
