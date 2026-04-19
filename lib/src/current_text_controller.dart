import 'dart:async';

import 'package:current/current.dart';
import 'package:current/src/current_exceptions.dart';
import 'package:flutter/material.dart';

/// A TextEditingController that is bound to a CurrentProperty.
///
/// Should apply the [CurrentTextControllersLifecycleMixin] mixin to the State of your Widget to manage the lifecycle of the controller and ensure it is properly disposed of.
///
/// Use the factory contructors to create a new instance.
///
/// [CurrentTextController.string], [CurrentTextController.nullableString],
///
/// [CurrentTextController.integer], [CurrentTextController.nullableInteger],
///
/// [CurrentTextController.date], and [CurrentTextController.nullableDate]
///
/// These are provided for convenience when working with common types, but you can also use [CurrentTextController.of] to create a controller for any type.
///
/// When using [CurrentTextController.of], you must provide the fromString and [asString] functions in the [bind] method to specify how to parse the text into the property's type and how to display the property's value as text.
///
/// It listens for changes to the property and updates the text accordingly, and also updates the property when the text changes.
/// You MUST call [bind] to configure the controller. If you do not, the controller will simply act as a normal [TextEditingController].
///
/// Example usage:
///
///
/// ```dart
///
/// class MyWidgetViewModel extends CurrentViewModel {
///   final name = CurrentStringProperty();
///   final age = CurrentIntProperty();
///   final departureDate = CurrentNullableDateTimeProperty();
///
///   @override
///   Iterable<CurrentProperty> get currentProps => [name, age, departureDate];
/// }
///
/// class _MyWidgetState extends CurrentState<_MyWidgetState, MyWidgetViewModel> with CurrentTextControllersLifecycleMixin {
///
///   final nameController = CurrentTextController.string();
///   final ageController = CurrentTextController.integer();
///   final departureDateController = CurrentTextController.nullableDate();
///
///   @override
///   void bindCurrentControllers() {
///     nameController.bindString(
///       property: viewModel.name,
///       lifecycleProvider: this,
///     );
///     ageController.bindInt(
///       property: viewModel.age,
///       lifecycleProvider: this,
///       defaultValue: 0,
///     );
///     departureDateController.bindDateTime(
///       property: viewModel.departureDate,
///       lifecycleProvider: this,
///       fromString: DateTime.parse,
///     );
///   }
///
///   @override
///   void dispose() {
///     nameController.dispose();
///     ageController.dispose();
///     departureDateController.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         TextField(controller: nameController),
///         TextField(controller: ageController),
///         TextField(controller: departureDateController),
///       ],
///     );
///   }
/// }
/// ```
///
final class CurrentTextController<T> extends TextEditingController {
  /// The [CurrentProperty] that this controller is bound to. This will be set during initialization in the [bind] method.
  ///
  CurrentProperty<T?>? _property;
  CurrentProperty<T?> get property {
    final boundProperty = _property;

    if (boundProperty == null) {
      throw CurrentTextControllerNotInitializedException<T>();
    }

    return boundProperty;
  }

  /// A function that parses a string into the type of the [CurrentProperty]. This is used to update the property's value when the text changes. This will be set during initialization in the [bind] method. If the [CurrentProperty] is of type String, this function can be omitted and the controller will simply use the text as the property's value.
  ///
  T Function(String text)? _fromString;
  T Function(String text)? get fromString => _fromString;

  /// A function that converts the [CurrentProperty]'s value into a string for display in the text field. This will be set during initialization in the [bind] method. If not provided, it will default to using the property's value's toString() method, or an empty string if the property's value is null.
  ///
  String? Function(T? propertyValue)? _asString;
  String? Function(T? propertyValue)? get asString => _asString;

  /// An optional default value to use when parsing the text if the [fromString] function fails to parse the text. This is only used for non-String properties. If the [CurrentProperty] is of type String, this can be omitted since parsing will not be performed.
  ///
  StreamSubscription? _subscription;

  /// An optional default value to use when parsing the text if the [fromString] function fails to parse the text. This is only used for non-String properties. If the [CurrentProperty] is of type String, this can be omitted since parsing will not be performed.
  ///
  T? _defaultValue;
  T? get defaultValue => _defaultValue;

  bool get _isNullable => null is T;

  bool _hasDefaultValue = false;
  bool _isSyncingText = false;
  bool _treatTextAsStringValue = false;

  CurrentTextControllersLifecycleMixin? _lifecycleProvider;

  CurrentTextController._() {
    addListener(_handleTextChanged);
  }

  /// Factory constructor to create a CurrentTextController for a String property.
  ///
  /// **IMPORTANT**: You still must call either the [bind] or the [bindString]
  /// in the [CurrentTextControllersLifecycleMixin.bindCurrentControllers] method to initialize the controller and bind it to a CurrentProperty.
  /// The factory constructor only creates an instance of the controller, but does not configure it in any way.
  static CurrentTextController<String> string() =>
      CurrentTextController<String>._();

  /// Factory constructor to create a CurrentTextController for a nullable String  property.
  ///
  /// **IMPORTANT**: You still must call either the [bind] or the [bindString]
  /// in the [CurrentTextControllersLifecycleMixin.bindCurrentControllers] method to initialize the controller and bind it to a CurrentProperty.
  /// The factory constructor only creates an instance of the controller, but does not configure it in any way.
  static CurrentTextController<String?> nullableString() =>
      CurrentTextController<String?>._();

  /// Factory constructor to create a CurrentTextController for an integer property.
  ///
  /// **IMPORTANT**: You still must call either the [bind] or the [bindInt]
  /// in the [CurrentTextControllersLifecycleMixin.bindCurrentControllers] method to initialize the controller and bind it to a CurrentProperty.
  /// The factory constructor only creates an instance of the controller, but does not configure it in any way.
  static CurrentTextController<int> integer() => CurrentTextController<int>._();

  /// Factory constructor to create a CurrentTextController for a nullable integer property.
  ///
  /// **IMPORTANT**: You still must call either the [bind] or the [bindInt]
  /// in the [CurrentTextControllersLifecycleMixin.bindCurrentControllers] method to initialize the controller and bind it to a CurrentProperty.
  /// The factory constructor only creates an instance of the controller, but does not configure it in any way.
  static CurrentTextController<int?> nullableInteger() =>
      CurrentTextController<int?>._();

  /// Factory constructor to create a CurrentTextController for a DateTime property.
  ///
  /// **IMPORTANT**: You still must call either the [bind] or the [bindDateTime]
  /// in the [CurrentTextControllersLifecycleMixin.bindCurrentControllers] method to initialize the controller and bind it to a CurrentProperty.
  /// The factory constructor only creates an instance of the controller, but does not configure it in any way.
  static CurrentTextController<DateTime> date() =>
      CurrentTextController<DateTime>._();

  /// Factory constructor to create a CurrentTextController for a nullable DateTime property.
  ///
  /// **IMPORTANT**: You still must call either the [bind] or the [bindDateTime]
  /// in the [CurrentTextControllersLifecycleMixin.bindCurrentControllers] method to initialize the controller and bind it to a CurrentProperty.
  /// The factory constructor only creates an instance of the controller, but does not configure it in any way.
  static CurrentTextController<DateTime?> nullableDate() =>
      CurrentTextController<DateTime?>._();

  /// Factory constructor to create a CurrentTextController for a type specified by the generic parameter [T].
  ///
  /// **IMPORTANT**: You still must call either the [bind]
  /// in the [CurrentTextControllersLifecycleMixin.bindCurrentControllers] method to initialize the controller and bind it to a CurrentProperty.
  /// The factory constructor only creates an instance of the controller, but does not configure it in any way.
  static CurrentTextController<T> of<T>() => CurrentTextController<T>._();

  /// Initializes the CurrentTextController by binding it to a CurrentProperty and providing necessary configuration for parsing and displaying the property's value.
  ///
  /// If the CurrentProperty is not of type String, you must provide a fromString function to parse the text into the property's type.
  ///
  /// If it is a Non-Nullable non-String type, you can optionally provide a
  /// [defaultValue]. When the user clears the text field, the controller will
  /// use that explicit default value instead of leaving the property unchanged.
  /// Invalid non-empty text does not throw and does not update the property
  /// until parsing succeeds.
  ///
  /// If the CurrentProperty is of type String, you can omit the fromString function and the controller will simply use the text as the property's value. In this case, providing a defaultValue is not necessary since parsing will not be performed.
  ///
  /// The asString function is optional, but can be used to customize how the property's value is displayed in the text field. If not provided, it will default to using the property's value's toString() method, or an empty string if the property's value is null.
  ///
  void bind({
    required CurrentProperty<T?> property,
    required CurrentTextControllersLifecycleMixin lifecycleProvider,
    T Function(String text)? fromString,
    String? Function(T? propertyValue)? asString,
    T? defaultValue,
  }) {
    final treatTextAsStringValue = _isStringProperty(property);

    if (!treatTextAsStringValue && fromString == null) {
      throw ArgumentError.value(
        fromString,
        'fromString',
        'A fromString function is required for non-String CurrentTextController bindings.',
      );
    }

    if (_matchesBinding(
      property: property,
      lifecycleProvider: lifecycleProvider,
      fromString: fromString,
      asString: asString,
      defaultValue: defaultValue,
      treatTextAsStringValue: treatTextAsStringValue,
    )) {
      return;
    }

    _subscription?.cancel();

    _property = property;
    _fromString = fromString;
    _asString = asString;
    _defaultValue = defaultValue;
    _hasDefaultValue = !_isNullable && defaultValue != null;
    _treatTextAsStringValue = treatTextAsStringValue;
    _lifecycleProvider = lifecycleProvider;

    _subscription =
        property.viewModel.addStateChangedListener<CurrentStateChanged>(
      (_) => _setText(),
      filter: (event) => event.sourceHashCode == property.sourceHashCode,
    );

    _setText();
  }

  /// A convenience method for initializing the controller with properties based on [CurrentProperty<String>]. This is equivalent to calling [bind] with fromString and asString configured for String properties.
  /// If the CurrentProperty is not of type String, this method will throw an exception.
  ///
  void bindString({
    required CurrentProperty<T> property,
    required CurrentTextControllersLifecycleMixin lifecycleProvider,
    String? Function(T? propertyValue)? asString,
  }) {
    (bool isValidType, List<Type> validTypes) validateType(
        CurrentProperty property) {
      final validTypes = [
        CurrentProperty<String>,
        CurrentProperty<String?>,
        CurrentStringProperty,
        CurrentNullableStringProperty
      ];

      // This is done in a verbose way, duplicating the list (unfortunately) to ensure type check safety,
      // guarding against Darts reified generics. Simply checking via `validTypes.any((type) => property.runtimeType == type)`
      // is not guaranteed to behave correctly due to possible type erasure.
      if (property is! CurrentProperty<String> &&
          property is! CurrentProperty<String?> &&
          property is! CurrentStringProperty &&
          property is! CurrentNullableStringProperty) {
        return (false, validTypes);
      }
      return (true, validTypes);
    }

    if (validateType(property) case (false, final validTypes)) {
      throw CurrentTextControllerCurrentPropertyTypeException(
        property,
        'stringController',
        validTypes,
      );
    }

    bind(
      property: property,
      lifecycleProvider: lifecycleProvider,
      asString: asString,
    );
  }

  /// A convenience method for initializing the controller with properties based on [CurrentProperty<int>]. This is equivalent to calling [bind] with fromString and asString configured for int properties.
  /// If the CurrentProperty is not of type int, this method will throw an exception.
  ///
  void bindInt({
    required CurrentProperty<T> property,
    required CurrentTextControllersLifecycleMixin lifecycleProvider,
    T Function(String text)? fromString,
    String? Function(T? propertyValue)? asString,
    T? defaultValue,
  }) {
    (bool isValidType, List<Type> validTypes) validateType(
        CurrentProperty property) {
      final validTypes = [
        CurrentProperty<int>,
        CurrentProperty<int?>,
        CurrentIntProperty,
        CurrentNullableIntProperty
      ];

      // This is done in a verbose way, duplicating the list (unfortunately) to ensure type check safety,
      // guarding against Darts reified generics. Simply checking via `validTypes.any((type) => property.runtimeType == type)`
      // is not guaranteed to behave correctly due to possible type erasure.
      if (property is! CurrentProperty<int> &&
          property is! CurrentProperty<int?> &&
          property is! CurrentIntProperty &&
          property is! CurrentNullableIntProperty) {
        return (false, validTypes);
      }
      return (true, validTypes);
    }

    if (validateType(property) case (false, final validTypes)) {
      throw CurrentTextControllerCurrentPropertyTypeException(
        property,
        'intController',
        validTypes,
      );
    }

    bind(
      property: property,
      lifecycleProvider: lifecycleProvider,
      fromString: fromString ?? (text) => int.parse(text) as T,
      asString: asString,
      defaultValue: defaultValue,
    );
  }

  /// A convenience method for initializing the controller with properties based on [CurrentProperty<DateTime>]. This is equivalent to calling [bind] with fromString and asString configured for DateTime properties.
  /// The [property] must be of type [CurrentProperty<DateTime>], [CurrentDateTimeProperty], or [CurrentNullableDateTimeProperty]. If it is not, this method will throw an exception.
  ///
  void bindDateTime({
    required CurrentProperty<T> property,
    required CurrentTextControllersLifecycleMixin lifecycleProvider,
    required T Function(String text) fromString,
    String? Function(T? propertyValue)? asString,
    T? defaultValue,
  }) {
    (bool isValidType, List<Type> validTypes) validateType(
        CurrentProperty property) {
      final validTypes = [
        CurrentProperty<DateTime>,
        CurrentProperty<DateTime?>,
        CurrentDateTimeProperty,
        CurrentNullableDateTimeProperty
      ];

      // This is done in a verbose way, duplicating the list (unfortunately) to ensure type check safety,
      // guarding against Darts reified generics. Simply checking via `validTypes.any((type) => property.runtimeType == type)`
      // is not guaranteed to behave correctly due to possible type erasure.
      if (property is! CurrentProperty<DateTime> &&
          property is! CurrentProperty<DateTime?> &&
          property is! CurrentDateTimeProperty &&
          property is! CurrentNullableDateTimeProperty) {
        return (false, validTypes);
      }
      return (true, validTypes);
    }

    if (validateType(property) case (false, final validTypes)) {
      throw CurrentTextControllerCurrentPropertyTypeException(
        property,
        'dateController',
        validTypes,
      );
    }

    bind(
      property: property,
      lifecycleProvider: lifecycleProvider,
      fromString: fromString,
      asString: asString ??
          (propertyValue) =>
              (propertyValue as DateTime?)?.toIso8601String() ?? '',
      defaultValue: defaultValue,
    );
  }

  void _setText({bool selectAll = false}) {
    final boundProperty = _property;

    if (boundProperty == null) {
      return;
    }

    final nextText = _asString?.call(boundProperty.value) ??
        boundProperty.value?.toString() ??
        '';

    if (nextText == text) {
      return;
    }

    _isSyncingText = true;

    try {
      value = TextEditingValue(
        text: nextText,
        selection: selectAll && nextText.isNotEmpty
            ? TextSelection(baseOffset: 0, extentOffset: nextText.length)
            : TextSelection.collapsed(offset: nextText.length),
      );
    } finally {
      _isSyncingText = false;
    }
  }

  void _handleTextChanged() {
    final boundProperty = _property;

    if (_isSyncingText || boundProperty == null) {
      return;
    }

    final parseResult = _tryParseText(text);

    if (!parseResult.shouldUpdate &&
        text.isEmpty &&
        !_isNullable &&
        !_hasDefaultValue) {
      _setText(selectAll: true);
      return;
    }

    if (!parseResult.shouldUpdate || parseResult.value == boundProperty.value) {
      return;
    }

    boundProperty.value = parseResult.value;
  }

  ({bool shouldUpdate, T? value}) _tryParseText(String text) {
    if (_treatTextAsStringValue) {
      if (text.isEmpty && _isNullable) {
        return (shouldUpdate: true, value: null);
      }

      return (shouldUpdate: true, value: text as T);
    }

    if (text.isEmpty) {
      if (_isNullable) {
        return (shouldUpdate: true, value: null);
      }

      if (_hasDefaultValue) {
        return (shouldUpdate: true, value: _defaultValue);
      }

      return (shouldUpdate: false, value: null);
    }

    if (_fromString == null) {
      return (shouldUpdate: false, value: null);
    }

    try {
      return (shouldUpdate: true, value: _fromString!(text));
    } catch (_) {
      return (shouldUpdate: false, value: null);
    }
  }

  bool _isStringProperty(CurrentProperty property) {
    return property is CurrentProperty<String> ||
        property is CurrentProperty<String?> ||
        property is CurrentStringProperty ||
        property is CurrentNullableStringProperty;
  }

  bool _matchesBinding({
    required CurrentProperty<T?> property,
    required CurrentTextControllersLifecycleMixin lifecycleProvider,
    required T Function(String text)? fromString,
    required String? Function(T? propertyValue)? asString,
    required T? defaultValue,
    required bool treatTextAsStringValue,
  }) {
    return identical(_property, property) &&
        identical(_lifecycleProvider, lifecycleProvider) &&
        identical(_fromString, fromString) &&
        identical(_asString, asString) &&
        _defaultValue == defaultValue &&
        _hasDefaultValue == (!_isNullable && defaultValue != null) &&
        _treatTextAsStringValue == treatTextAsStringValue;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

/// A mixin for managing the lifecycle of [CurrentTextController]s in a [CurrentState].
///
/// This mixin initializes controllers on the first dependency pass and re-runs
/// [bindCurrentControllers] when the widget updates so controllers can rebind
/// to new properties when needed.
///
/// Must implement [bindCurrentControllers]. This is where you should initialize your [CurrentTextController]s.
mixin CurrentTextControllersLifecycleMixin<TWidget extends CurrentWidget,
    TViewModel extends CurrentViewModel> on CurrentState<TWidget, TViewModel> {
  bool _initializedControllers = false;

  /// Whether the CurrentTextControllers have been initialized. This is used to ensure that the controllers are only initialized once.
  bool get controllersInitialized => _initializedControllers;

  void bindCurrentControllers();

  void _bindOrRebindControllers() {
    bindCurrentControllers();
    _initializedControllers = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!controllersInitialized) {
      _bindOrRebindControllers();
    }
  }

  @override
  void didUpdateWidget(covariant TWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bindOrRebindControllers();
  }
}
