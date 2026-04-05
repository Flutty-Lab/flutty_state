import 'package:flutter/material.dart';
import 'package:flutty_ds/dimens.dart';

/// A simple page focused.
///
/// This page provides:
/// - A clean layout for scrollable page
/// - Automatic scroll behavior
/// - Safe area and padding management
///
/// Ideal for simple forms that don't require initial data fetching.
///
/// Example:
/// ```dart
/// StaticPage(
///   pageTitle: Text('Login'),
///   child: LoginForm(),
/// )
/// ```
class StaticPage extends StatelessWidget {
  const StaticPage({
    required this.child,
    this.padding,
    this.appBar,
    this.floatingActionButton,
    this.useCustomScrollView = true,
    super.key,
  });

  final Widget child;
  final EdgeInsets? padding;
  final AppBar? appBar;
  final FloatingActionButton? floatingActionButton;
  final bool useCustomScrollView;

  @override
  Widget build(BuildContext context) => _StaticPage(
        padding: padding,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        useCustomScrollView: useCustomScrollView,
        child: child,
      );
}

class _StaticPage extends StatelessWidget {
  const _StaticPage({
    required this.child,
    required this.padding,
    this.appBar,
    this.floatingActionButton,
    this.useCustomScrollView = true,
  });

  final Widget child;
  final EdgeInsets? padding;
  final AppBar? appBar;
  final FloatingActionButton? floatingActionButton;
  final bool useCustomScrollView;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: Padding(
            padding: padding ?? EdgeInsets.all(Dimens.standardSpacing),
            child: Stack(
              children: [
                useCustomScrollView
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [SliverToBoxAdapter(child: child)],
                      )
                    : child,
              ],
            ),
          ),
        ),
      );
}
