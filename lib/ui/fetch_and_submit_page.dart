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
    this.loader,
    this.loadingFailed,
    this.padding,
    this.appBarBuilder,
    this.staticChildBuilder,
    this.floatingActionButtonBuilder,
    this.stickyBottomBuilder,
    this.timeoutError,
    this.unexpectedError,
    this.technicalError,
    super.key,
  });

  final SuccessWidgetBuilder<F> builder;
  final DataFetcher<F> dataFetcher;
  final Stream<F>? dataUpdatedStream;
  final Widget? loader;
  final Widget? loadingFailed;
  final EdgeInsets? padding;
  final AppBarBuilder<F>? appBarBuilder;
  final StaticChildBuilder<F>? staticChildBuilder;
  final PageElementWidgetBuilder<F>? floatingActionButtonBuilder;
  final PageElementWidgetBuilder<F>? stickyBottomBuilder;
  final String? timeoutError;
  final String? unexpectedError;
  final String? technicalError;

  @override
  Widget build(BuildContext context) {
    final fetchCubit = FetchCubit<F>(
      timeoutMessage: timeoutError,
      unexpectedExceptionMessage: unexpectedError,
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
            timeoutMessage: timeoutError,
            unexpectedExceptionMessage: unexpectedError,
            technicalErrorMessage: technicalError,
          ),
        ),
      ],
      child: _FetchAndSubmitPage(
        dataFetcher: dataFetcher,
        loader: loader,
        loadingFailed: loadingFailed,
        childBuilder: builder,
        padding: padding,
        appBarBuilder: appBarBuilder,
        staticChildBuilder: staticChildBuilder,
        floatingActionButtonBuilder: floatingActionButtonBuilder,
        stickyBottomBuilder: stickyBottomBuilder,
      ),
    );
  }
}

class _FetchAndSubmitPage<F> extends StatelessWidget {
  _FetchAndSubmitPage({
    required this.dataFetcher,
    required this.loader,
    required this.loadingFailed,
    required this.childBuilder,
    this.padding,
    this.appBarBuilder,
    StaticChildBuilder<F>? staticChildBuilder,
    this.floatingActionButtonBuilder,
    this.stickyBottomBuilder,
    super.key,
  }) : _staticChildBuilder = staticChildBuilder ?? ((widget, _, __) => widget);

  final DataFetcher<F> dataFetcher;
  final Widget? loader;
  final Widget? loadingFailed;
  final SuccessWidgetBuilder<F> childBuilder;
  final EdgeInsets? padding;
  final AppBarBuilder<F>? appBarBuilder;
  final StaticChildBuilder<F> _staticChildBuilder;
  final PageElementWidgetBuilder<F>? floatingActionButtonBuilder;
  final PageElementWidgetBuilder<F>? stickyBottomBuilder;

  @override
  Widget build(BuildContext context) {
    assert(
      stickyBottomBuilder == null || floatingActionButtonBuilder == null,
      'Sticky bottom and floating action button cannot be used together',
    );

    return BlocListener<SubmitCubit<F>, SubmitState>(
      listener: (context, state) {
        if (state is SubmitSucceed) {
          context.showSuccessSnackBar(state.successMessage);
        }
        if (state is SubmitFailed) {
          context.showErrorSnackBar(state.failedMessage);
        }
      },
      child: BlocConsumer<FetchCubit<F>, FetchState<F>>(
        listener: (context, state) {
          if (state is RefreshFailed) {
            context.showErrorSnackBar(
              (state as RefreshFailed<F>).failedMessage,
            );
          }
        },
        buildWhen: (_, state) => state is! RefreshState,
        builder: (context, state) {
          final submitCubit = context.read<SubmitCubit<F>>();

          final content = switch (state) {
            FetchFailed() => loadingFailed ??
                Padding(
                  padding: EdgeInsets.all(Dimens.standardSpacing),
                  child: Center(
                    child: ErrorCard(errorMessage: state.failedMessage),
                  ),
                ),
            FetchSucceed<F>() => childBuilder(state.data, submitCubit, context),
            _ => loader ?? const Center(child: RefreshProgressIndicator()),
          };

          final staticChild = _staticChildBuilder(
            content,
            submitCubit,
            context,
          );

          final childWithSliver = switch (state) {
            FetchSucceed<F>() => SliverToBoxAdapter(child: staticChild),
            _ => SliverFillRemaining(hasScrollBody: false, child: staticChild),
          };

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
            padding: padding,
            stickyBottom: stickyBottom,
            floatingActionButton: floatingActionButton,
            child: childWithSliver,
          );
        },
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
    super.key,
  });

  final DataFetcher<F> dataFetcher;
  final AppBar? appBar;
  final EdgeInsets? padding;
  final Widget child;
  final Widget? floatingActionButton;
  final Widget? stickyBottom;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar?.copyWith(
          actions: [
            if (appBar!.actions != null) ...appBar!.actions!,
            if (!kIsWeb && Platform.isWindows)
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
