# Current Mission Control Example

This example is a multi-page mission-control showcase for Current. Instead of a simple counter app, it demonstrates how Current handles typed properties, shared app state, issue-based validation, text input binding, collection mutation, custom events, and instructional code snippets inside one responsive Flutter application.

## What The App Demonstrates

- Mission Overview: a guided summary of the main Current capabilities surfaced by the app.
- Telemetry Lab: typed `CurrentProperty` values, dirty tracking, reset behavior, and batched updates.
- Flight Forms: `CurrentTextController`, `CurrentFieldValidation`, `CurrentValidationGroup`, and issue-based validation rules.
- Star Map Collections: reactive `CurrentListProperty` and `CurrentMapProperty` workflows.
- Launch Events: custom `CurrentStateChanged` events, busy state listeners, and `doAsync` task handling.
- Code Examples: smaller reference snippets that mirror the live demos.

## Running The Example

From the `example` folder:

```bash
flutter pub get
flutter run
```

The example is configured for Android, iOS, macOS, Linux, Windows, and web. You can target a specific device the same way you would with any Flutter app, for example `flutter run -d macos` or `flutter run -d chrome`.

## Where To Start

- Open Flight Forms if you want to see the current validation and text-controller APIs in action.
- Open Telemetry Lab if you want a compact tour of the primitive property types and reset semantics.
- Open Launch Events if you want to inspect busy-state handling and custom event listeners.
- Open Code Examples if you want short snippets before reading the package README.

## AI Notice

This example app was created largely by AI. Not because we are lazy, but this allowed us to prove that Current's APIs are intuitive and discoverable enough to be used by an AI with no prior knowledge of the package. What this also means however is the example app may contain unconventional patterns or approaches that an AI might take. If you have any feedback on how the example app is structured or how the APIs are used, please let us know!

## Related Documentation

- Package overview and API usage: [../README.md](../README.md)
- API reference: https://pub.dev/documentation/current/latest/
