import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutty_ds/dimens.dart';
import 'package:flutty_state/logic/submit_cubit.dart';
import 'package:flutty_state/config/flutty_state_config.dart';

class PageContent<T> extends StatelessWidget {
  const PageContent({
    required this.padding,
    required this.child,
    this.stickyBottom,
    this.submitLoader,
    super.key,
  });

  final EdgeInsets? padding;
  final Widget child;
  final Widget? stickyBottom;

  /// Overrides the loader displayed while a submit is in flight.
  ///
  /// When `null`, falls back to [FluttyStateConfig.defaultSubmitLoader] from the
  /// nearest ancestor, then to the default
  /// [LinearProgressIndicator]/[ModalBarrier] combo.
  final Widget? submitLoader;

  @override
  Widget build(BuildContext context) {
    final configLoader =
        FluttyStateConfig.maybeOf(context)?.defaultSubmitLoader;
    final loader = submitLoader ?? configLoader;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: padding ?? EdgeInsets.all(Dimens.standardSpacing),
                child: child,
              ),
            ),
            if (stickyBottom != null) stickyBottom!,
          ],
        ),
        BlocBuilder<SubmitCubit<T>, SubmitState>(
          builder: (context, state) => state is Submitting
              ? loader ?? const _DefaultSubmitLoader()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _DefaultSubmitLoader extends StatelessWidget {
  const _DefaultSubmitLoader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LinearProgressIndicator(),
        Opacity(
          opacity: 0.05,
          child: ModalBarrier(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
