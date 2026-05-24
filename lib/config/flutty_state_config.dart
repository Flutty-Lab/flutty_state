import 'package:flutter/material.dart';
import 'package:flutty_ds/theme/flutty_material_theme.dart';
import 'package:flutty_ds/theme/flutty_theme_wrapper.dart';
import 'package:flutty_state/logic/fetch_cubit.dart';
import 'package:flutty_state/utils.dart';

/// Provides default widgets and callbacks to descendant `flutty_state`
/// pages such as `FetchAndSubmitPage` and `SubmitPage`.
///
/// Wrap the root of your app with [FluttyStateConfig] to centralize:
///
/// * the loader displayed while data is being fetched ([defaultFetchLoader]),
/// * the loader displayed while a form is being submitted
///   ([defaultSubmitLoader]),
/// * a side-effect callback fired whenever a fetch fails
///   ([defaultOnFetchError]),
/// * a side-effect callback fired whenever a submit fails
///   ([defaultOnSubmitError]).
///
/// Every setting is optional. Pages always honor (in order of priority):
/// 1. an explicit override passed to the page constructor,
/// 2. the value declared on the nearest [FluttyStateConfig] ancestor,
/// 3. the built-in default.
///
/// The widget exposes two ways to declare the wrapped tree:
///
/// ```dart
/// // Plain mode: wrap any subtree.
/// FluttyStateConfig(
///   fetchLoader: const MyLoader(),
///   onFetchError: (message, error) => log(message),
///   child: const MyApp(),
/// );
///
/// // Themed mode: integrates with [FluttyThemeWrapper] from `flutty_ds`.
/// FluttyStateConfig(
///   theme: FluttyMaterialTheme.defaultTheme,
///   mode: ThemeMode.system,
///   appBuilder: (theme, mode) => MaterialApp(
///     theme: theme.toMaterialTheme(),
///     home: const HomePage(),
///   ),
/// );
/// ```
///
/// Pages keep working without any ancestor [FluttyStateConfig] – they simply
/// fall back to their built-in defaults.
class FluttyStateConfig extends StatelessWidget {
  /// Creates a configuration scope around [child].
  ///
  /// Use this constructor to wrap an arbitrary subtree. To integrate with
  /// `flutty_ds`' theme wrapper in a single declaration, pass [theme],
  /// [mode] and [appBuilder] instead of [child].
  FluttyStateConfig({
    super.key,
    this.defaultFetchLoader,
    this.defaultOnFetchError,
    this.defaultFetchFailedBuilder,
    this.defaultSubmitLoader,
    this.defaultOnSubmitError,
    this.defaultPagePadding,
    this.defaultTimeoutErrorMessage,
    this.defaultUnexpectedErrorMessage,
    this.defaultTechnicalErrorMessage,
    Widget? child,
    AppBuilder? appBuilder,
    FluttyMaterialTheme? theme,
    ThemeMode? mode,
  })  : assert(
          child != null || appBuilder != null,
          'FluttyStateConfig requires either a child or an appBuilder.',
        ),
        assert(
          child == null || appBuilder == null,
          'FluttyStateConfig cannot receive both child and appBuilder.',
        ),
        assert(
          appBuilder == null || (theme != null && mode != null),
          'FluttyStateConfig.appBuilder requires both theme and mode.',
        ),
        child = child ??
            FluttyThemeWrapper(
              theme: theme!,
              mode: mode!,
              materialAppBuilder: appBuilder!,
            );

  /// The widget below this scope in the tree.
  ///
  /// When constructed with [appBuilder], this is automatically wired to a
  /// [FluttyThemeWrapper] that forwards `theme` and `mode` to the builder.
  final Widget child;

  /// Default loader rendered by pages during the *initial fetch*.
  ///
  /// Falls back to a centered [RefreshProgressIndicator] when omitted.
  final Widget? defaultFetchLoader;

  /// Default fetch failed widget builder.
  /// Displayed whenever a fetch operation surfaces a failure
  /// ([FetchFailed]).
  ///
  /// Falls back to default error messages ([defaultTimeoutErrorMessage],
  /// [defaultUnexpectedErrorMessage] or [defaultTechnicalErrorMessage]).
  final FailedWidgetBuilder<FetchFailed>? defaultFetchFailedBuilder;

  /// Called whenever a fetch operation surfaces a failure
  /// ([FetchFailed] or [RefreshFailed]).
  ///
  /// Useful to centralize logging or analytics. Pages still display the
  /// failure on screen as usual.
  final FluttyStateErrorCallback? defaultOnFetchError;

  /// Default loader overlay rendered by pages while a submit is in
  /// flight.
  ///
  /// Falls back to a [LinearProgressIndicator] paired with a translucent
  /// [ModalBarrier] when omitted.
  final Widget? defaultSubmitLoader;

  /// Called whenever a submit operation surfaces a failure
  /// ([SubmitFailed]).
  ///
  /// Useful to centralize logging or analytics. Pages still display the
  /// failure on screen as usual.
  final FluttyStateErrorCallback? defaultOnSubmitError;

  /// Default padding used in [fetch_and_submit_page] and [submit_page]
  final EdgeInsets? defaultPagePadding;

  /// Default time out error message [FetchFailed]
  final String? defaultTimeoutErrorMessage;

  /// Default time out error message [FetchFailed]
  final String? defaultUnexpectedErrorMessage;

  /// Default time out error message [FetchFailed]
  final String? defaultTechnicalErrorMessage;

  /// Returns the nearest [FluttyStateConfig] in the widget tree, or `null`
  /// if none is found.
  ///
  /// This lookup intentionally does **not** create a dependency, so widgets
  /// that read configuration once (typically at build time to pick a
  /// fallback builder) will not rebuild when the config changes. A new
  /// [FluttyStateConfig] subtree always provides fresh values to its
  /// descendants because the page widgets re-read the config on every
  /// rebuild.
  static FluttyStateConfig? maybeOf(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<_FluttyStateConfigScope>();
    return scope?.config;
  }

  @override
  Widget build(BuildContext context) {
    return _FluttyStateConfigScope(config: this, child: child);
  }
}

class _FluttyStateConfigScope extends InheritedWidget {
  const _FluttyStateConfigScope({required this.config, required super.child});

  final FluttyStateConfig config;

  @override
  bool updateShouldNotify(_FluttyStateConfigScope oldWidget) =>
      !identical(oldWidget.config, config);
}
