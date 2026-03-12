import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/logic/submit_cubit.dart';

void main() {
  group('SubmitState', () {
    test('SubmitInitial should be a SubmitState', () {
      final state = SubmitInitial();
      expect(state, isA<SubmitState>());
    });

    test('Submitting should be a SubmitState', () {
      final state = Submitting();
      expect(state, isA<SubmitState>());
    });

    test('SubmitSucceed should store success message', () {
      const message = 'Successfully submitted';
      const state = SubmitSucceed(message);

      expect(state.successMessage, message);
      expect(state, isA<SubmitState>());
    });

    test('SubmitSucceed props should include message', () {
      const state1 = SubmitSucceed('success');
      const state2 = SubmitSucceed('success');
      const state3 = SubmitSucceed('different success');

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('SubmitFailed should store message and exception', () {
      const message = 'Failed to submit';
      final exception = Exception('Network error');
      final state = SubmitFailed(message, exception: exception);

      expect(state.failedMessage, message);
      expect(state.exception, exception);
      expect(state, isA<SubmitState>());
    });

    test('SubmitFailed should work without exception', () {
      const message = 'Failed to submit';
      const state = SubmitFailed(message);

      expect(state.failedMessage, message);
      expect(state.exception, isNull);
    });

    test('SubmitFailed props should include message', () {
      const state1 = SubmitFailed('error');
      const state2 = SubmitFailed('error');
      const state3 = SubmitFailed('different error');

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('all states should have empty props by default except those with data',
        () {
      final initial = SubmitInitial();
      final submitting = Submitting();

      expect(initial.props, isEmpty);
      expect(submitting.props, isEmpty);
    });
  });
}
