# AGENTS.md - flutty_state

Flutter package (`pub.dev: flutty_state`) for ready-to-use page patterns and lightweight state helpers. This package lives in the `flutty_core` workspace.

## Big picture

- Two state systems coexist:
  - Cubit/Bloc flow in `lib/logic/` + `lib/ui/` for async fetch/submit pages.
  - ValueNotifier flow in `lib/src/flutty_notifier.dart` + `lib/src/flutty_builder.dart` for local reactive state.
- Cubit page data-flow:
  - `Repository` -> `DataFetcher/DataSubmitter` (`lib/utils.dart`) -> `FetchCubit<F>` / `SubmitCubit<F>`
  - state emits from `fetch_state.dart` / `submit_state.dart` (`part of` cubits)
  - UI renders through `FetchAndSubmitPage`, `SubmitPage`, and shared `PageContent`.
- `FetchAndSubmitPage` creates `FetchCubit` first and injects it into `SubmitCubit` so `submitAndFetch()` / `submitAndRefresh()` can update fetch state.

## Version-sensitive API (from CHANGELOG)

- `0.3.1`: `FluttyStateConfig` (`lib/src/flutty_state_config.dart`) provides app-wide defaults for `fetchLoader`, `submitLoader`, `onFetchError`, `onSubmitError`. `FetchAndSubmitPage` and `SubmitPage` resolve options in order: page constructor → nearest `FluttyStateConfig` ancestor → built-in default. `FetchCubit` now forwards the exception when emitting `FetchFailed`/`RefreshFailed`.
- `0.3.0`: fetch/submit failures are logged via `dart:developer`; `FetchCubit`, `SubmitCubit`, `FetchAndSubmitPage`, and `SubmitPage` accept optional `onFetchError` / `onSubmitError` callbacks (typedefs `OnFetchError`, `OnSubmitError` in `lib/utils.dart`). `FetchFailed` / `RefreshFailed` now carry the original `exception`.
- `0.2.0`: all three pages (`FetchAndSubmitPage`, `SubmitPage`, `StaticPage`) support `useCustomScrollView` for sliver-compatible layouts.
- `0.2.0`: `SubmitPage.childBuilder` was renamed to `SubmitPage.builder` (aligns with `FetchAndSubmitPage`).
- `0.1.2`: `lib/data/repository.dart` is exported from the barrel (`lib/flutty_state.dart`).

## Key references

- `lib/flutty_state.dart`: canonical barrel export; import package APIs from here.
- `lib/utils.dart`: typedef contracts (`DataFetcher`, `DataSubmitter`, `PageElementWidgetBuilder`, etc.) + snackbar extensions.
- `lib/ui/fetch_and_submit_page.dart`: canonical wiring of fetch+submit cubits and refresh UX.
- `lib/ui/submit_page.dart`: current `builder` API, submit-only flow, snackbar listener.
- `lib/ui/static_page.dart`: minimal page shell with optional custom scroll behavior.
- `lib/data/repository.dart`: abstract repository base (`StreamController` + cache helper).

## Conventions agents should follow

- Keep new fetch/submit states in existing `part of` files: `lib/logic/fetch_state.dart`, `lib/logic/submit_state.dart`.
- Do not add new code under `lib/notifier/`; it is legacy duplicate. Use `lib/src/` instead.
- Always provide user-facing messages in `DataFetchFailed` / `DataSubmitFailed`; do not leak raw exceptions.
- UI layer relies on `flutty_ds` (`Dimens`, `CustomColors`, `ErrorCard`); reuse those instead of re-defining constants/components.
- `SubmitPage` and `FetchAndSubmitPage` disallow using both `stickyBottomBuilder` and `floatingActionButtonBuilder` together (assertion).

## Practical builder signatures

```dart
typedef DataFetcher<F> = Future<DataFetchingResponse<F>> Function();
typedef DataSubmitter<F> = Future<DataSubmitResponse<F>> Function();
typedef SuccessWidgetBuilder<F> = Widget Function(F data, SubmitCubit<F>, BuildContext);
typedef SubmitWidgetBuilder<F> = Widget Function(SubmitCubit<F>, BuildContext);
typedef PageElementWidgetBuilder<F> = Widget Function(F? data, SubmitCubit<F>, BuildContext);
typedef StaticChildBuilder<F> = Widget Function(Widget builtChild, SubmitCubit<F>, BuildContext);
```

## Dev workflows

```bash
flutter test
flutter test test/ui/fetch_and_submit_page_test.dart
cd example && flutter run
```

Widget tests in `test/ui/` usually wrap pages in `MaterialApp` and call `await tester.pumpAndSettle()` after async actions.

## Error monitoring integration

Register `FluttyBlocObserver` at app startup (`lib/logic/flutty_bloc_observer.dart`) to centralize `FetchFailed`, `RefreshFailed`, and `SubmitFailed` reporting.

