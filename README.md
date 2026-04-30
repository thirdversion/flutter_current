[![CI: Library](https://github.com/thirdversion/flutter_current/actions/workflows/validate_library.yml/badge.svg)](https://github.com/thirdversion/flutter_current/actions/workflows/validate_library.yml)
[![CI: Examples](https://github.com/thirdversion/flutter_current/actions/workflows/validate_examples.yml/badge.svg)](https://github.com/thirdversion/flutter_current/actions/workflows/validate_examples.yml)
[![CI: API Docs](https://github.com/thirdversion/flutter_current/actions/workflows/validate_docs.yml/badge.svg)](https://github.com/thirdversion/flutter_current/actions/workflows/validate_docs.yml)

<p align="center">
  <a href="https://pub.dev/packages/current">
    <img src="https://raw.githubusercontent.com/thirdversion/flutter_current/main/images/CurrentLogoSM.png" alt="Current Logo" />
  </a>
</p>

<h1 align="center">Flutter Current</h1>
<h3 align="center">A simple, lightweight state management library for Flutter</h3>

## Features

- Typed reactive properties for primitives, nullable values, lists, and maps.
- View-model-driven widgets with `CurrentWidget` and `CurrentState`.
- Application-wide shared state with `Current`.
- Issue-based validation that keeps localization in the widget layer.
- Text input binding with `CurrentTextController`, `CurrentTextFormField`, and `CurrentTextField` for form and non-form flows.
- Built-in busy state, change notifications, and event listeners for async flows.

## Getting Started

In your Flutter project, add the dependency to your `pubspec.yaml`.

```yaml
dependencies:
  current: ^3.0.0-beta-1
```

**Tip:** Consider installing the [Current Flutter Snippets](https://marketplace.visualstudio.com/items?itemName=ThirdVersionTechnologyLtd.current-flutter-snippets) extension in Visual Studio Code to make creating Current classes easier.

## Quick Start

A small counter is still the fastest way to see the core pattern: keep state in a `CurrentViewModel`, list reactive properties in `currentProps`, and render that view model through a `CurrentWidget`.

### counter_view_model.dart

```dart
import 'package:current/current.dart';

class CounterViewModel extends CurrentViewModel {
  final count = CurrentProperty.integer();

  void incrementCounter() {
    count.value += 1;
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
        child: Text('Count: ${viewModel.count}'),
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
  final displayName = CurrentProperty.string();
  final age = CurrentProperty.integer();

  // Can define your validation rules in the view model
  // or in a separate validation focused file if that keeps things cleaner and/or easier to test.

  CurrentFieldValidation<String> displayNameValidation(CurrentStringProperty displayName, AppLocalizations intl) {
    return displayName.createValidation(rules: [_displayNameNotEmpty(intl)]);
  }

  CurrentValidationRule<String> _displayNameNotEmpty(AppLocalizations intl) {
    return (value) => value.trim().isEmpty
        ? CurrentValidationIssue.message(intl.displayNameRequired)
        : null;
  }
  
  CurrentFieldValidation<int> ageValidation(CurrentIntegerProperty age) {
    return age.createValidation(rules: [_userIsAdult()]);
CurrentValidationRule<int> _userIsAdult() {
    return (value) => value < 18
        ? const CurrentValidationIssue(
            'profile.age.minimum', // error code if localization is based on codes
            arguments: {'minimumAge': 18},
            fallbackMessage: 'Must be at least 18',
          )
        : null;
  }

  @override
  Iterable<CurrentProperty> get currentProps => [displayName, age];
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

  final _formKey = GlobalKey<FormState>();
  final displayNameController = CurrentTextController.string();
  final ageController = CurrentTextController.integer();

  @override
  void bindCurrentControllers() {
    // Bind each controller to its property, with an optional validation builder.
    // Once the controller is bound and assigned to a CurrentTextFormField, 
    // value parsing, validation, state updates, and error visibility are automatically handled for you.

    displayNameController.bind(
      property: viewModel.displayName,
      lifecycleProvider: this,
      validationBuilder: (property, context) => 
        viewModel.displayNameValidation(property, AppLocalizations.of(context)),
    );

    ageController.bind(
      property: viewModel.age,
      lifecycleProvider: this,
      validationBuilder: (property, _) => viewModel.ageValidation(property),
      validationIssues: CurrentTextControllerValidationIssues(
        invalidValueIssueBuilder: _invalidAgeIssue, // Optional custom message for invalid values
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CurrentTextFormField<String>(
            controller: displayNameController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          CurrentTextFormField<int>(
            controller: ageController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validationTextResolver: _resolveIssueText,
            decoration: const InputDecoration(labelText: 'Age'),
          ),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // Submit the form.
              }
            },
            child: const Text('Save profile'),
          ),
        ],
      ),
    );
  }

  static String? _resolveIssueText(CurrentValidationIssue issue) {
    switch (issue.code) {
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

### Choosing a field widget

Current exposes three field-integration paths. Pick the one that matches who owns your widget tree and validation UX.

- Use `CurrentTextFormField` when you are already inside a `Form` and want the shortest Current-specific wrapper.
- Use native `TextFormField` with `controller.formValidator(...)` when your app already has its own field wrapper or design-system component and you only want Current to provide binding plus validation bridging.
- Use `CurrentTextField` when you are not using Flutter `Form` widgets but still want Current-managed error visibility with `AutovalidateMode`-style behavior.

```dart
CurrentTextFormField<String>(
  controller: displayNameController,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validationTextResolver: _resolveIssueText,
  decoration: const InputDecoration(labelText: 'Display name'),
);

TextFormField(
  controller: ageController,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: ageController.formValidator(
    context: context,
    resolver: _resolveIssueText,
  ),
  decoration: const InputDecoration(labelText: 'Age'),
);

CurrentTextField<String>(
  controller: displayNameController,
  autovalidateMode: AutovalidateMode.onUserInteractionIfError,
  validationTextResolver: _resolveIssueText,
  decoration: const InputDecoration(labelText: 'Quick search'),
);
```

Key points:

- Register validation once, either by calling `createValidation()` directly or by supplying `validationBuilder` when binding a controller.
- Use `CurrentValidationGroup.forProperties([...])` when you want grouped validation without separately listing validators.
- Use `CurrentTextFormField` for the shortest `Form` integration, native `TextFormField` with `controller.formValidator(...)` when your widget layer already exists, and `CurrentTextField` when you want Current-managed validation without a `Form`.
- Let widgets resolve issue text either through a resolver or through `BuildContext` when your localization API requires it.
- Use `CurrentTextControllerValidationIssues` for controller-generated parse or required-value failures.
- Validation rules can live in the widget, the view model, or in a separate plain-Dart helper file when that keeps a larger form easier to read.

## Application Wide State Management

Use `Current` when you want a shared `CurrentViewModel` anywhere below a subtree, or across the whole app.

### application_view_model.dart

```dart
import 'package:current/current.dart';

class ApplicationViewModel extends CurrentViewModel {
  final userName = CurrentProperty.nullableString();
  final signedIn = CurrentProperty.boolean();

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

<p align="center">
  <a href="https://thirdversion.ca">
    <img src="https://raw.githubusercontent.com/thirdversion/flutter_current/main/images/LogoBlackMD.png" alt="Third Version Technology Logo" />
  </a>
</p>

<p align="center">© 2026 Third Version Technology Ltd</p>
