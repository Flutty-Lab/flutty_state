import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutty_ds/dimens.dart';
import 'package:flutty_state/logic/submit_cubit.dart';

class PageContent<T> extends StatelessWidget {
  const PageContent({
    required this.padding,
    required this.child,
    this.stickyBottom,
    this.useCustomScrollView = true,
    super.key,
  });

  final EdgeInsets? padding;
  final Widget child;
  final Widget? stickyBottom;
  final bool useCustomScrollView;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: padding ?? EdgeInsets.all(Dimens.standardSpacing),
                child: useCustomScrollView
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [child],
                      )
                    : child,
              ),
            ),
            if (stickyBottom != null) stickyBottom!,
          ],
        ),
        BlocBuilder<SubmitCubit<T>, SubmitState>(
          builder: (context, state) => state is Submitting
              ? Stack(
                  children: [
                    const LinearProgressIndicator(),
                    Opacity(
                      opacity: 0.05,
                      child: ModalBarrier(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
