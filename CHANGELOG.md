## 0.3.0

- Log fetch and submit failures via `dart:developer` so exceptions are no longer silent
- Add optional `onFetchError` callback to `FetchCubit` and `FetchAndSubmitPage`
- Add optional `onSubmitError` callback to `SubmitCubit`, `SubmitPage` and `FetchAndSubmitPage`
- Expose `OnFetchError` and `OnSubmitError` typedefs from `utils.dart`
- Add `FailedWidgetBuilder<E>` typedef in `utils.dart` for typed fetch error UI customization
- Propagate the original exception from `DataFetchFailed` to `FetchFailed` / `RefreshFailed` states (already done for `SubmitFailed`) so `FluttyBlocObserver` receives the real exception
- Fix `SubmitCubit.submit` / `submitAndFetch` / `submitAndRefresh` ignoring the caller-provided `timeout` (it was always falling back to the 10s default)
- Replace `FetchAndSubmitPage.loadingFailed` with `fetchFailedBuilder` to provide the fetch failure state and a retry callback when building custom error widgets
- Ensure default fetch error content stays pull-to-refresh compatible by wrapping it in an always-scrollable `CustomScrollView`
- Move custom scroll wrapping to page widgets: `PageContent` now renders the provided child as-is, and `SubmitPage` handles its own `CustomScrollView` sliver wrapping

## 0.2.0

- Add useCustomScrollView parameter to pages (allow to use own scroll view, useful for slivers)
- Rename childBuilder to builder in SubmitPage for consistency with FetchAndSubmitPage
- Remove useless data param from submit_page app bar builder

## 0.1.2

- Export repository

## 0.1.1

- Add all real code from private lib
- Add examples : fetch_and_submit_page, submit_page and static_page

## 0.1.0

- Initial release
