import 'package:current/src/current_cloneable.dart';
import 'package:current/src/current_exceptions.dart';

import 'current_view_model.dart';

part 'current_bool_property.dart';
part 'current_int_property.dart';
part 'current_double_property.dart';
part 'current_string_property.dart';
part 'current_map_property.dart';
part 'current_list_property.dart';
part 'current_date_time_property.dart';

///Base class for [CurrentProperty]
abstract class CurrentValue<T> {
  T? get value;
}

///Contains any object that will notify any listeners when its value is changed.
///
///Usually these are properties that are bound to a UI Widget so when the value changes, the UI is updated.
///
///You optionally set the [propertyName] argument to conditionally perform logic when a specific
///property changes. You can access the [propertyName] in any event listener registered with the
///[CurrentViewModel.addOnStateChangedListener] function via the [propertyName] property on an [CurrentStateChanged] object.
///
///If [T] is of type [List] or [Map], use either [CurrentListProperty] or [CurrentMapProperty]. Not doing so
///will prevent the [reset] function from performing as expected.
///
///An [CurrentProperty] is callable. Calling the property updates the value. However, there are two
///ways to update the value of an [CurrentProperty]:
///
///*Using [set]*:
///```dart
/////initialize the property value to zero.
///final age = createProperty<int>(0);
///
/////update the property value to five.
///age.set(5);
///```
///
///-----------------------------------------
///
///*Calling the property*:
///```dart
/////initialize the property value to zero.
///final age = CurrentProperty<int>(0);
///
/////update the property value to five.
///age(5);
///```
class CurrentProperty<T> implements CurrentValue<T> {
  String? propertyName;

  final int sourceHashCode = identityHashCode(Object());

  final bool isPrimitiveType;

  late T _originalValue;
  T get originalValue => _originalValue;

  T _value;

  /// Returns the current value of this [CurrentProperty].
  /// Setting the [value] will update the value of this [CurrentProperty] and trigger a UI update if the new value is different from the current value.
  /// If [T] is a reference type, setting the [value] to a new instance of [T] with the same properties as the current value will still trigger a UI update since the reference has changed.
  ///
  /// Setting the value here will not update the [originalValue]. To update the [originalValue] to the current value, use the [setOriginalValueToCurrent] function, or use the [set] function with the [setAsOriginal] argument set to true.
  @override
  T get value => _value;
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }

    set(newValue, notifyChange: true);
  }

  /// Returns true if the value of this [CurrentProperty] is null.
  ///
  bool get isNull => _value == null;

  /// Returns true if the value of this [CurrentProperty] is not null.
  bool get isNotNull => !isNull;

  /// Returns true if the value of this [CurrentProperty] is different from the [originalValue].
  ///
  /// This can be used to determine if the value has been changed since it was last reset or since the [originalValue] was last updated to the current value.
  bool get isDirty => hasValueChanged(value, originalValue);

  /// Determines whether the current value differs from the original value.
  ///
  /// Specialized property types can override this when their value semantics
  /// differ from the default `==` comparison.
  bool hasValueChanged(T currentValue, T originalValue) =>
      currentValue != originalValue;

  CurrentViewModel? _viewModel;

  /// Returns the instance of the [CurrentViewModel] this
  /// property is associated with.
  ///
  CurrentViewModel get viewModel {
    if (_viewModel == null) {
      throw PropertyNotAssignedToCurrentViewModelException(
          StackTrace.current, propertyName, runtimeType);
    } else {
      return _viewModel!;
    }
  }

  CurrentProperty(
    this._value, {
    this.propertyName,
    this.isPrimitiveType = false,
  }) {
    _originalValue = _value;
  }

  /// Factory constructor for initializing a [CurrentProperty] with a null value.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final name = CurrentProperty.nullable<User>();
  /// ```
  ///
  /// This is just another way to initialize a nullable CurrentProperty. You can also use the [createNullProperty] helper function.
  /// ```dart
  /// final name = CurrentProperty<User?>(null);
  /// ```
  static CurrentProperty<TNullable?> nullable<TNullable>({
    String? propertyName,
  }) {
    return createNullProperty(propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentIntProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to zero if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final age = CurrentProperty.integer();
  /// ```
  ///
  /// This is just another way to initialize a CurrentIntProperty. You can also use the [CurrentIntProperty] constructor directly.
  static CurrentIntProperty integer({
    int initialValue = 0,
    String? propertyName,
  }) {
    return CurrentIntProperty(initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentNullableIntProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to null if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```
  /// final age = CurrentProperty.nullableInteger();
  /// ```
  ///
  /// This is just another way to initialize a CurrentNullableIntProperty. You can also use the [CurrentNullableIntProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final age = CurrentNullableIntProperty();
  /// ```
  static CurrentNullableIntProperty nullableInteger({
    int? initialValue,
    String? propertyName,
  }) {
    return CurrentNullableIntProperty(
        value: initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentDoubleProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to zero if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final price = CurrentProperty.doubleProp();
  /// ```
  ///
  /// This is just another way to initialize a CurrentDoubleProperty. You can also use the [CurrentDoubleProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final price = CurrentDoubleProperty(initialValue: 9.99);
  /// ```
  static CurrentDoubleProperty doubleProp({
    double initialValue = 0.0,
    String? propertyName,
  }) {
    return CurrentDoubleProperty(initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentNullableDoubleProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to null if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart  /// final price = CurrentProperty.nullableDouble();
  /// ```
  ///
  /// This is just another way to initialize a CurrentNullableDoubleProperty. You can also use the [CurrentNullableDoubleProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final price = CurrentNullableDoubleProperty();
  /// ```
  static CurrentNullableDoubleProperty nullableDouble({
    double? initialValue,
    String? propertyName,
  }) {
    return CurrentNullableDoubleProperty(
        value: initialValue, propertyName: propertyName);
  }

  static CurrentNullableDoubleProperty nullableDecimal({
    double? initialValue,
    String? propertyName,
  }) {
    return CurrentNullableDoubleProperty(
        value: initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentStringProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to empty string if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final name = CurrentProperty.string();
  /// ```
  ///
  /// This is just another way to initialize a CurrentStringProperty. You can also use the [CurrentStringProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final name = CurrentStringProperty(initialValue: 'Bob');
  /// ```
  static CurrentStringProperty string({
    String initialValue = '',
    String? propertyName,
  }) {
    return CurrentStringProperty(initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentNullableStringProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to null if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final name = CurrentProperty.nullableString();
  /// ```
  ///
  /// This is just another way to initialize a CurrentNullableStringProperty. You can also use the [CurrentNullableStringProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final name = CurrentNullableStringProperty();
  /// ```
  static CurrentNullableStringProperty nullableString({
    String? initialValue,
    String? propertyName,
  }) {
    return CurrentNullableStringProperty(
        value: initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentBoolProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to false if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isVisible = CurrentProperty.boolean();
  /// ```
  ///
  /// This is just another way to initialize a CurrentBoolProperty. You can also use the [CurrentBoolProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isVisible = CurrentBoolProperty(initialValue: true);
  /// ```
  static CurrentBoolProperty boolean({
    bool initialValue = false,
    String? propertyName,
  }) {
    return CurrentBoolProperty(initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentNullableBoolProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to null if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isVisible = CurrentProperty.nullableBoolean();
  /// ```
  ///
  /// This is just another way to initialize a CurrentNullableBoolProperty. You can also use the [CurrentNullableBoolProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isVisible = CurrentNullableBoolProperty();
  /// ```
  static CurrentNullableBoolProperty nullableBoolean({
    bool? initialValue,
    String? propertyName,
  }) {
    return CurrentNullableBoolProperty(
        value: initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentDateTimeProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to the current date and time if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final createdAt = CurrentProperty.dateTime();
  /// ```
  ///
  /// This is just another way to initialize a CurrentDateTimeProperty. You can also use the [CurrentDateTimeProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final createdAt = CurrentDateTimeProperty(initialValue: DateTime(2024, 1, 1));
  /// ```
  static CurrentDateTimeProperty dateTime({
    DateTime? initialValue,
    String? propertyName,
  }) {
    return CurrentDateTimeProperty(initialValue ?? DateTime.now(),
        propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentNullableDateTimeProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to null if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final createdAt = CurrentProperty.nullableDateTime();
  /// ```
  ///
  /// This is just another way to initialize a CurrentNullableDateTimeProperty. You can also use the [CurrentNullableDateTimeProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final createdAt = CurrentNullableDateTimeProperty();
  /// ```
  static CurrentNullableDateTimeProperty nullableDateTime({
    DateTime? initialValue,
    String? propertyName,
  }) {
    return CurrentNullableDateTimeProperty(
        value: initialValue, propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentListProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to an empty list if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final items = CurrentProperty.list<String>();
  /// ```
  ///
  /// This is just another way to initialize a CurrentListProperty. You can also use the [CurrentListProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final items = CurrentListProperty<String>(['item1', 'item2']);
  /// ```
  static CurrentListProperty<TItem> list<TItem>({
    List<TItem>? initialValue,
    String? propertyName,
  }) {
    return CurrentListProperty<TItem>(initialValue ?? <TItem>[],
        propertyName: propertyName);
  }

  /// Factory constructor for initializing a [CurrentMapProperty].
  ///
  /// Can optionally provide an [initialValue] and [propertyName]. Initial value defaults to an empty map if not provided.
  ///
  /// See [CurrentProperty] for [propertyName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final items = CurrentProperty.map<String, int>();
  /// ```
  ///
  /// This is just another way to initialize a CurrentMapProperty. You can also use the [CurrentMapProperty] constructor directly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final items = CurrentMapProperty<String, int>({'item1': 1, 'item2': 2});
  /// ```
  static CurrentMapProperty<TKey, TValue> map<TKey, TValue>({
    Map<TKey, TValue>? initialValue,
    String? propertyName,
  }) {
    return CurrentMapProperty<TKey, TValue>(initialValue ?? <TKey, TValue>{},
        propertyName: propertyName);
  }

  ///Links this CurrentProperty instance with an [CurrentViewModel].
  ///
  void setViewModel(CurrentViewModel viewModel) {
    _viewModel = viewModel;
  }

  /// Updates the underlying [value] for this CurrentProperty.
  ///
  /// If [notifyChange] is true, a UI update will be triggered after the change occurs. Otherwise,
  /// only the value will be set.
  ///
  /// If [setAsOriginal] is true, updating the value will also set the [originalValue] to the
  /// current value. See also [setOriginalValueToCurrent] and [reset]
  ///
  void call(T value, {bool notifyChange = true, bool setAsOriginal = false}) {
    set(value, notifyChange: notifyChange, setAsOriginal: setAsOriginal);
  }

  ///Updates the original value to what the current value of this property is.
  ///
  ///If this function is called, the [reset] function will then use the updated
  ///original value to set the current value
  ///
  ///## Example
  ///```dart
  ///final user = createNullProperty<User>();
  ///
  ///user(await userService.loadUser());
  ///
  ///user.reset(); //user value would be reset to null
  ///
  ///user(await userService.loadUser());
  ///
  ///user.setOriginalValueToCurrent();
  ///
  ///user(null);
  ///
  ///user.reset(); //user value would be reset to the user returned from the userService
  ///
  ///```
  void setOriginalValueToCurrent() {
    _originalValue = _value;
  }

  ///Updates the property value. Notifies any listeners to the change
  ///
  ///Returns the updated value
  T set(T value, {bool notifyChange = true, bool setAsOriginal = false}) {
    final previousValue = _value;
    _value = value;
    if (notifyChange && previousValue != value) {
      viewModel.notifyChanges([
        CurrentStateChanged(
          value,
          previousValue,
          propertyName: propertyName,
          sourceHashCode: sourceHashCode,
        )
      ]);
    }

    if (setAsOriginal) {
      _originalValue = _value;
    }

    return _value;
  }

  ///Resets the [value] to the [originalValue].
  ///
  ///If [T] is a class with properties, changing the properties directly on the object
  ///instead of updating this CurrentProperty with a new instance of [T] with the updated values will
  ///prevent [reset] from performing as expected. Tracking the original value is done by reference
  ///internally.
  ///
  ///If [T] is a reference type, calling [reset] will update the [value] to the [originalValue] by
  ///reference, causing unexpected behavior. To avoid this, T should implement [CurrentCloneable]
  ///so the [value] will be reset to a deep copy of the [originalValue].
  ///
  ///If [T] is a primitiveType, setting [isPrimitiveType] to true will suppress the warning.
  ///Consider using the typed CurrentProperty classes (eg: [CurrentIntProperty], [CurrentStringProperty])
  ///in place of the generic [CurrentProperty] class for primitives.
  ///
  ///## Usage
  ///
  ///```dart
  ///final age = CurrentProperty<int>(10); //age.value is 10
  ///
  ///age(20); //age.value is 20
  ///age(25); //age.value is 25
  ///
  ///age.reset(); //age.value is back to 10. Triggers UI rebuild or...
  ///
  ///age.reset(notifyChange: false); //age.value is back to 10 but UI does not rebuild
  ///```
  void reset({bool notifyChange = true}) {
    final currentValue = _value;

    if (_originalValue is CurrentCloneable) {
      _value = (_originalValue as CurrentCloneable).clone();
    } else if (isPrimitiveType) {
      _value = _originalValue;
    } else {
      // ignore: avoid_print
      print(
          '[Current] WARNING: $T is not CurrentCloneable and not marked as a primitive type. Reset may result in unexpected behavior. See CurrentProperty.reset documentation for more information.');
      _value = _originalValue;
    }

    if (notifyChange) {
      viewModel.notifyChanges([
        CurrentStateChanged(
          _originalValue,
          currentValue,
          propertyName: propertyName,
          sourceHashCode: sourceHashCode,
        )
      ]);
    }
  }

  @override
  String toString() => _value?.toString() ?? '';

  ///Checks if [other] is equal to the [value] of this CurrentProperty
  ///
  ///### Usage
  ///
  ///```dart
  ///final age = CurrentProperty<int>(10);
  ///
  ///age.equals(10); //returns true
  ///
  ///
  ///final ageTwo = CurrentProperty<int>(10);
  ///
  ///age.equals(ageTwo); //returns true
  ///```
  bool equals(dynamic other) {
    if (other is CurrentProperty) {
      return other.value == value;
    } else {
      return other == value;
    }
  }

  @override
  // ignore: non_nullable_equals_parameter
  bool operator ==(dynamic other) => equals(other);

  @override
  int get hashCode => _value.hashCode;
}

///Short hand helper function for initializing an [CurrentProperty].
///
///See [CurrentProperty] for [propertyName] usages.
///
///## Example
///
///```dart
///late final CurrentProperty<String> name;
///
///name = createProperty('Bob');
///```
CurrentProperty<T> createProperty<T>(T value, {String? propertyName}) {
  return CurrentProperty<T>(value, propertyName: propertyName);
}

///Short hand helper function for initializing an [CurrentProperty] with a null value.
///
///See [CurrentProperty] for [propertyName] usages.
///
///## Example
///
///```dart
///late final CurrentProperty<String?> name;
///
///name = createNullProperty();
///
///```
CurrentProperty<T?> createNullProperty<T>({String? propertyName}) {
  return createProperty(null, propertyName: propertyName);
}
