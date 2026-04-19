import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'current_view_model.dart';

///Base class for any widget that needs to be updated when the state of your widget changes.
///
///Requires a class that extends [CurrentViewModel] to be passed to the [viewModel] argument. The
///[CurrentViewModel] is responsible for notifying this widget when the UI needs to be updated.
///By default, [CurrentWidget] also owns the lifecycle of the provided [viewModel] and disposes it
///when the accompanying [CurrentState] is disposed. Set [disposeViewModel] to `false` when using
///an externally managed or shared [CurrentViewModel] instance.
///
///### Usage
///
///```dart
///class MyWidget extends CurrentWidget<MyViewModel> {
///
///    const MyWidget({super.key, required super.viewModel});
///
///    @override
///    CurrentState<CurrentWidget<CurrentViewModel>, MyViewModel> createCurrent() => _MyWidgetState(viewModel);
///
///}
///```
abstract class CurrentWidget<T extends CurrentViewModel>
    extends StatefulWidget {
  final T viewModel;
  final bool debugPrintStateChanges;

  /// Whether this widget owns the lifecycle of the provided [viewModel].
  ///
  /// When true, disposing the [CurrentState] will also dispose the
  /// [CurrentViewModel].
  ///
  /// Set this to false when the [viewModel] is managed externally and should
  /// survive widget disposal so it can be rebound later.
  final bool disposeViewModel;

  const CurrentWidget({
    super.key,
    required this.viewModel,
    this.debugPrintStateChanges = false,
    this.disposeViewModel = true,
  });

  ///Create an instance of [CurrentState] for this widget.
  ///
  ///**IMPORTANT**
  ///This function replaces the default [createState] function. Under the hood, [createCurrent] overrides
  ///the [createState] function. Overriding this function and the [createState] function can have
  ///unintended side affects.
  CurrentState<CurrentWidget, T> createCurrent();

  ///Avoid overriding this function. [createCurrent] handles the creation of the widget state.
  ///Overriding this function can have unintended side affects. You've been warned.
  @mustCallSuper
  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return createCurrent();
  }
}

///Base class for your [CurrentWidget]s accompanying State class.
///
///Will automatically trigger a rebuild when any of this objects accompanying [CurrentViewModel]
///properties change.
///
///### Usage
///
///```dart
///class _CounterPageState extends CurrentState<CounterPage, CounterViewModel> {
///  _CounterPageState(super.viewModel);
///
///  @override
///  Widget build(BuildContext context) {
///    return Scaffold(
///      appBar: AppBar(
///        title: Text(widget.title),
///      ),
///      body: Center(
///        child: Column(
///          mainAxisAlignment: MainAxisAlignment.center,
///          children: <Widget>[
///            const Text(
///              'You have pushed the button this many times:',
///            ),
///            Text(
///              '${viewModel.count}',
///            ),
///          ],
///        ),
///      ),
///      floatingActionButton: FloatingActionButton(
///        onPressed: viewModel.incrementCounter,
///        tooltip: 'Increment',
///        child: const Icon(Icons.add),
///      ),
///    );
///  }
///}
///```
///**IMPORTANT**
///If you expect the parent widget of [T] to cause [T] to rebuild while reusing the same
///[CurrentViewModel] instance, you should either use the Flutter [AutomaticKeepAliveClientMixin]
///on the [CurrentState] implementation or set [CurrentWidget.disposeViewModel] to `false` and manage
///the view model lifecycle yourself. Otherwise, the default owned lifecycle will dispose the view
///model with the state.
///
///For example:
///```dart
///class _CounterPageState extends CurrentState<CounterPage, CounterViewModel> with AutomaticKeepAliveClientMixin {
///  _CounterPageState(super.viewModel);
///
///  @override
///  bool get wantKeepAlive => true;
///
///  @override
///  Widget build(BuildContext context) {
///    super.build(context);
///    return Scaffold(
///     body: Text('Counter: ${viewModel.count}'),
///    );
///  }
///}
abstract class CurrentState<T extends CurrentWidget, E extends CurrentViewModel>
    extends State<T> {
  final E viewModel;
  late final StreamSubscription<CurrentStateChanged> _stateChangedSubscription;

  ///Exposes the [viewModel] busy status. Used to determine if the [viewModel] is busy running
  ///a long running task
  bool get isBusy => viewModel.busy;

  CurrentState(this.viewModel) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          viewModel.assignTo(hashCode);
        }
      },
    );

    _stateChangedSubscription =
        viewModel.addStateChangedListener<CurrentStateChanged>((event) {
      if (widget.debugPrintStateChanges && kDebugMode) {
        // ignore: avoid_print
        print(event);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  ///Can be used to conditionally show another widget if the [viewModel] is busy running a long
  ///running task.
  ///
  ///If the view model is busy, it will show the [busyIndicator] widget. If it is not
  ///busy, it will show the [otherwise] widget.
  Widget ifBusy(Widget busyIndicator, {required Widget otherwise}) {
    return isBusy ? busyIndicator : otherwise;
  }

  @override
  @mustCallSuper
  void dispose() {
    if (widget.disposeViewModel) {
      viewModel.dispose();
    } else {
      viewModel.cancelSubscription(_stateChangedSubscription);
      viewModel.releaseFrom(hashCode);
    }
    super.dispose();
  }
}
