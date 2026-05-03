## 3.0.0-beta-6

- `CurrentTextControllersLifecycleMixin` now automatically tracks and disposes `CurrentTextController` instances when the `dispose` method is called. This eliminates the need to manually call `dispose()` on controllers, reducing boilerplate and the risk of memory leaks.
  - To support backwards compatibility or some case where manual disposal is still desired, `dispose()` on `CurrentTextController` is idempotent, meaning it is safe if you still have manual `dispose()` calls in your existing code.

## 3.0.0-beta-5

**BREAKING CHANGES**

- To eliminate excessive _O(N)_ memory allocations during bulk collection operations (`clear`, `addAll`, `insertAll`, `addEntries`), `CurrentStateChanged` events no longer contain deep clones of the collection by default. The `previousValue` payload will now be `null`. If you need the previous state (e.g., for your own fine-grained Undo feature for example), you must now explicitly opt-in by passing `capturePrevious: true` to these methods.
  - I recognize this could be a real pain for those of you who were relying on the old behavior, but this is a massive improvement for performance and memory efficiency for 99% of use cases, and the opt-in approach doesn't leave you hanging without a path forward if you do need the previous state.
- `CurrentListProperty.where()` and `CurrentListProperty.reversed` now return a lazy `Iterable<T>` instead of eagerly allocating a new `List<T>`. This avoids unnecessary memory allocations and aligns with standard Dart iterable semantics. If you strictly need a `List`, simply append `.toList()` to the call.
  - I also recognize this could be a real pain. Same deal as above, this can result in significant performance and memory improvements for large lists. Plus as mentioned above, it's how standard Dart collections work so it should be more intuitive and less surprising in the long run.

### Performance Improvements

- Fixed a double evaluation performance issue in `CurrentListProperty.firstWhereOrNull`.
- Fixed excessively sending events in `CurrentMapProperty.updateAll` and `CurrentMapProperty.removeWhere`. These methods now emit a single bulk change event instead of spamming the state stream with one event per map entry.

## 3.0.0-beta-4

- Update README to reflect the VS Code extension name change and to highlight the new features of the extension such as Quick Fix actions and Command Palette commands.

## 3.0.0-beta-3

- Update the example app name to reflect the new mission control theme.
- Updated all the platforms in the example app to reflect the new mission control name change
- Updated the example app to better support mobile layouts

## 3.0.0-beta-2

- Further simplified examples in README.
- Add topics to pubspec.yaml for better discoverability on pub.dev.

**BREAKING CHANGE**

- The `CurrentApp` no longer requires or accepts a String unique key, while the `Current` widget no longer requires or accepts an onAppStateChanged callback. These were used to force UI builds on root-level app state changes. This has been replaced with a more idiomatic implementation using `ChangeNotifier` in conjuction with the existing `InheritedWidget` implementation, so the UI will now automatically update on app state changes without any extra work on your part. Please refer to earlier comment about being smarter now 🤯.

## 3.0.0-beta-1

- Updated the minimum Flutter SDK constraint to >=3.38.0
- Added a new `CurrentTextController` API for two-way text/property binding, including `CurrentTextFormField`, `CurrentTextField`, `formValidator(...)`, and controller-managed validation visibility.
- Added a new issue-based validation framework built around `CurrentValidationIssue`, `CurrentValidationState`, `CurrentFieldValidation`, `CurrentValidationGroup`, and property-owned validation registration.
- Added `CurrentProperty` factory constructors, a direct `value` setter, improved busy/event helpers, content-aware dirty tracking for list and map properties, and a full mission-control example app that demonstrates the new APIs end-to-end.

**BREAKING CHANGES**

- State change subscriptions now use typed single-event listeners instead of list-based callbacks. Migrate from `addOnStateChangedListener((List<CurrentStateChanged> events) { ... })` to `addStateChangedListener<T>((T event) { ... })`, or use `addAnyStateChangedListener(...)` when you want the untyped stream.
- `CurrentProperty` equality and `hashCode` are now identity-based. Use `equals(...)` when you want value comparison semantics.
- `CurrentListProperty` and `CurrentMapProperty` dirty tracking now compares collection contents instead of reference identity, which can change `isDirty` behavior for existing apps.
- `CurrentWidget` and `CurrentViewModel` lifecycle semantics changed. View model assignment is now tracked per `CurrentState`, `CurrentWidget` can optionally preserve externally owned view models with `disposeViewModel: false`. A couple years ago we opted to throw and exception if a view model was reassigned to a different widget (whether intentionally or by accident). This was to prevent very difficult to diagnose issues. However we are smarter now 🤯. We've now handed you the keys while still putting guardrails rails up to prevent self inflicted drop kicks. See the updated documentation for details on how to use the new lifecycle features and best practices around view model ownership.

### Added

- Added typed `CurrentProperty` factory constructors for primitive, nullable, list, and map properties.
- Added `CurrentViewModel.isDirty`, `CurrentProperty.isDirty`, `addBusyStatusChangedListener(...)`, `addAnyStateChangedListener(...)`, `addAnyErrorEventListener(...)`, and `notifyChange(...)` helpers.
- Added source tracking metadata to `CurrentStateChanged` events and convenience event types such as `BusyStatusChanged`.
- Added type-safe numeric helper methods such as `addNumber`, `subtractNumber`, `multiplyNumber`, and `modNumber` for int properties.
- Added helper binding infrastructure so property-owned integrations such as validation can attach automatically when a property is assigned to a view model. This opens the door for future property-owned integrations such as analytics, logging, or some other genius idea you have that we haven't even thought of yet (CONTRIBUTORS WELCOME!).

### Example And Docs

- Replaced the simple counter example with a multi-page mission-control showcase covering typed properties, validation, controller binding, collections, busy state, custom events, and code examples.
- Updated the README with forms-and-validation guidance, including when to use `CurrentTextFormField`, native `TextFormField` plus `controller.formValidator(...)`, or `CurrentTextField`.
- Expanded package and example test coverage around controller binding, validation flows, widget lifecycle behavior, collection semantics, and the redesigned example app.

## 2.0.2

- Updated branding images and README (again).

## 2.0.1

- Updated branding images and README.

## 2.0.0

- Rebrand and re-release of Flutter Empire to Flutter Current.

### Why?

- The Founders at Third Version Technology Ltd are the original creators of [Flutter Empire](https://pub.dev/packages/empire) and are no longer affiliated with Strive Business Solutions. Flutter Empire is not being actively maintained and thus we have decided to fork, rebrand and re-release the package under a new name; Flutter Current.
- The name 'Current' and the logo represents the idea of state flowing through your application as you see fit. It also represents the idea of being 'up to date' with the latest state in your application. 🤯
- We decided to carry on the versioning from Flutter Empire to represent the maturity of the package and to show that this is a continuation of the same great package. This also allows us to include the lineage in the change log for transparency.
- Please see the [announcement blog post](https://thirdversion.ca/blog/announcing-flutter-current-fork-and-rebrand-of-flutter-empire) for more details.

## 1.2.0

- Verify during EmpireWidget initialization that the EmpireViewModel being used has not been associated with another EmpireWidget.
  - This is a BREAKING CHANGE. Decided to do this to prevent users from introducing very difficult bugs to diagnose. See [Issue #95](https://github.com/strivesolutions/flutter_empire/issues/95)

## 1.1.0

- Added new insert methods to EmpireListProperty: `insert, insertAll, sublist, insertAtEnd`
- Added toString override to EmpireListProperty to better show what an EmpireListProperty is when logging

## 1.0.0

First official stable release! 🎉

## 0.12.0

- Added new optional argument on EmpireProperty called `setAsOriginal`. Setting this to true will update the original value on change.
- Updated some stale documentation

## 0.11.0

- Fixed the a bug where the `busy` property on an EmpireViewModel returned an incorrect value if there are multiple different busyTaskKeys assigned.
- Added additional functionality to `EmpireListProperty` to bring them closer in line with a plain Dart List object. The following has been added:
  - `first` (read-only property)
  - `last` (read-only property)
  - `reversed` (read-only property)
  - `single` (read-only property)
  - `where` (function)
  - `firstWhere` (function)
  - `firstWhereOrNull` (function)

**BREAKING CHANGES**

We found some issues with the arithmetic operator overrides in the `EmpireIntProperty` and `EmpireDoubleProperty` classes. For details on the issue, please see [GitHub Issue #83](https://github.com/strivesolutions/flutter_empire/issues/83). Ultimately, we had to scrap the operator overrides and implement the arithmetic operations as functions.

- Implemented arithmetic functions for EmpireIntProperty and EmprieDoubleProperty, and their nullable variants
- Removed the operator overrides

We have also made changes to the constructor signature for `EmpireNullableDateTimeProperty` and `EmpireNullableIntProperty`. This was to bring them in line with the other Empire Nullable properties.

- Updated EmpireNullableDateTimeProperty and EmpireNullableIntProperty constructors so the value argument is optional instead of a required positional argument.

## 0.10.0

- Added `resetAll` function to `EmpireViewModel`. This will reset all tracked properties to their original value and trigger a UI update.

## 0.9.1

- Updated README to reflect the new `empireProps` change in the 0.9.0 release.

## 0.9.0

- Added `increment` and `decrement` functions to the `EmpireIntProperty`
- Updated the example project
- Updated README to reflect the property initialization refactor changes
- Added many factory constructors to various Empire Properties. (eg) EmpireDateTimeProperty.now() to create a DateTime property defaulted to the current Date/Time

**BREAKING CHANGES**

- We've redesigned and refactored how you go about initializing an EmpireProperty, and made it more dart-ly (it's a word now).
- Empire Properties in an EmpireViewModel are no longer initialized via a initProperties function that previously needed to be overridden, and was called by the ViewModel constructor behind the scenes. You can now instantiate a property as you would any other Dart object; via it's own constructor.
- There is a new getter List property called `empireProps` that must be overridden in a ViewModel. This should return the Empire Properties that you want to be reactive. (eg) Update the UI on change.
- This change also allowed us to remove the requirement that all Empire Properties be defined with the late keyword.
- This change also allows consumers to inject Empire Properties into the ViewModel.
- Reorganized the library exports

In general, we will avoid major breaking changes if at all possible. In this case, as we approach a stable 1.0.0 release, we felt it was an overall improvement to the library based on valuable user feedback.

## 0.9.0-dev.3

- Changed `props` to `empireProps` on `EmpireViewModel` to prevent naming clashes with other popular packages (eg) Equatable
- Added better exception handling/messaging if you forget to add a property to the `empireProps` list and try to update the property value.

## 0.9.0-dev.2

- Fixed issue where EmpireIntProperty `increment` and `decrement` functions were not updating the UI
- Updated README to reflect the property initialization refactor changes

## 0.9.0-dev.1

- Added `increment` and `decrement` functions to the `EmpireIntProperty`

**BREAKING CHANGES**

- We've redesigned and refactored how you go about initializing an EmpireProperty, and made it more dart-ly(it's a word now).

- Empire Properties in an EmpireViewModel are no longer initialized via a initProperties function that previously needed to be overridden, and was called by the ViewModel constructor behind the scenes. You can now instantiate a property as you would any other Dart object; via it's own constructor.
- This change also allowed us to remove the requirement that all Empire Properties be defined with the late keyword.
- This change also allows consumers to inject Empire Properties into the ViewModel.
- There is a new getter List property called props that must be overridden in a ViewModel. This should return the Empire Properties that you want to be reactive. (eg) Update the UI on change.
- We've also added many factory constructors to various Empire Properties. (eg) EmpireDateTimeProperty.now() to create a DateTime property defaulted to the current Date/Time
- Reorganized the library exports
- Updated the example project

## 0.8.3

- Update package description to make Pub analysis happy

## 0.8.2

- Various code formatting and file structure clean up
- Updated example README

## 0.8.1

- CI Workflow Updates
- Documentation Generation Changes

## 0.8.0

- Initial library launch
