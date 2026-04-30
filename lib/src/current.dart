import 'package:current/current.dart';
import 'package:flutter/widgets.dart';

///This widget is not intended to be created manually and is used by the [Current] widget.
///
///[viewModel] should contain any properties or functions that any child below this widget need
///access to.
class CurrentApp<T extends CurrentViewModel> extends InheritedWidget {
  const CurrentApp({
    super.key,
    required super.child,
    required this.viewModel,
  });

  final T viewModel;

  @override
  bool updateShouldNotify(covariant CurrentApp oldWidget) => true;
}

///Used to provide shared state and functions across specific scopes of your application, or the
///entire application itself.
///
///The [viewModel] should contain any state or functionality that is required by one or more child
///widgets. See [viewModelOf] for information on accessing the view model.
///
///### Example Using Uuid
///
///```dart
///
///Current(
///  myViewModel,
///  child: HomePage(),
///)
///```
///
///### Nested / Scoped Currents
///
///```dart
///Current(
///  MyApplicationViewModel(),
///  child: MaterialApp(
///   title: 'My App',
///   home: Scaffold(
///     backgroundColor: Current.viewModelOf<MyApplicationViewModel>().backgroundColor.value,
///     child: Current(
///       MyHomePageViewModel(),
///       child: Builder(builder: (innerContext) {
///         return Center(
///           child: Text(${Current.viewModelOf<MyHomePageViewModel>().title.value})
///         );
///       }),
///    )
///   )
///  )
///)
///
///```
class Current<T extends CurrentViewModel> extends StatelessWidget {
  final T viewModel;
  final Widget child;

  const Current(this.viewModel, {required this.child, super.key});

  ///Gets the instance of the [CurrentApp] that matches the generic type argument [T].
  ///
  ///You can access the associated view model via the returned
  ///[CurrentApp]. However you'll most likely want to use the shorthand [viewModelOf] function to do
  ///so.
  static CurrentApp<T> of<T extends CurrentViewModel>(BuildContext context) {
    final CurrentApp<T>? result =
        context.dependOnInheritedWidgetOfExactType<CurrentApp<T>>();
    assert(result != null, 'No Current found in context');
    return result!;
  }

  ///Gets the [CurrentViewModel] from the [CurrentApp] that matches the generic type argument [T].
  ///
  ///This method can be called from any widget
  ///below this one in the widget tree. (Example: from a child widget):
  ///```dart
  ///Current.viewModelOf<MyApplicationViewModel>().logOut();
  ///```
  static T viewModelOf<T extends CurrentViewModel>(BuildContext context) {
    final CurrentApp<T> result = of(context);
    return result.viewModel;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return CurrentApp<T>(
          viewModel: viewModel,
          child: child,
        );
      },
    );
  }
}
