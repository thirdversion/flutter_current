import 'dart:async';

import 'current_property.dart';
import 'current_view_model.dart';

/// Signature for a synchronous validation rule used by [CurrentFieldValidation].
///
/// Return `null` when the provided [value] is valid.
/// Return a non-empty [String] when the value is invalid. The returned string
/// is treated as the validation error message.
///
/// Rules are executed in the order they are added. The first rule that returns
/// a non-null, non-empty message wins.
///
/// ## Example
///
/// ```dart
/// final name = CurrentStringProperty('', propertyName: 'name');
///
/// final validation = name.createValidation(
///   rules: [
///     (value) => value.isEmpty ? 'Name is required' : null,
///     (value) => value.length < 3 ? 'Name is too short' : null,
///   ],
/// );
/// ```
typedef CurrentValidationRule<T> = String? Function(T value);

/// Represents the current validation metadata for a field.
///
/// This object is intentionally separate from [CurrentProperty].
/// [CurrentProperty] remains the source of truth for the underlying value,
/// while [CurrentValidationState] describes whether that value has been
/// validated, whether the field has been touched, and what the current error
/// message is, if any.
///
/// Widgets can read this state to determine whether to show validation errors,
/// enable a submit action, or mark a field as interacted with.
///
/// Use [CurrentValidationState.untouched] to represent the initial validation
/// state before the field has been validated or touched.
class CurrentValidationState {
  /// Private marker used by [copyWith] to distinguish between
  /// "parameter not provided" and an explicit `null` value.
  ///
  /// This is necessary for nullable fields like [errorText], where passing
  /// `null` should clear the value, while omitting the argument should leave the
  /// existing value unchanged.
  ///
  /// Since Dart treats an omitted argument and a passed null the same way if the parameter is T? value = null,
  /// the _omitted is a unique object used to detect that nothing was passed at all.
  static const Object _omitted = Object();

  /// The current validation error message for the field.
  ///
  /// This is `null` when there is no validation error.
  final String? errorText;

  /// Whether the field has been touched by the current validation workflow.
  ///
  /// A field is typically marked as touched when the user has interacted with
  /// the input or when validation is explicitly requested with
  /// `markTouched: true`.
  final bool isTouched;

  /// Whether validation has run at least once for the field.
  final bool hasValidated;

  /// The most recent value that was validated.
  ///
  /// This is metadata only and does not affect the property's source value.
  final Object? lastValidatedValue;

  /// Creates a validation state with the provided metadata.
  const CurrentValidationState({
    this.errorText,
    this.isTouched = false,
    this.hasValidated = false,
    this.lastValidatedValue,
  });

  /// Creates the default untouched validation state.
  ///
  /// This is typically the starting state for a validator before any rules have
  /// executed.
  const CurrentValidationState.untouched()
      : errorText = null,
        isTouched = false,
        hasValidated = false,
        lastValidatedValue = null;

  /// Whether the state currently contains a validation error.
  bool get hasError => errorText != null && errorText!.isNotEmpty;

  /// Whether the current state is valid.
  bool get isValid => !hasError;

  /// Creates a copy of this validation state with selected values replaced.
  ///
  /// This is primarily used internally by [CurrentFieldValidation], but can
  /// be used publicly so you can update specific validation metadata without affecting other fields.
  /// For example, you might want to mark a field as touched without changing the current error state, or update the error message without affecting the touched state.
  CurrentValidationState copyWith({
    Object? errorText = _omitted,
    bool? isTouched,
    bool? hasValidated,
    Object? lastValidatedValue = _omitted,
  }) {
    return CurrentValidationState(
      errorText: identical(errorText, _omitted)
          ? this.errorText
          : errorText as String?,
      isTouched: isTouched ?? this.isTouched,
      hasValidated: hasValidated ?? this.hasValidated,
      lastValidatedValue: identical(lastValidatedValue, _omitted)
          ? this.lastValidatedValue
          : lastValidatedValue,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentValidationState &&
        other.errorText == errorText &&
        other.isTouched == isTouched &&
        other.hasValidated == hasValidated &&
        other.lastValidatedValue == lastValidatedValue;
  }

  @override
  int get hashCode =>
      Object.hash(errorText, isTouched, hasValidated, lastValidatedValue);
}

/// Event sent when the validation metadata for a field changes.
///
/// This extends [CurrentStateChanged] so validation state changes flow through
/// the same event pipeline used by the rest of Current. This means that
/// [CurrentWidget] and [CurrentState] rebuild automatically when validation
/// state changes.
///
/// The [sourceHashCode] inherited from [CurrentStateChanged] refers to the
/// underlying [property]. The [validationSourceHashCode] identifies the
/// specific [CurrentFieldValidation] instance that emitted the event.
class CurrentValidationChanged
    extends CurrentStateChanged<CurrentValidationState> {
  /// Unique identifier for the validation instance that emitted this event.
  final int validationSourceHashCode;

  /// Creates a validation change event for the provided [property].
  CurrentValidationChanged({
    required CurrentProperty property,
    required CurrentValidationState nextState,
    required CurrentValidationState previousState,
    required this.validationSourceHashCode,
  }) : super(
          nextState,
          previousState,
          propertyName: property.propertyName,
          description: 'Validation Changed',
          sourceHashCode: property.sourceHashCode,
        );
}

/// Tracks validation metadata for a single [CurrentProperty].
///
/// This helper is intended to be owned by a [CurrentViewModel] alongside the
/// property it validates. It stores a list of [CurrentValidationRule] objects,
/// exposes the current [state], and can optionally re-run validation whenever
/// the underlying property value changes.
///
/// Validation metadata is sent through the Current event stream by
/// sending [CurrentValidationChanged] events. This means widgets using a
/// [CurrentViewModel] can react to validation changes automatically.
///
/// ## Example
///
/// ```dart
/// class ProfileViewModel extends CurrentViewModel {
///   final email = CurrentStringProperty('', propertyName: 'email');
///
///   late final emailValidation = email.createValidation(
///     rules: [
///       (value) => value.isEmpty ? 'Email is required' : null,
///       (value) => value.contains('@') ? null : 'Email is invalid',
///     ],
///     validateOnPropertyChange: true,
///   );
///
///   @override
///   Iterable<CurrentProperty> get currentProps => [email];
///
///   @override
///   Iterable<CurrentViewModelBinding> get currentBindings => [emailValidation];
/// }
/// ```
class CurrentFieldValidation<T> implements CurrentViewModelBinding {
  /// The property whose value this validator describes.
  final CurrentProperty<T> property;

  /// Whether validation should automatically re-run when [property] changes.
  ///
  /// When `true`, [attachToViewModel] registers a listener against the owning
  /// [CurrentViewModel] so validation stays synchronized with external property
  /// updates.
  final bool validateOnPropertyChange;

  /// Unique identifier for this validation instance.
  ///
  /// This can be used to distinguish between multiple validators targeting the
  /// same property when listening to [CurrentValidationChanged] events.
  final int validationSourceHashCode = identityHashCode(Object());

  final List<CurrentValidationRule<T>> _rules;
  StreamSubscription<CurrentStateChanged>? _propertySubscription;
  CurrentValidationState _state = const CurrentValidationState.untouched();

  /// Creates a validator for the provided [property].
  ///
  /// The optional [rules] are evaluated in the order supplied.
  ///
  /// If [validateOnPropertyChange] is `true`, this validation helper should be
  /// returned from [CurrentViewModel.currentBindings] so it can attach to the
  /// owning [CurrentViewModel] after the property has been initialized.
  CurrentFieldValidation(
    this.property, {
    Iterable<CurrentValidationRule<T>> rules = const [],
    this.validateOnPropertyChange = false,
  }) : _rules = List<CurrentValidationRule<T>>.from(rules);

  /// The current validation state.
  CurrentValidationState get state => _state;

  /// The current validation error message, if any.
  String? get errorText => _state.errorText;

  /// Whether the validator currently has an error.
  bool get hasError => _state.hasError;

  /// Whether the current validation state is valid.
  bool get isValid => _state.isValid;

  /// Whether the field has been marked as touched.
  bool get isTouched => _state.isTouched;

  /// Whether validation has run at least once.
  bool get hasValidated => _state.hasValidated;

  /// Adds a validation [rule] to this validator.
  ///
  /// Rules run in insertion order, and the first non-null, non-empty error
  /// message wins.
  ///
  /// Returns this validator to support fluent setup.
  CurrentFieldValidation<T> addRule(CurrentValidationRule<T> rule) {
    _rules.add(rule);
    return this;
  }

  /// Runs the validator rules against the current property value.
  ///
  /// Returns the updated [CurrentValidationState].
  ///
  /// If [markTouched] is `true`, the resulting validation state is also marked
  /// as touched.
  ///
  /// This method emits a [CurrentValidationChanged] event when the validation
  /// metadata changes.
  CurrentValidationState validate({bool markTouched = false}) {
    String? errorText;

    for (final rule in _rules) {
      final result = rule(property.value);

      if (result != null && result.isNotEmpty) {
        errorText = result;
        break;
      }
    }

    final nextState = _state.copyWith(
      errorText: errorText,
      isTouched: _state.isTouched || markTouched,
      hasValidated: true,
      lastValidatedValue: property.value,
    );

    _updateState(nextState);

    return _state;
  }

  /// Marks the field as touched without changing the current error state.
  ///
  /// This is useful when the UI wants to show that the user has interacted
  /// with the field before validation has been run.
  void markTouched() {
    _updateState(_state.copyWith(isTouched: true));
  }

  /// Sets a validation error message manually.
  ///
  /// This can be used to surface validation metadata produced outside the
  /// normal synchronous rule flow, such as controller parse failures or
  /// other external validation results.
  ///
  /// Passing `null` clears the current error state.
  ///
  /// If [markTouched] is `true`, the field is also marked as touched.
  void setError(String? errorText, {bool markTouched = false}) {
    final nextState = _state.copyWith(
      errorText: errorText,
      isTouched: _state.isTouched || markTouched,
      hasValidated: true,
      lastValidatedValue: property.value,
    );

    _updateState(nextState);
  }

  /// Resets the validation metadata back to the untouched state.
  void reset() {
    _updateState(const CurrentValidationState.untouched());
  }

  @override

  /// Attaches this validator to the owning [CurrentViewModel].
  ///
  /// This is called automatically when the validator is returned from
  /// [CurrentViewModel.currentBindings].
  ///
  /// When [validateOnPropertyChange] is enabled, this subscribes to property
  /// change events and re-runs [validate] whenever the target [property]
  /// changes.
  void attachToViewModel() {
    if (!validateOnPropertyChange || _propertySubscription != null) {
      return;
    }

    _propertySubscription = property.viewModel.addAnyStateChangedListener(
      (event) {
        if (event is CurrentValidationChanged) {
          return;
        }

        if (event.sourceHashCode != property.sourceHashCode) {
          return;
        }

        validate();
      },
      filter: (event) => event.sourceHashCode == property.sourceHashCode,
    );
  }

  void _updateState(CurrentValidationState nextState) {
    final previousState = _state;

    if (previousState == nextState) {
      return;
    }

    _state = nextState;

    final viewModel = _tryGetViewModel();

    if (viewModel == null) {
      return;
    }

    viewModel.notifyChange(
      CurrentValidationChanged(
        property: property,
        nextState: nextState,
        previousState: previousState,
        validationSourceHashCode: validationSourceHashCode,
      ),
    );
  }

  CurrentViewModel? _tryGetViewModel() {
    try {
      return property.viewModel;
    } catch (_) {
      return null;
    }
  }
}

/// Aggregates multiple [CurrentFieldValidation] instances.
///
/// This is intended for form-level workflows where multiple fields need to be
/// validated together. The group itself does not own any values; it simply
/// coordinates the validators that are passed to it.
///
/// ## Example
///
/// ```dart
/// final firstNameValidation = firstName.createValidation(
///   rules: [(value) => value.isEmpty ? 'First name is required' : null],
/// );
///
/// final ageValidation = age.createValidation(
///   rules: [(value) => value < 18 ? 'Must be an adult' : null],
/// );
///
/// final validationGroup = CurrentValidationGroup([
///   firstNameValidation,
///   ageValidation,
/// ]);
///
/// final canSubmit = validationGroup.validateAll();
/// ```
class CurrentValidationGroup {
  /// The validators tracked by this group.
  final List<CurrentFieldValidation<dynamic>> validations;

  /// Creates a group from the provided [validations].
  CurrentValidationGroup(Iterable<CurrentFieldValidation<dynamic>> validations)
      : validations = List<CurrentFieldValidation<dynamic>>.from(validations);

  /// Whether every validator in the group is currently valid.
  bool get isValid => validations.every((validation) => validation.isValid);

  /// Whether any validator in the group currently has an error.
  bool get hasErrors => validations.any((validation) => validation.hasError);

  /// The first error message currently reported by the group, if any.
  String? get firstErrorText {
    for (final validation in validations) {
      if (validation.hasError) {
        return validation.errorText;
      }
    }

    return null;
  }

  /// Validates every field in the group.
  ///
  /// Returns `true` when all validations succeed.
  ///
  /// By default, every validation is marked as touched.
  bool validateAll({bool markTouched = true}) {
    for (final validation in validations) {
      validation.validate(markTouched: markTouched);
    }

    return isValid;
  }

  /// Resets every validator in the group back to the untouched state.
  void resetAll() {
    for (final validation in validations) {
      validation.reset();
    }
  }
}

/// Adds convenience validation helpers to [CurrentProperty].
extension CurrentPropertyValidationExtensions<T> on CurrentProperty<T> {
  /// Creates a [CurrentFieldValidation] for this property.
  ///
  /// This is a convenience wrapper around [CurrentFieldValidation.new] that
  /// keeps validation setup close to the property declaration.
  ///
  /// If [validateOnPropertyChange] is `true`, return the created validator from
  /// [CurrentViewModel.currentBindings] so it can attach after the view model
  /// initializes its properties.
  ///
  /// ## Example
  ///
  /// ```dart
  /// late final emailValidation = email.createValidation(
  ///   rules: [
  ///     (value) => value.isEmpty ? 'Email is required' : null,
  ///   ],
  /// );
  /// ```
  CurrentFieldValidation<T> createValidation({
    Iterable<CurrentValidationRule<T>> rules = const [],
    bool validateOnPropertyChange = false,
  }) {
    return CurrentFieldValidation<T>(
      this,
      rules: rules,
      validateOnPropertyChange: validateOnPropertyChange,
    );
  }
}
