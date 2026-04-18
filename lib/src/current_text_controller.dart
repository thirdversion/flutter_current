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
///     nameController.bindString(context: context, property: viewModel.name);
///     ageController.bindInteger(context: context, property: viewModel.age, defaultValue: 0);
///     departureDateController.bindDate(context: context, property: viewModel.departureDate);
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
  late final CurrentProperty<T?> property;

  /// A function that parses a string into the type of the [CurrentProperty]. This is used to update the property's value when the text changes. This will be set during initialization in the [bind] method. If the [CurrentProperty] is of type String, this function can be omitted and the controller will simply use the text as the property's value.
  ///
  late final T Function(String text)? fromString;

  /// A function that converts the [CurrentProperty]'s value into a string for display in the text field. This will be set during initialization in the [bind] method. If not provided, it will default to using the property's value's toString() method, or an empty string if the property's value is null.
  ///
  late final String? Function(T? propertyValue)? asString;

  /// An optional default value to use when parsing the text if the [fromString] function fails to parse the text. This is only used for non-String properties. If the [CurrentProperty] is of type String, this can be omitted since parsing will not be performed.
  ///
  late final StreamSubscription _subscription;

  /// An optional default value to use when parsing the text if the [fromString] function fails to parse the text. This is only used for non-String properties. If the [CurrentProperty] is of type String, this can be omitted since parsing will not be performed.
  ///
  T? defaultValue;

  CurrentTextControllersLifecycleMixin? _lifecycleProvider;

  CurrentTextController._() {
    addListener(() {
      if (_lifecycleProvider == null) {
        throw CurrentTextControllerNotInitializedException<T>();
      }
    });
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
  /// If it is a Non-Nullable non-String type,
  /// you should also provide a [defaultValue]. In the case that [fromString] fails to parse the text, the [defaultValue] will be used instead. If a [defaultValue] is not provided
  /// and parsing fails, an exception will be thrown.
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
    _lifecycleProvider = lifecycleProvider;

    if (_lifecycleProvider?.controllersInitialized ?? false) {
      throw CurrentTextControllerAlreadyInitializedException(property);
    }

    this.property = property;
    this.fromString = fromString;
    this.asString = asString;

    addListener(() {
      final value = _tryParseText(text);

      if (value == property.value) {
        return;
      }

      property.set(value);
    });

    _subscription = property.viewModel.addStateChangedListener(
      (event) {
        if (event != null) {
          _setText();
        }
      },
      filter: (CurrentStateChanged? event) =>
          event?.sourceHashCode == property.hashCode,
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
        CurrentStringProperty,
        CurrentNullableStringProperty
      ];

      // This is done in a verbose way, duplicating the list (unfortunately) to ensure type check safety,
      // guarding against Darts reified generics. Simply checking via `validTypes.any((type) => property.runtimeType == type)`
      // is not guaranteed to behave correctly due to possible type erasure.
      if (property is! CurrentProperty<String> &&
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
        CurrentIntProperty,
        CurrentNullableIntProperty
      ];

      // This is done in a verbose way, duplicating the list (unfortunately) to ensure type check safety,
      // guarding against Darts reified generics. Simply checking via `validTypes.any((type) => property.runtimeType == type)`
      // is not guaranteed to behave correctly due to possible type erasure.
      if (property is! CurrentProperty<int> &&
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
      fromString:
          fromString ?? (text) => (int.tryParse(text) ?? defaultValue) as T,
      asString: asString,
      defaultValue: defaultValue as T,
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
        CurrentDateTimeProperty,
        CurrentNullableDateTimeProperty
      ];

      // This is done in a verbose way, duplicating the list (unfortunately) to ensure type check safety,
      // guarding against Darts reified generics. Simply checking via `validTypes.any((type) => property.runtimeType == type)`
      // is not guaranteed to behave correctly due to possible type erasure.
      if (property is! CurrentProperty<DateTime> &&
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
              (propertyValue as DateTime?)?.toIso8601String() ??
              'Unparsable Date',
      defaultValue: defaultValue as T,
    );
  }

  void _setText() {
    final value =
        asString?.call(property.value) ?? property.value?.toString() ?? '';

    if (value != text) {
      text = value;
    }
  }

  T? _tryParseText(String text) {
    try {
      return fromString?.call(text) ?? defaultValue ?? text as T;
    } catch (_) {
      throw Exception(
        'Failed to parse and set CurrentProperty "${property.propertyName ?? property.runtimeType}" with value "$text". Did you provide a fromString function or provide a defaultValue?',
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// A mixin for managing the lifecycle of [CurrentTextController]s in a [CurrentState].
/// This mixin ensures that the controllers are only initialized once.
///
/// Must implement [bindCurrentControllers]. This is where you should initialize your [CurrentTextController]s.
mixin CurrentTextControllersLifecycleMixin<TWidget extends CurrentWidget,
    TViewModel extends CurrentViewModel> on CurrentState<TWidget, TViewModel> {
  bool _initializedControllers = false;

  /// Whether the CurrentTextControllers have been initialized. This is used to ensure that the controllers are only initialized once.
  bool get controllersInitialized => _initializedControllers;

  void bindCurrentControllers();

  @override
  void didChangeDependencies() {
    if (!controllersInitialized) {
      bindCurrentControllers();
      _initializedControllers = true;
    }
    super.didChangeDependencies();
  }
}
