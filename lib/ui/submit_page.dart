import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutty_state/component/page_content.dart';
import 'package:flutty_state/logic/submit_cubit.dart';
import 'package:flutty_state/utils.dart';

/// A simple page focused on form submission.
///
/// This page provides:
/// - A clean layout for forms
/// - Built-in submission state handling
/// - Loading indicator during submission
/// - Automatic scroll behavior
/// - Safe area and padding management
///
/// Ideal for simple forms that don't require initial data fetching.
///
/// Example:
/// ```dart
/// SubmitPage<LoginData>(
///   pageTitle: Text('Login'),
///   child: LoginForm(),
/// )
/// ```
class SubmitPage extends StatelessWidget {
  const SubmitPage({
    required this.builder,
    this.padding,
    this.appBarBuilder,
    this.floatingActionButtonBuilder,
    this.stickyBottomBuilder,
    this.timeoutError,
    this.unexpectedError,
    this.technicalError,
    this.onSubmitError,
    this.useCustomScrollView = true,
    super.key,
  });

  final SubmitWidgetBuilder builder;
  final EdgeInsets? padding;
  final AppBarBuilder? appBarBuilder;
  final PageElementWidgetBuilder<void>? floatingActionButtonBuilder;
  final PageElementWidgetBuilder<void>? stickyBottomBuilder;
  final String? timeoutError;
  final String? unexpectedError;
  final String? technicalError;

  /// Optional callback invoked on submit exceptions, after the failure has
  /// been logged. Useful to wire in app-level monitoring.
  final OnSubmitError? onSubmitError;

  final bool useCustomScrollView;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SubmitCubit<void>(
          timeoutMessage: timeoutError,
          unexpectedExceptionMessage: unexpectedError,
          technicalErrorMessage: technicalError,
          onSubmitError: onSubmitError,
        ),
        child: _SubmitPage(
          builder: builder,
          padding: padding,
          appBarBuilder: appBarBuilder,
          floatingActionButtonBuilder: floatingActionButtonBuilder,
          stickyBottomBuilder: stickyBottomBuilder,
          useCustomScrollView: useCustomScrollView,
        ),
      );
}

class _SubmitPage extends StatelessWidget {
  const _SubmitPage({
    required this.builder,
    this.padding,
    this.appBarBuilder,
    this.floatingActionButtonBuilder,
    this.stickyBottomBuilder,
    this.useCustomScrollView = true,
  });

  final SubmitWidgetBuilder builder;
  final EdgeInsets? padding;
  final AppBarBuilder? appBarBuilder;
  final PageElementWidgetBuilder<void>? floatingActionButtonBuilder;
  final PageElementWidgetBuilder<void>? stickyBottomBuilder;
  final bool useCustomScrollView;

  @override
  Widget build(BuildContext context) {
    assert(
      stickyBottomBuilder == null || floatingActionButtonBuilder == null,
      'Sticky bottom and floating action button cannot be used together',
    );

    final submitCubit = context.read<SubmitCubit<void>>();

    return Scaffold(
      appBar: appBarBuilder?.call(submitCubit, context),
      floatingActionButton: floatingActionButtonBuilder?.call(
        null,
        submitCubit,
        context,
      ),
      body: SafeArea(
        child: BlocListener<SubmitCubit<void>, SubmitState>(
          listener: (context, state) {
            if (state is SubmitSucceed) {
              context.showSuccessSnackBar(state.successMessage);
            }
            if (state is SubmitFailed) {
              context.showErrorSnackBar(state.failedMessage);
            }
          },
          child: PageContent<void>(
            padding: padding,
            stickyBottom: stickyBottomBuilder?.call(null, submitCubit, context),
            child: useCustomScrollView
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: builder(submitCubit, context),
                      )
                    ],
                  )
                : builder(submitCubit, context),
          ),
        ),
      ),
    );
  }
}
