import 'dart:async';

import 'package:current/src/current_exceptions.dart';
import 'package:flutter/foundation.dart';

import 'current_property.dart';

/// Contract for helper objects that need to attach themselves to a
/// [CurrentViewModel] after all [CurrentProperty] values have been initialized.
///
/// Generic helper implementations can be exposed from
/// [CurrentViewModel.currentBindings]. Validation no longer depends on this
/// mechanism in the common path because property-owned validators can
/// register and attach themselves directly.
abstract class CurrentViewModelBinding {
  /// Attaches this helper to its owning [CurrentViewModel].
  ///
  /// This is called automatically from the [CurrentViewModel] constructor after
  /// all [CurrentViewModel.currentProps] have been associated with the view model.
  void attachToViewModel();
}

///A ViewModel is an abstraction of the view it is bound to and represents the current state of
///the data in your model.
///
///This is where any logic that manipulates your model should be. An [CurrentWidget] and it's
///accompanying state always has access to it's view model via the viewModel property.
///
///Update events are automatically emitted whenever the value of an [CurrentProperty] is changed.
///The [CurrentState] the ViewModel is bound to will update itself each time an [CurrentProperty] value
///is changed and call the states build function, updating the UI.
abstract class CurrentViewModel with ChangeNotifier {
  final StreamController<CurrentStateChanged> _stateController =
      StreamController.broadcast();

  final StreamController<ErrorEvent> _errorController =
      StreamController.broadcast();

  final List<StreamSubscription> _subscriptions = [];

  /// Whether any of the properties defined in [currentProps] have a value that is different from their original value.
  ///
  /// This can be used to determine if any changes have been made to the view model since it was last reset or since the [CurrentProperty.originalValue] of the properties were last updated to their current values.
  bool get isDirty {
    for (final prop in currentProps) {
      if (prop.isDirty) return true;
    }
    return false;
  }

  bool _busy = false;

  /// Whether the view model is currently busy performing a long running task. Can be used by the UI to show a loading indicator or prevent user interaction.
  ///
  /// You can use the [setBusy] and [setNotBusy] functions to update this status, or the [doAsync] function to automatically update the busy status while performing a long running task.
  ///
  /// You can also subscribe to changes in the busy status by registering an event handler using the [addBusyStatusChangedListener] function.
  bool get busy => _busy;

  final List<dynamic> _busyTaskKeys = [];
  List<dynamic> get activeTasks => _busyTaskKeys;

  int? _assignedTo;

  /// The [CurrentState] identifier that the view model is currently assigned to
  int? get assignedTo => _assignedTo;

  /// Whether the view model has already been assigned to a [CurrentState]
  ///
  /// This is used to prevent the view model from being assigned to multiple state instances at once.
  bool get assignedToState => _assignedTo != null;

  CurrentViewModel() {
    for (var element in currentProps) {
      element.setViewModel(this);
    }

    for (final binding in currentBindings) {
      binding.attachToViewModel();
    }
  }

  ///Provides a list of [CurrentProperty] fields in the [CurrentViewModel].
  ///
  ///Properties on the implementation must be added to this list in order to be reactive and update the UI on change.
  Iterable<CurrentProperty> get currentProps;

  /// Provides a list of helper bindings that should attach after the view model
  /// has assigned itself to all [currentProps].
  ///
  /// This is useful for helper types that depend on [CurrentProperty.viewModel]
  /// being available before they can subscribe to state changes or emit their
  /// own metadata events.
  ///
  /// This remains the low-level generic extension point for attachable helper
  /// objects. Validation no longer requires overriding this getter in the
  /// common path because validators can register themselves directly on the
  /// property they validate.
  ///
  /// ## Example
  ///
  /// ```dart
  /// class AnalyticsBinding implements CurrentViewModelBinding {
  ///   bool attached = false;
  ///
  ///   @override
  ///   void attachToViewModel() {
  ///     attached = true;
  ///   }
  /// }
  ///
  /// class DashboardViewModel extends CurrentViewModel {
  ///   final title = CurrentStringProperty('Home', propertyName: 'title');
  ///   final analyticsBinding = AnalyticsBinding();
  ///
  ///   @override
  ///   Iterable<CurrentProperty> get currentProps => [title];
  ///
  ///   @override
  ///   Iterable<CurrentViewModelBinding> get currentBindings => [
  ///         analyticsBinding,
  ///       ];
  /// }
  /// ```
  Iterable<CurrentViewModelBinding> get currentBindings => const [];

  ///Creates associates the view model with a specific [CurrentState] via the states hash code.
  ///
  ///This method is called automatically by the [CurrentState] when the view model is assigned to a state.
  ///
  ///**This method should not be called manually.**
  void assignTo(int widgetHash) {
    if (assignedToState && assignedTo != widgetHash) {
      throw CurrentViewModelAlreadyAssignedException(
        StackTrace.current,
        runtimeType,
      );
    }
    _assignedTo = widgetHash;
  }

  /// Releases the current [CurrentState] assignment when it matches the
  /// provided state identifier.
  void releaseFrom(int widgetHash) {
    if (_assignedTo == widgetHash) {
      _assignedTo = null;
    }
  }

  /// Adds an event handler which gets executed each time an event of type [T] is added to the state stream.
  ///
  /// If the optional [filter] function is provided, the event handler will only be executed for events where the [filter] function returns true.
  /// If the optional [propertyName] argument is provided, the event handler will only be executed for events where the [CurrentStateChanged.propertyName] matches the provided [propertyName].
  ///
  /// Note if you provide both a [filter] and [propertyName], the event handler will only be executed for events that satisfy both conditions.
  ///
  /// If an error occurs in the event handler, any event handlers registered with the [addOnErrorEventListener] function will be executed with an [ErrorEvent] containing the error.
  StreamSubscription<T> addStateChangedListener<T extends CurrentStateChanged>(
      void Function(T event) onStateChanged,
      {bool Function(T event)? filter,
      String? propertyName}) {
    final newSubscription = _stateController.stream
        .where((event) => event is T)
        .cast<T>()
        .where((event) {
      if (filter != null && !filter(event)) {
        return false;
      }
      if (propertyName != null && (event).propertyName != propertyName) {
        return false;
      }
      return true;
    }).listen(
      onStateChanged,
      onError: (error) {
        notifyError(ErrorEvent(error));
      },
    );

    _subscriptions.add(newSubscription);

    return newSubscription;
  }

  /// Adds an event handler for all [CurrentStateChanged] events.
  ///
  /// This is a convenience wrapper around [addStateChangedListener] for cases
  /// where the caller does not care about listening to a specific subclass.
  StreamSubscription<CurrentStateChanged> addAnyStateChangedListener(
      void Function(CurrentStateChanged event) onStateChanged,
      {bool Function(CurrentStateChanged event)? filter,
      String? propertyName}) {
    return addStateChangedListener<CurrentStateChanged>(
      onStateChanged,
      filter: filter,
      propertyName: propertyName,
    );
  }

  ///Cancels the subscription. The subscriber will stop receiving events
  Future<void> cancelSubscription(StreamSubscription? subscription) async {
    _subscriptions.remove(subscription);
    await subscription?.cancel();
  }

  ///Adds an event handler which gets executed each time [notifyError] is called.
  ///
  ///You can subscribe to specific error events by providing a type argument [T] that extends [ErrorEvent], or you can listen to all error events by subscribing with the base [ErrorEvent] type.
  ///
  ///You can also provide an optional [onInternalError] callback which will be executed if an error occurs within the event handler itself.
  ///This is useful for preventing unhandled exceptions that occur within the event handler from crashing your application or bubbling the error up to the global Flutter.error handler.
  ///
  ///### Usage (Specific ErrorEvent):
  ///
  ///```dart
  ///viewModel.addOnErrorEventListener<FailedToRecitePi>((error) {
  ///  ScaffoldMessenger.of(context).showSnackBar(
  ///    SnackBar(
  ///      content: Text(error.error),
  ///    ),
  ///  );
  ///});
  ///```
  ///
  ///### Usage (All ErrorEvents):
  ///```dart
  ///viewModel.addOnErrorEventListener((ErrorEvent event) {
  ///  ScaffoldMessenger.of(context).showSnackBar(
  ///    SnackBar(
  ///      content: Text(event.error.toString()),
  ///    ),
  ///  );
  ///});
  ///```
  ///
  StreamSubscription<T> addOnErrorEventListener<T extends ErrorEvent>(
      void Function(T event) onError,
      {void Function(Object error, StackTrace stackTrace)? onInternalError}) {
    final newSubscription = _errorController.stream
        .where((event) => event is T)
        .cast<T>()
        .listen(onError, onError: onInternalError);

    _subscriptions.add(newSubscription);
    return newSubscription;
  }

  /// Adds an event handler for all [ErrorEvent] values
  ///
  /// This is a convenience wrapper around [addOnErrorEventListener] for cases
  /// where the caller wants to observe any error event.
  StreamSubscription<ErrorEvent> addAnyErrorEventListener(
      void Function(ErrorEvent event) onError,
      {void Function(Object error, StackTrace stackTrace)? onInternalError}) {
    return addOnErrorEventListener<ErrorEvent>(
      onError,
      onInternalError: onInternalError,
    );
  }

  ///Inform the bound [CurrentState] that the state of the UI needs to be updated.
  ///
  ///**NOTE**: Although you CAN call this method manually, it's usually not required. Updating the
  ///value of an [CurrentProperty] will automatically notify the UI to update itself.
  void notifyChanges(List<CurrentStateChanged> events) {
    if (_stateController.isClosed) {
      return;
    }

    for (final event in events) {
      _stateController.add(event);
    }

    notifyListeners();
  }

  /// Inform the bound [CurrentState] that the state of the UI needs to be updated with a single event.
  ///
  /// This is a convenience method that allows you to avoid having to create a list when you only have one event to notify.
  /// **NOTE**: Although you CAN call this method manually, it's usually not required. Updating the value of an [CurrentProperty] will automatically notify the UI to update itself.
  /// But if you have a custom event that you'd like to notify the UI of, you can use this method to do so.
  void notifyChange(CurrentStateChanged event) {
    notifyChanges([event]);
  }

  ///Set multiple [CurrentProperty] values, but only trigger a single state change
  ///
  ///The [setters] is a list of maps, where the keys are the properties you want to set, and the values are the new
  ///values for each property. Each map in the list must contain exactly one key/value pair.
  ///
  ///## Usage
  ///
  ///```dart
  ///late final CurrentProperty<String> name;
  ///late final CurrentProperty<int> age;
  ///
  ///setMultiple([
  ///   {name: 'Doug'},
  ///   {age: 45},
  ///]);
  ///```
  void setMultiple(List<Map<CurrentProperty, dynamic>> setters) {
    final List<CurrentStateChanged> changes = [];
    for (var setter in setters) {
      assert(setter.keys.length == 1,
          'Each setter item must contain exactly one key/value pair.');
      final property = setter.keys.first;

      final previousValue = property.value;
      final nextValue = setter.values.first;

      if (!property.hasValueChanged(nextValue, previousValue)) {
        continue;
      }

      changes.add(CurrentStateChanged(nextValue, previousValue,
          propertyName: property.propertyName,
          sourceHashCode: property.sourceHashCode));

      property(nextValue, notifyChange: false);
    }

    if (changes.isNotEmpty) {
      notifyChanges(changes);
    }
  }

  ///Inform the bound [CurrentState] that an error has occurred.
  ///
  ///Any event handlers registered by the
  ///[addOnErrorEventListener] function will be executed
  void notifyError(ErrorEvent event) {
    if (_errorController.isClosed) {
      return;
    }

    _errorController.add(event);

    notifyListeners();
  }

  ///Explicitly updates the current busy status of the view model.
  ///
  ///Can use this in conjunction with the [CurrentState.ifBusy] function on the [CurrentState] to show
  ///a loading indicator when performing a long running task. Can also determine the current busy
  ///status by accessing the [busy] property on the view model.
  ///
  ///See [doAsync] for [busyTaskKey] usage.
  ///
  ///Updating the busy status is automatic when using the [doAsync] function.
  void setBusyStatus({required bool isBusy, dynamic busyTaskKey}) {
    if (_busy != isBusy || busyTaskKey != null) {
      if (isBusy) {
        _addBusyTaskKey(busyTaskKey);
      } else {
        _removeBusyTaskKey(busyTaskKey);
      }
      _busy = _busyTaskKeys.isNotEmpty || isBusy;
      notifyChange(
        BusyStatusChanged(isBusy: _busy, busyTaskKey: busyTaskKey),
      );
    }
  }

  ///Sets the busy status to `true`
  ///
  ///[busyTaskKey] can be optionally set to help identify why the view model is busy. This can then
  ///be accessed by the UI to react differently depending on what the view model is doing.
  void setBusy({dynamic busyTaskKey}) {
    setBusyStatus(isBusy: true, busyTaskKey: busyTaskKey);
  }

  ///Sets the busy status to `false`
  ///
  ///[busyTaskKey] can be optionally set to help identify why the view model is busy. This can then
  ///be accessed by the UI to react differently depending on what the view model is doing.
  void setNotBusy({dynamic busyTaskKey}) {
    setBusyStatus(isBusy: false, busyTaskKey: busyTaskKey);
  }

  ///Executes a long running task asynchronously.
  ///
  ///Automatically sets the view model [busy] status.
  ///
  ///[busyTaskKey] can be optionally set to help identify why the view model is busy. This can then
  ///be accessed by the UI to react differently depending on what the view model is doing.
  ///
  ///Example:
  ///```dart
  ///Future<void> loadUsers() async {
  ///    final users = await doAsync(
  ///      () => userService.getAll(),
  ///      busyTaskKey: 'loadingUsers'
  ///    );
  ///}
  ///```
  Future<T> doAsync<T>(Future<T> Function() work, {dynamic busyTaskKey}) async {
    setBusyStatus(isBusy: true, busyTaskKey: busyTaskKey);

    try {
      final result = await work();
      return result;
    } finally {
      setBusyStatus(isBusy: false, busyTaskKey: busyTaskKey);
    }
  }

  ///Checks if the view model is busy working on a specific task.
  ///
  ///See [doAsync] for [busyTaskKey] usage.
  bool isTaskInProgress(dynamic busyTaskKey) =>
      _busyTaskKeys.contains(busyTaskKey);

  /// Subscribes to changes in the busy status of the view model.
  ///
  /// The [onChanged] callback will be executed each time the busy status changes. If a [busyTaskKey] is provided, the callback will only be executed for changes related to that specific task key.
  ///
  /// **NOTE** Any change to the busy status will trigger a UI update in the bound [CurrentState], regardless of whether you use this function to subscribe to busy status changes or not.
  /// This function is only necessary if you want to perform additional side effects in response to busy status changes.
  StreamSubscription addBusyStatusChangedListener(
      void Function(BusyStatusChanged event) onChanged,
      {dynamic busyTaskKey}) {
    return addStateChangedListener<BusyStatusChanged>(
      onChanged,
      filter: (event) =>
          busyTaskKey == null || event.busyTaskKey == busyTaskKey,
    );
  }

  void _addBusyTaskKey(dynamic busyTaskKey) {
    if (busyTaskKey != null && !_busyTaskKeys.contains(busyTaskKey)) {
      _busyTaskKeys.add(busyTaskKey);
    }
  }

  void _removeBusyTaskKey(dynamic busyTaskKey) {
    if (busyTaskKey != null && _busyTaskKeys.contains(busyTaskKey)) {
      _busyTaskKeys.remove(busyTaskKey);
    }
  }

  ///Resets the value of all properties defined in the [currentProps] list
  ///to their original value.
  ///
  void resetAll() {
    final resetEvents = <CurrentStateChanged>[];
    for (final prop in currentProps) {
      final previousValue = prop.value;
      prop.reset(notifyChange: false);

      resetEvents.add(CurrentStateChanged(
        prop.value,
        previousValue,
        propertyName: prop.propertyName,
        sourceHashCode: prop.sourceHashCode,
      ));
    }

    notifyChanges(resetEvents);
    _busyTaskKeys.clear();
    setNotBusy();
  }

  ///Closes the state and error streams and removes any listeners associated with those streams
  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _errorController.close();
    _stateController.close();
  }
}

///The event that is added to the State stream.
///
///Any event handlers registered with the
///[CurrentViewModel.addStateChangedListener] function will receive these types of events
class CurrentStateChanged<T> {
  final T? previousValue;
  final T? nextValue;
  final String? propertyName;
  final String? description;
  final int? sourceHashCode;

  CurrentStateChanged(this.nextValue, this.previousValue,
      {this.propertyName, this.description, this.sourceHashCode});

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing what value was added to the list
  static CurrentStateChanged addedToList<V>(V newValue,
          {String? propertyName, int? sourceHashCode}) =>
      CurrentStateChanged(newValue, null,
          propertyName: propertyName,
          description: 'Added To List: $newValue',
          sourceHashCode: sourceHashCode);

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing all the values that were added to the list
  static CurrentStateChanged addedAllToList<V>(Iterable<V> newValues,
          {String? propertyName, int? sourceHashCode}) =>
      CurrentStateChanged(newValues, null,
          propertyName: propertyName,
          description: 'Added All To List: $newValues',
          sourceHashCode: sourceHashCode);

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing the value inserted into to the list at the specified index
  static CurrentStateChanged insertIntoList<V>(int index, V value,
          {String? propertyName, int? sourceHashCode}) =>
      CurrentStateChanged(
        value,
        null,
        propertyName: propertyName,
        description: 'Inserted $value into List as index $index',
        sourceHashCode: sourceHashCode,
      );

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing all the values that were inserted into the list at the specified index
  static CurrentStateChanged insertAllIntoList<V>(int index, Iterable<V> values,
          {String? propertyName, int? sourceHashCode}) =>
      CurrentStateChanged(values, null,
          propertyName: propertyName,
          description: 'Inserted All $values into List as index $index',
          sourceHashCode: sourceHashCode);

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing what value was removed from the list
  static CurrentStateChanged removedFromList<V>(V removedValue,
          {String? propertyName, int? sourceHashCode}) =>
      CurrentStateChanged(null, removedValue,
          propertyName: propertyName,
          description: 'Removed From List: $removedValue',
          sourceHashCode: sourceHashCode);

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///stating that the entire list was cleared
  static CurrentStateChanged<Iterable<V>> clearedList<V>(Iterable<V> iterable,
          {String? propertyName, int? sourceHashCode}) =>
      CurrentStateChanged(<V>[], iterable,
          propertyName: propertyName,
          description: 'Iterable Cleared',
          sourceHashCode: sourceHashCode);

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing what new map values were added to another map
  static CurrentStateChanged addedMapToMap<K, V>(Map<K, V> addedMap,
      {String? propertyName, int? sourceHashCode}) {
    return CurrentStateChanged(addedMap, null,
        propertyName: propertyName,
        description: 'Added Map To Map: $addedMap',
        sourceHashCode: sourceHashCode);
  }

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing what key/value was added to the map
  static CurrentStateChanged addedToMap<K, V>(K key, V newValue,
      {String? propertyName, int? sourceHashCode}) {
    final newEntry = MapEntry(key, newValue);
    return CurrentStateChanged(newEntry, null,
        propertyName: propertyName,
        description: 'Added To Map: $newEntry',
        sourceHashCode: sourceHashCode);
  }

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing what [MapEntry] objects were added to the map
  static CurrentStateChanged addedEntriesToMap<K, V>(
      Iterable<MapEntry<K, V>> entries,
      {String? propertyName,
      int? sourceHashCode}) {
    return CurrentStateChanged(entries, null,
        propertyName: propertyName,
        description: 'Added Entries To Map: $entries',
        sourceHashCode: sourceHashCode);
  }

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing what changes were made to a map entry, including for which key
  static CurrentStateChanged<V> updateMapEntry<K, V>(
      K key, V? originalValue, V? nextValue,
      {String? propertyName, int? sourceHashCode}) {
    return CurrentStateChanged<V>(nextValue, originalValue,
        propertyName: propertyName,
        description: 'Update Map Value For Key: $key',
        sourceHashCode: sourceHashCode);
  }

  ///A factory method which creates a single [CurrentStateChanged] object with a description
  ///describing what key/value was removed from the map
  static CurrentStateChanged<V> removedFromMap<K, V>(K key, V? removedValue,
      {String? propertyName, int? sourceHashCode}) {
    final removedEntry = MapEntry(key, removedValue);
    return CurrentStateChanged<V>(null, removedValue,
        propertyName: propertyName,
        description: 'Removed From Map: $removedEntry',
        sourceHashCode: sourceHashCode);
  }

  @override
  String toString() {
    return 'Previous: $previousValue, Next: $nextValue, Property Name: $propertyName, Description: $description';
  }
}

/// Event that is added to the state stream when the busy status of the view model changes.
///
/// Any event handlers registered with the [CurrentViewModel.addBusyStatusChangedListener] function will receive these types of events.
class BusyStatusChanged extends CurrentStateChanged<bool> {
  final dynamic busyTaskKey;
  final bool isBusy;

  BusyStatusChanged({required this.isBusy, super.description, this.busyTaskKey})
      : super(isBusy, !isBusy, propertyName: 'busy');
}

extension CurrentStateChangedExtensions<T> on List<CurrentStateChanged<T>> {
  ///Whether the propertyName on any event matches the [propertyName] argument
  bool containsPropertyName(String propertyName) {
    return map((x) => x.propertyName).contains(propertyName);
  }

  ///Gets the first event where the [CurrentStateChanged.propertyName] matches the
  ///[propertyName] argument
  ///
  ///Returns null if no event is found
  CurrentStateChanged<T>? firstForPropertyName(String propertyName) {
    final events = where((e) => e.propertyName == propertyName);

    return events.isNotEmpty ? events.first : null;
  }

  ///Gets the [CurrentStateChanged.nextValue] for the first event where the [CurrentStateChanged.propertyName]
  ///matches the [propertyName] argument
  T? nextValueFor(String propertyName) {
    return firstForPropertyName(propertyName)?.nextValue;
  }

  ///Gets the [CurrentStateChanged.previousValue] for the first event where the [CurrentStateChanged.propertyName]
  ///matches the [propertyName] argument
  T? previousValueFor(String propertyName) {
    return firstForPropertyName(propertyName)?.previousValue;
  }
}

///The event that is added to the Error stream.
///
///Any event handlers registered with the [CurrentViewModel.addStateChangedListener] or [CurrentViewModel.addAnyStateChangedListener] functions will
///receive these types of events. The [metaData] property can be used to store any additional
///information you may want your error event handler to have access to.
class ErrorEvent<T> {
  final T error;
  final StackTrace? stackTrace;
  final Map<dynamic, dynamic> metaData;

  ///Tries to get a value from the [metaData] map by key.
  ///
  ///Returns `null` if the [key] is not found in the [metaData] map.
  E? getMetaData<E>(dynamic key) {
    if (metaData.containsKey(key)) {
      return metaData[key] as E;
    }
    return null;
  }

  ErrorEvent(this.error, {this.stackTrace, this.metaData = const {}});

  @override
  String toString() =>
      'Exception: ${error.toString()}\nStackTrace: $stackTrace';
}
