[![CI: Library](https://github.com/thirdversion/flutter_current/actions/workflows/validate_library.yml/badge.svg)](https://github.com/thirdversion/flutter_current/actions/workflows/validate_library.yml)
[![CI: Examples](https://github.com/thirdversion/flutter_current/actions/workflows/validate_examples.yml/badge.svg)](https://github.com/thirdversion/flutter_current/actions/workflows/validate_examples.yml)
[![CI: API Docs](https://github.com/thirdversion/flutter_current/actions/workflows/validate_docs.yml/badge.svg)](https://github.com/thirdversion/flutter_current/actions/workflows/validate_docs.yml)

<a href="https://pub.dev/packages/current">
  <div align="center">
    <img src="https://github.com/thirdversion/flutter_current/blob/main/images/CurrentLogoSM.png?raw=true" alt="Current Logo" />
  </div>
</a>

<h1 align="center">Flutter Current</h1>
<h3 align="center">A simple, lightweight state management library for Flutter</h3>

## Features

- Typed reactive properties for primitives, nullable values, lists, and maps.
- View-model-driven widgets with `CurrentWidget` and `CurrentState`.
- Application-wide shared state with `Current`.
- Issue-based validation that keeps localization in the widget layer.
- Text input binding with `CurrentTextController` for string, integer, and date values.
- Built-in busy state, change notifications, and event listeners for async flows.

## Getting Started

In your Flutter project, add the dependency to your `pubspec.yaml`.

```yaml
dependencies:
  current: ^2.0.2
```

**Tip:** Consider installing the [Current Flutter Snippets](https://marketplace.visualstudio.com/items?itemName=ThirdVersionTechnologyLtd.current-flutter-snippets) extension in Visual Studio Code to make creating Current classes easier.

## Quick Start

A small counter is still the fastest way to see the core pattern: keep state in a `CurrentViewModel`, list reactive properties in `currentProps`, and render that view model through a `CurrentWidget`.

### counter_view_model.dart

```dart
import 'package:current/current.dart';

class CounterViewModel extends CurrentViewModel {
  final count = CurrentProperty.integer(
    initialValue: 0,
    propertyName: 'count',
  );

  void incrementCounter() {
    count.increment();
  }

  @override
  Iterable<CurrentProperty> get currentProps => [count];
}
```

### counter_page.dart

```dart
import 'package:current/current.dart';
import 'package:flutter/material.dart';

class CounterPage extends CurrentWidget<CounterViewModel> {
  const CounterPage({super.key, required super.viewModel});

  @override
  CurrentState<CounterPage, CounterViewModel> createCurrent() {
    return _CounterPageState(viewModel);
  }
}

class _CounterPageState extends CurrentState<CounterPage, CounterViewModel> {
  _CounterPageState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Example')),
      body: Center(
        child: Text('Count: ${viewModel.count.value}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### main.dart

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Current State Example',
      home: CounterPage(
        viewModel: CounterViewModel(),
      ),
    );
  }
}
```

This keeps business logic out of the widget tree without introducing a second state object. When any property in `currentProps` changes, the matching `CurrentState` rebuilds automatically.

## Forms And Validation

Current validation is issue-based. Rules return `CurrentValidationIssue`, not display strings. That keeps validation logic locale-agnostic and lets widgets resolve the final text using whatever localization system the app already uses.

### profile_view_model.dart

```dart
import 'package:current/current.dart';

class ProfileViewModel extends CurrentViewModel {
  final displayName = CurrentProperty.string(
    initialValue: '',
    propertyName: 'displayName',
  );
  final age = CurrentProperty.integer(
    initialValue: 0,
    propertyName: 'age',
  );

  CurrentFieldValidation<String>? _displayNameValidation;
  CurrentFieldValidation<String> get displayNameValidation =>
      _displayNameValidation ??= displayName.createValidation(
        rules: [
          (value) => value.trim().isEmpty
              ? const CurrentValidationIssue(
                  'profile.displayName.required',
                  fallbackMessage: 'Display name is required',
                )
              : null,
        ],
        validateOnPropertyChange: true,
      );

  CurrentFieldValidation<int>? _ageValidation;
  CurrentFieldValidation<int> get ageValidation =>
      _ageValidation ??= age.createValidation(
        rules: [
          (value) => value < 18
              ? const CurrentValidationIssue(
                  'profile.age.minimum',
                  arguments: {'minimumAge': 18},
                  fallbackMessage: 'Must be at least 18',
                )
              : null,
        ],
        validateOnPropertyChange: true,
      );

  CurrentValidationGroup? _profileValidation;
  CurrentValidationGroup get profileValidation =>
      _profileValidation ??= CurrentValidationGroup([
        displayNameValidation,
        ageValidation,
      ]);

  @override
  Iterable<CurrentProperty> get currentProps => [displayName, age];

  @override
  Iterable<CurrentViewModelBinding> get currentBindings => [
        displayNameValidation,
        ageValidation,
      ];
}
```

### profile_page.dart

```dart
import 'package:current/current.dart';
import 'package:flutter/material.dart';

class ProfilePage extends CurrentWidget<ProfileViewModel> {
  const ProfilePage({super.key, required super.viewModel});

  @override
  CurrentState<ProfilePage, ProfileViewModel> createCurrent() {
    return _ProfilePageState(viewModel);
  }
}

class _ProfilePageState extends CurrentState<ProfilePage, ProfileViewModel>
    with CurrentTextControllersLifecycleMixin {
  _ProfilePageState(super.viewModel);

  final displayNameController = CurrentTextController.string();
  final ageController = CurrentTextController.integer();

  @override
  void bindCurrentControllers() {
    displayNameController.bindString(
      property: viewModel.displayName,
      lifecycleProvider: this,
      validation: viewModel.displayNameValidation,
    );

    ageController.bindInt(
      property: viewModel.age,
      lifecycleProvider: this,
      validation: viewModel.ageValidation,
      validationIssues: CurrentTextControllerValidationIssues(
        invalidValueIssueBuilder: _invalidAgeIssue,
      ),
    );
  }

  String? fieldError(CurrentFieldValidation<dynamic> validation) {
    if (validation.hasIssue &&
        (validation.isTouched || validation.hasValidated)) {
      return validation.resolveIssueText(_resolveIssueText);
    }

    return null;
  }

  static String? _resolveIssueText(CurrentValidationIssue issue) {
    switch (issue.code) {
      case 'profile.displayName.required':
        return 'Display name is required.';
      case 'profile.age.minimum':
        return 'Must be at least ${issue.arguments['minimumAge']} years old.';
      case 'profile.age.invalid':
        return 'Enter a valid whole number.';
      default:
        return issue.fallbackMessage;
    }
  }

  static CurrentValidationIssue _invalidAgeIssue(String value) {
    return const CurrentValidationIssue.invalidValue(
      code: 'profile.age.invalid',
      fallbackMessage: 'Enter a valid whole number.',
    );
  }
}
```

Key points:

- Attach validators through `currentBindings` so they can subscribe to view-model changes.
- Can Use memoized getters for `CurrentFieldValidation` and `CurrentValidationGroup`, or `late final`.
- Let widgets resolve issue codes into localized or user-facing text.
- Use `CurrentTextControllerValidationIssues` for controller-generated parse or required-value failures.
- Validation rules can live in the view model or in a separate plain-Dart helper file when that keeps a larger form easier to read.

## Application Wide State Management

Use `Current` when you want a shared `CurrentViewModel` anywhere below a subtree, or across the whole app.

### application_view_model.dart

```dart
import 'package:current/current.dart';

class ApplicationViewModel extends CurrentViewModel {
  final userName = CurrentProperty.nullableString(
    propertyName: 'userName',
  );
  final signedIn = CurrentProperty.boolean(
    propertyName: 'signedIn',
  );

  void signIn(String name) {
    userName.value = name;
    signedIn.value = true;
  }

  @override
  Iterable<CurrentProperty> get currentProps => [userName, signedIn];
}
```

### main.dart

```dart
import 'package:current/current.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Current(
        ApplicationViewModel(),
        onAppStateChanged: () =>
            DateTime.now().microsecondsSinceEpoch.toString(),
        child: Builder(
          builder: (context) {
            final appViewModel = Current.viewModelOf<ApplicationViewModel>(context);
            final userName = appViewModel.userName.value;

            return Column(
              children: [
                Text('User: ${userName ?? 'Guest'}'),
                TextButton(
                  onPressed: () => appViewModel.signIn('Taylor'),
                  child: const Text('Sign In'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

`onAppStateChanged` must return a unique string each time shared state changes. For production apps, a UUID generator is a common choice.

## Explore The Example App

The repository includes a larger showcase app in [example/README.md](example/README.md). It demonstrates typed properties, form validation, controller binding, collection properties, busy state, custom events, and reference snippets in a single responsive mission-control UI.

## Contributing

This is an open source project, and contributions are welcome. Please feel free to [create a new issue](https://github.com/thirdversion/flutter_current/issues/new/choose) if you encounter any problems, or [submit a pull request](https://github.com/thirdversion/flutter_current/pulls). For community contribution guidelines, please review the [Code of Conduct](CODE_OF_CONDUCT.md).

If submitting a pull request, please ensure the following standards are met:

1. Code files must be well formatted with `dart format .`.
2. Tests must pass with `flutter test`. New test cases to validate your changes are highly recommended.
3. Implementations must not add unnecessary project dependencies.
4. Project must contain zero warnings. Running `flutter analyze` must return zero issues.
5. Keep docstrings and README guidance up to date when public APIs change.

## Additional information

This package has **ZERO** third-party package dependencies.

You can find the full API documentation [here](https://pub.dev/documentation/current/latest/).

<br />

<a href="https://thirdversion.ca">
  <div align="center">
    <img src="https://github.com/thirdversion/flutter_current/blob/main/images/LogoBlackMD.png?raw=true" alt="Third Version Technology Logo" />
    <br />
    © 2025 Third Version Technology Ltd
  </div>
</a>
