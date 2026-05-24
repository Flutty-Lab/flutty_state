import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutty_ds/cards/error_card.dart';
import 'package:flutty_ds/dimens.dart';
import 'package:flutty_state/component/page_content.dart';
import 'package:flutty_state/logic/fetch_cubit.dart';
import 'package:flutty_state/logic/submit_cubit.dart';
import 'package:flutty_state/config/flutty_state_config.dart';
import 'package:flutty_state/utils.dart';

/// A page that combines data fetching and form submission capabilities.
///
/// This page will:
/// - Automatically fetch data on initialization using [dataFetcher]
/// - Display a loading indicator while fetching
/// - Show error state if fetch fails
/// - Allow manual refresh (pull-to-refresh and refresh button on Windows)
/// - Handle form submissions with loading state
/// - Maintain static content during loading states if [staticChildBuilder] is provided
///
/// Example:
/// ```dart
/// FetchAndSubmitPage<UserData>(
///   pageTitle: Text('User Profile'),
///   dataFetcher: () => getUserData(),
///   builder: (data, context) => UserForm(data: data),
///   staticChildBuilder: (child, context) => Column(children: [Banner(), child]),
/// )
/// ```
class FetchAndSubmitPage<F> extends StatelessWidget {
  const FetchAndSubmitPage({
    required this.builder,
    required this.dataFetcher,
    this.dataUpdatedStream,
    this.appBarBuilder,
    this.staticChildBuilder,
    this.floatingActionButtonBuilder,
    this.stickyBottomBuilder,
    this.useCustomScrollView = true,
    this.padding,
    this.fetchLoader,
    this.onFetchError,
    this.fetchFailedBuilder,
    this.submitLoader,
    this.onSubmitError,
    this.timeoutError,
    this.unexpectedError,
    this.technicalError,
    super.key,
  });

  final SuccessWidgetBuilder<F> builder;
  final DataFetcher<F> dataFetcher;
  final Stream<F>? dataUpdatedStream;

  /// Loader widget shown during the initial fetch.
  ///
  /// Resolution order: this widget, then [FluttyStateConfig.defaultFetchLoader],
  /// then the default centered [RefreshProgressIndicator].
  final Widget? fetchLoader;
  final FailedWidgetBuilder<FetchFailed>? fetchFailedBuilder;

  /// Loader shown while a submit triggered from this page is in flight.
  ///
  /// Falls back to [FluttyStateConfig.defaultSubmitLoader] then to the built-in
  /// overlay.
  final Widget? submitLoader;
  final EdgeInsets? padding;
  final AppBarBuilderWithData<F>? appBarBuilder;
  final StaticChildBuilder<F>? staticChildBuilder;
  final PageElementWidgetBuilder<F>? floatingActionButtonBuilder;
  final PageElementWidgetBuilder<F>? stickyBottomBuilder;
  final String? timeoutError;
  final String? unexpectedError;
  final String? technicalError;

  /// Called whenever the fetch (or refresh) fails on this page.
  ///
  /// Overrides [FluttyStateConfig.defaultOnFetchError] for this page when provided.
  final FluttyStateErrorCallback? onFetchError;

  /// Called whenever a submit triggered from this page fails.
  ///
  /// Overrides [FluttyStateConfig.defaultOnSubmitError] for this page when
  /// provided.
  final FluttyStateErrorCallback? onSubmitError;
  final bool useCustomScrollView;

  @override
  Widget build(BuildContext context) {
    final config = FluttyStateConfig.maybeOf(context);
    final resolvedTimeoutError =
        timeoutError ?? config?.defaultTimeoutErrorMessage;
    final resolvedUnexpectedError =
        unexpectedError ?? config?.defaultUnexpectedErrorMessage;
    final resolvedTechnicalError =
        technicalError ?? config?.defaultTechnicalErrorMessage;

    final fetchCubit = FetchCubit<F>(
      timeoutMessage: resolvedTimeoutError,
      unexpectedExceptionMessage: resolvedUnexpectedError,
      dataUpdatedStream: dataUpdatedStream,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => fetchCubit..fetch(dataFetcher: dataFetcher),
        ),
        BlocProvider(
          create: (_) => SubmitCubit(
            fetchCubit: fetchCubit,
            dataFetcher: dataFetcher,
            timeoutMessage: resolvedTimeoutError,
            unexpectedExceptionMessage: resolvedUnexpectedError,
            technicalErrorMessage: resolvedTechnicalError,
          ),
        ),
      ],
      child: _FetchAndSubmitPage(
        dataFetcher: dataFetcher,
        loader: fetchLoader,
        loadingFailedBuilder: fetchFailedBuilder,
        submitLoader: submitLoader,
        childBuilder: builder,
        padding: padding,
        appBarBuilder: appBarBuilder,
        staticChildBuilder: staticChildBuilder,
        floatingActionButtonBuilder: floatingActionButtonBuilder,
        stickyBottomBuilder: stickyBottomBuilder,
        useCustomScrollView: useCustomScrollView,
        onFetchError: onFetchError,
        onSubmitError: onSubmitError,
      ),
    );
  }
}

class _FetchAndSubmitPage<F> extends StatelessWidget {
  _FetchAndSubmitPage({
    required this.dataFetcher,
    required this.loader,
    required this.loadingFailedBuilder,
    required this.submitLoader,
    required this.childBuilder,
    required this.onFetchError,
    required this.onSubmitError,
    this.padding,
    this.appBarBuilder,
    StaticChildBuilder<F>? staticChildBuilder,
    this.floatingActionButtonBuilder,
    this.stickyBottomBuilder,
    this.useCustomScrollView = true,
    super.key,
  }) : _staticChildBuilder = staticChildBuilder ?? ((widget, _, __) => widget);

  final DataFetcher<F> dataFetcher;
  final Widget? loader;
  final FailedWidgetBuilder<FetchFailed>? loadingFailedBuilder;
  final Widget? submitLoader;
  final SuccessWidgetBuilder<F> childBuilder;
  final EdgeInsets? padding;
  final AppBarBuilderWithData<F>? appBarBuilder;
  final StaticChildBuilder<F> _staticChildBuilder;
  final PageElementWidgetBuilder<F>? floatingActionButtonBuilder;
  final PageElementWidgetBuilder<F>? stickyBottomBuilder;
  final FluttyStateErrorCallback? onFetchError;
  final FluttyStateErrorCallback? onSubmitError;
  final bool useCustomScrollView;

  @override
  Widget build(BuildContext context) {
    assert(
      stickyBottomBuilder == null || floatingActionButtonBuilder == null,
      'Sticky bottom and floating action button cannot be used together',
    );

    final config = FluttyStateConfig.maybeOf(context);
    final resolvedOnFetchError = onFetchError ?? config?.defaultOnFetchError;
    final resolvedOnSubmitError = onSubmitError ?? config?.defaultOnSubmitError;
    final resolvedLoader = loader ?? config?.defaultFetchLoader;
    final resolvedPadding = padding ?? config?.defaultPagePadding;
    final resolvedLoadingFailedBuilder =
        loadingFailedBuilder ?? config?.defaultFetchFailedBuilder;

    return BlocListener<SubmitCubit<F>, SubmitState>(
      listener: (context, state) {
        if (state is SubmitSucceed) {
          context.showSuccessSnackBar(state.successMessage);
        }
        if (state is SubmitFailed) {
          context.showErrorSnackBar(state.failedMessage);
          resolvedOnSubmitError?.call(state.failedMessage, state.exception);
        }
      },
      child: BlocConsumer<FetchCubit<F>, FetchState<F>>(
        listener: (context, state) {
          if (state is FetchFailed<F>) {
            resolvedOnFetchError?.call(state.failedMessage, state.exception);
          }
          if (state is RefreshFailed<F>) {
            context.showErrorSnackBar(state.failedMessage);
            resolvedOnFetchError?.call(state.failedMessage, state.exception);
          }
        },
        buildWhen: (_, state) => state is! RefreshState,
        builder: (context, state) {
          final submitCubit = context.read<SubmitCubit<F>>();

          // Build content based on fetch state
          final content = switch (state) {
            FetchFailed() => resolvedLoadingFailedBuilder?.call(
                    state,
                    () => context
                        .read<FetchCubit<F>>()
                        .fetch(dataFetcher: dataFetcher),
                    context) ??
                _DefaultErrorContent(error: state.failedMessage),
            FetchSucceed<F>() => childBuilder(state.data, submitCubit, context),
            _ =>
              resolvedLoader ?? const Center(child: RefreshProgressIndicator()),
          };

          // Wrapping the content with static child if provided, so that it remains visible during loading states
          final staticChild = _staticChildBuilder(
            content,
            submitCubit,
            context,
          );

          // If fetch failed and no custom error builder is provided, we wrap with CustomScrollView to enable pull-to-refresh. In other cases, we follow the useCustomScrollView flag.
          final isWrappedWithCustomerScrollView = switch (state) {
            FetchFailed<F>() when resolvedLoadingFailedBuilder == null => true,
            _ => useCustomScrollView,
          };

          final wrappedChild = isWrappedWithCustomerScrollView
              ? _CustomScrollView(
                  staticChild: staticChild,
                  useSliverToBoxAdapter: state is FetchSucceed<F>)
              : staticChild;

          // Build app bar, sticky bottom, and floating action button with access to fetched data if available
          final appBar = appBarBuilder?.call(
            state is FetchSucceed<F> ? state.data : null,
            submitCubit,
            context,
          );

          final stickyBottom = stickyBottomBuilder?.call(
            state is FetchSucceed<F> ? state.data : null,
            submitCubit,
            context,
          );

          final floatingActionButton = floatingActionButtonBuilder?.call(
            state is FetchSucceed<F> ? state.data : null,
            submitCubit,
            context,
          );

          return _FetchAndSubmitPageContent(
            dataFetcher: dataFetcher,
            appBar: appBar,
            padding: resolvedPadding,
            stickyBottom: stickyBottom,
            floatingActionButton: floatingActionButton,
            submitLoader: submitLoader,
            child: wrappedChild,
          );
        },
      ),
    );
  }
}

class _CustomScrollView extends StatelessWidget {
  const _CustomScrollView({
    required this.staticChild,
    required this.useSliverToBoxAdapter,
  });

  final Widget staticChild;
  final bool useSliverToBoxAdapter;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (useSliverToBoxAdapter) SliverToBoxAdapter(child: staticChild),
        if (!useSliverToBoxAdapter)
          SliverFillRemaining(hasScrollBody: false, child: staticChild),
      ],
    );
  }
}

class _DefaultErrorContent extends StatelessWidget {
  const _DefaultErrorContent({
    required this.error,
  });

  final String error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.standardSpacing),
      child: Center(
        child: ErrorCard(errorMessage: error),
      ),
    );
  }
}

class _FetchAndSubmitPageContent<F> extends StatelessWidget {
  const _FetchAndSubmitPageContent({
    required this.dataFetcher,
    required this.appBar,
    required this.padding,
    required this.child,
    required this.floatingActionButton,
    required this.stickyBottom,
    required this.submitLoader,
    super.key,
  });

  final DataFetcher<F> dataFetcher;
  final AppBar? appBar;
  final EdgeInsets? padding;
  final Widget child;
  final Widget? floatingActionButton;
  final Widget? stickyBottom;
  final Widget? submitLoader;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar?.copyWith(
          actions: [
            if (appBar!.actions != null) ...appBar!.actions!,
            if (kIsWeb || Platform.isWindows)
              BlocBuilder<FetchCubit<F>, FetchState<F>>(
                builder: (context, state) {
                  if (state is RefreshFetching || state is Fetching) {
                    return const RefreshProgressIndicator(
                      elevation: 0,
                      indicatorMargin: EdgeInsets.zero,
                    );
                  }

                  return IconButton(
                    onPressed: () => context.read<FetchCubit<F>>().refresh(
                          dataFetcher: dataFetcher,
                        ),
                    icon: const Icon(Icons.refresh),
                  );
                },
              ),
          ],
        ),
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () =>
                context.read<FetchCubit<F>>().refresh(dataFetcher: dataFetcher),
            child: PageContent<F>(
              padding: padding,
              stickyBottom: stickyBottom,
              submitLoader: submitLoader,
              child: child,
            ),
          ),
        ),
      );
}

extension AppBarExtension on AppBar {
  AppBar copyWith({
    Widget? leading,
    bool? automaticallyImplyLeading,
    Widget? title,
    List<Widget>? actions,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
    double? elevation,
    double? scrolledUnderElevation,
    ScrollNotificationPredicate? notificationPredicate,
    Color? shadowColor,
    Color? surfaceTintColor,
    ShapeBorder? shape,
    Color? backgroundColor,
    Color? foregroundColor,
    IconThemeData? iconTheme,
    IconThemeData? actionsIconTheme,
    bool? primary,
    bool? centerTitle,
    bool? excludeHeaderSemantics,
    double? titleSpacing,
    double? toolbarOpacity,
    double? bottomOpacity,
    double? toolbarHeight,
    double? leadingWidth,
    TextStyle? toolbarTextStyle,
    TextStyle? titleTextStyle,
    SystemUiOverlayStyle? systemOverlayStyle,
    bool? forceMaterialTransparency,
    Clip? clipBehavior,
    EdgeInsetsGeometry? actionsPadding,
  }) =>
      AppBar(
        leading: leading ?? this.leading,
        automaticallyImplyLeading:
            automaticallyImplyLeading ?? this.automaticallyImplyLeading,
        title: title ?? this.title,
        actions: actions ?? this.actions,
        flexibleSpace: flexibleSpace ?? this.flexibleSpace,
        bottom: bottom ?? this.bottom,
        elevation: elevation ?? this.elevation,
        scrolledUnderElevation:
            scrolledUnderElevation ?? this.scrolledUnderElevation,
        notificationPredicate:
            notificationPredicate ?? this.notificationPredicate,
        shadowColor: shadowColor ?? this.shadowColor,
        surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
        shape: shape ?? this.shape,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
        iconTheme: iconTheme ?? this.iconTheme,
        actionsIconTheme: actionsIconTheme ?? this.actionsIconTheme,
        primary: primary ?? this.primary,
        centerTitle: centerTitle ?? this.centerTitle,
        excludeHeaderSemantics:
            excludeHeaderSemantics ?? this.excludeHeaderSemantics,
        titleSpacing: titleSpacing ?? this.titleSpacing,
        toolbarOpacity: toolbarOpacity ?? this.toolbarOpacity,
        bottomOpacity: bottomOpacity ?? this.bottomOpacity,
        toolbarHeight: toolbarHeight ?? this.toolbarHeight,
        leadingWidth: leadingWidth ?? this.leadingWidth,
        toolbarTextStyle: toolbarTextStyle ?? this.toolbarTextStyle,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
        systemOverlayStyle: systemOverlayStyle ?? this.systemOverlayStyle,
        forceMaterialTransparency:
            forceMaterialTransparency ?? this.forceMaterialTransparency,
        clipBehavior: clipBehavior ?? this.clipBehavior,
        actionsPadding: actionsPadding ?? this.actionsPadding,
      );
}
