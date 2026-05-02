# Flutter Current Extension

This extension contains Flutter code snippets, commands and Quick Fix actions for the [Current State Management package](https://pub.dev/packages/current).

## Snippets

| Trigger         | Content                                                                                                                                                                                              |
| :-------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `currentvm`     | Create a new `CurrentViewModel` <br /><br /> ![currentvm example](https://github.com/thirdversion/flutter_current/raw/main/vscode_extensions/current-flutter-snippets/assets/current_view_model.gif) |
| `currentwidget` | Create a new `CurrentWidget`<br /><br /> ![currentwidget example](https://github.com/thirdversion/flutter_current/raw/main/vscode_extensions/current-flutter-snippets/assets/current_widget.gif)     |

## Code Actions

| Action Name                              | Description                                                                                                                                                                                                                         |
| :--------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Add CurrentTextController Support        | Adds the `CurrentTextControllersLifecycleMixin` to the State class and adds the necessary lifecycle method overrides to properly dispose of any `CurrentTextControllers` created in the widget. (Requires Current 3.0.0 or greater) |
| Scaffold CurrentWidget and ViewModel     | When activated on an empty .dart file, scaffolds a new CurrentWidget and CurrentViewModel with the necessary boilerplate to get started.                                                                                            |
| Add CurrentProperty to currentProps list | When activated on a CurrentProperty, adds the property to the CurrentViewModel's `currentProps` list.                                                                                                                               |
| Add missing CurrentProperties to list    | When activated on the `currentProps` list in a CurrentViewModel, adds any missing CurrentProperty fields to the list.                                                                                                               |
| Convert to CurrentWidget                 | When activated on a regular StatefulWidget or StatelessWidget, converts it to a CurrentWidget.                                                                                                                                      |

## Commands

| Command Name                         | Description                                                                                                                                                                                                                                                                                                                |
| :----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Scaffold CurrentWidget and ViewModel | Prompts you for a file name and design language (material or cupertino) and creates a new CurrentWidget and CurrentViewModel with the necessary boilerplate to get started. If you are using Current 3.0.0 or greater, will also be presented with an option to create a CurrentWidget with CurrentTextController support. |

## Context Menu

When right-clicking on a folder in the VS Explorer pane, there is now an option to create new CurrentWidget and ViewModel files in that folder. This will prompt you for a file name and design language (material or cupertino) and creates a new CurrentWidget and CurrentViewModel with the necessary boilerplate to get started. If you are using Current 3.0.0 or greater, will also be presented with an option to create a CurrentWidget with CurrentTextController support.

## Requirements

Flutter version 3.38.0 or greater.

Minimum supported Current version 2.0.0, however 3.0.0 or greater is recommended to get the most out of this extension as many of the new features of this extension require Current 3.0.0.

## Reporting issues

If you discover any issues with this extension please file an issue on the [Current](https://github.com/thirdversion/flutter_current/issues) repository.

## Release Notes

### 2.0.1

- Move the context menu command to the bottom of the menu to avoid conflicts with other commonly used context menu options like "New File" and "New Folder".

### 2.0.0

- Updated extension name and description to better reflect available features
- Minor updates to existing snippets so the cursor ends up in a more intuitive place after insertion
- Added new Command Palette command to create a new CurrentWidget and View Model. Will prompt you for a file name and design language (material or cupertino). If you are using Current 3.0.0 or greater, will also be presented with an option to create a CurrentWidget with CurrentTextController support.
- Added a Context Menu option when right-clicking on a folder in the VS Explorer pane to create new CurrentWidget and ViewModel files in that folder.
- Added several VS Quick Code Actions have been added. These can be activated using your Quick Fix keyboard shortcut and your cursor is:
  1. On an empty .dart file, scaffold a new CurrentWidget and CurrentViewModel with the necessary boilerplate to get started.
  1. On a CurrentProperty, add the property to the CurrentViewModel's `currentProps` list.
  1. On the `currentProps` list in a CurrentViewModel, add any missing CurrentProperty fields to the list.
  1. On a regular StatefulWidget or StatelessWidget, convert it to a CurrentWidget.
  1. On a CurrentState class declaration, add the `CurrentTextControllersLifecycleMixin` to the class declaration and add the necessary lifecycle method overrides. (Requires Current 3.0.0 or greater)
  1. On a CurrentTextController, bind the controller to a property and add to the bindCurrentControllers method automatically. (Requires Current 3.0.0 or greater)

### 1.0.0

Initial release of Current Flutter Snippets.
