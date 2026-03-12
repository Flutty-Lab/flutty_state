import 'package:flutter/material.dart';
import 'package:flutty_ds/dimens.dart';
import 'package:flutty_ds/theme/color/custom_colors.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/data/data_submit_response.dart';
import 'package:flutty_state/logic/submit_cubit.dart';

typedef DataFetcher<F> = Future<DataFetchingResponse<F>> Function();
typedef DataSubmitter<F> = Future<DataSubmitResponse<F>> Function();
typedef DataOnResponseReceived<F> = void Function(DataSubmitResponse<F>);

typedef SuccessWidgetBuilder<F> = Widget Function(
    F data, SubmitCubit<F> submitter, BuildContext context);

typedef PageElementWidgetBuilder<F> = Widget Function(
    F? data, SubmitCubit<F> submitter, BuildContext context);
typedef AppBarBuilder<F> = AppBar Function(
    F? data, SubmitCubit<F> submitter, BuildContext context);

typedef SubmitWidgetBuilder<F> = Widget Function(
    SubmitCubit<F> submitter, BuildContext context);
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
