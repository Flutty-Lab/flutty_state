import 'package:flutter/material.dart';
import 'package:flutty_ds/dimens.dart';
import 'package:flutty_ds/theme/color/custom_colors.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/data/data_submit_response.dart';
import 'package:flutty_state/logic/submit_cubit.dart';

typedef DataFetcher<F> = Future<DataFetchingResponse<F>> Function();
typedef DataSubmitter<F> = Future<DataSubmitResponse<F>> Function();
typedef DataOnResponseReceived<F> = void Function(DataSubmitResponse<F>);

/// Signature for callbacks invoked when a fetch or submit operation fails.
///
/// [message] is the human-readable error message that will be shown to the
/// user. [exception] is the raw error caught by the cubit. It may be `null`
/// if no exception was associated with the failure, and is typed as
/// [Object] because Dart `try`/`catch` can catch any object (not only
/// [Exception]s).
typedef FluttyStateErrorCallback = void Function(
  String message,
  Object? exception,
);

typedef SuccessWidgetBuilder<F> = Widget Function(
    F data, SubmitCubit<F> submitter, BuildContext context);
typedef FailedWidgetBuilder<E> = Widget Function(
    E data, VoidCallback retryFetch, BuildContext context);

typedef PageElementWidgetBuilder<F> = Widget Function(
    F? data, SubmitCubit<F> submitter, BuildContext context);
typedef AppBarBuilderWithData<F> = AppBar Function(
    F? data, SubmitCubit<F> submitter, BuildContext context);
typedef AppBarBuilder = AppBar Function(
    SubmitCubit<void> submitter, BuildContext context);

typedef SubmitWidgetBuilder = Widget Function(
    SubmitCubit<void> submitter, BuildContext context);
typedef StaticChildBuilder<F> = Widget Function(
  Widget builtChild,
  SubmitCubit<F> submitter,
  BuildContext context,
);

extension CustomSnackBar on BuildContext {
  void showSuccessSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: CustomColors.success),
            SizedBox(width: Dimens.standardSpacing),
            Expanded(child: Text(message)),
          ],
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: CustomColors.error),
            SizedBox(width: Dimens.standardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(message)],
              ),
            ),
          ],
        ),
        duration: duration ?? const Duration(seconds: 6),
      ),
    );
  }
}
