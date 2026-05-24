import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutty_state/component/page_content.dart';
import 'package:flutty_state/logic/submit_cubit.dart';
import 'package:flutty_state/config/flutty_state_config.dart';
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
    this.submitLoader,
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

  final bool useCustomScrollView;

  /// Loader shown while a submit triggered from this page is in flight.
  ///
  /// Falls back to [FluttyStateConfig.defaultSubmitLoader] then to the built-in
  /// overlay.
  final Widget? submitLoader;

  /// Called whenever a submit triggered from this page fails.
  ///
  /// Overrides [FluttyStateConfig.defaultOnSubmitError] for this page when
  /// provided.
  final FluttyStateErrorCallback? onSubmitError;

  @override
  Widget build(BuildContext context) {
    final config = FluttyStateConfig.maybeOf(context);
    final resolvedTimeoutError =
        timeoutError ?? config?.defaultTimeoutErrorMessage;
    final resolvedUnexpectedError =
        unexpectedError ?? config?.defaultUnexpectedErrorMessage;
    final resolvedTechnicalError =
        technicalError ?? config?.defaultTechnicalErrorMessage;

    return BlocProvider(
      create: (_) => SubmitCubit<void>(
        timeoutMessage: resolvedTimeoutError,
        unexpectedExceptionMessage: resolvedUnexpectedError,
        technicalErrorMessage: resolvedTechnicalError,
      ),
      child: _SubmitPage(
        builder: builder,
        padding: padding,
        appBarBuilder: appBarBuilder,
        floatingActionButtonBuilder: floatingActionButtonBuilder,
        stickyBottomBuilder: stickyBottomBuilder,
        useCustomScrollView: useCustomScrollView,
        submitLoader: submitLoader,
        onSubmitError: onSubmitError,
      ),
    );
  }
}

class _SubmitPage extends StatelessWidget {
  const _SubmitPage({
    required this.builder,
    required this.submitLoader,
    required this.onSubmitError,
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
  final Widget? submitLoader;
  final FluttyStateErrorCallback? onSubmitError;

  @override
  Widget build(BuildContext context) {
    assert(
      stickyBottomBuilder == null || floatingActionButtonBuilder == null,
      'Sticky bottom and floating action button cannot be used together',
    );

    final submitCubit = context.read<SubmitCubit<void>>();
    final config = FluttyStateConfig.maybeOf(context);
    final resolvedOnSubmitError = onSubmitError ?? config?.defaultOnSubmitError;
    final resolvedPadding = padding ?? config?.defaultPagePadding;

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
              resolvedOnSubmitError?.call(state.failedMessage, state.exception);
            }
          },
          child: PageContent<void>(
            padding: resolvedPadding,
            stickyBottom: stickyBottomBuilder?.call(null, submitCubit, context),
            submitLoader: submitLoader,
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
