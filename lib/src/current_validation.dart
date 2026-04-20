import 'dart:async';

import 'package:flutter/widgets.dart';

import 'current_property.dart';
import 'current_view_model.dart';

/// Signature for a synchronous validation rule used by [CurrentFieldValidation].
///
/// Return `null` when the provided [value] is valid.
/// Return a [CurrentValidationIssue] when the value is invalid.
///
/// Rules are executed in the order they are added. The first rule that returns
/// a non-null issue wins.
///
/// ## Example
///
/// ```dart
/// final name = CurrentStringProperty('', propertyName: 'name');
///
/// final validation = name.createValidation(
///   rules: [
///     (value) => value.isEmpty
///         ? const CurrentValidationIssue(
///             'profile.name.required',
///             fallbackMessage: 'Name is required',
///           )
///         : null,
///     (value) => value.length < 3
///         ? const CurrentValidationIssue(
///             'profile.name.tooShort',
///             fallbackMessage: 'Name is too short',
///           )
///         : null,
///   ],
/// );
/// ```
typedef CurrentValidationRule<T> = CurrentValidationIssue? Function(T value);

/// Resolves a [CurrentValidationIssue] into display text.
///
/// This is typically supplied from the widget layer, where localization is
/// available.
typedef CurrentValidationIssueTextResolver = String? Function(
  CurrentValidationIssue issue,
);

/// Resolves a [CurrentValidationIssue] into display text using a
/// [BuildContext].
typedef CurrentValidationIssueContextTextBuilder = String? Function(
  BuildContext context,
  CurrentValidationIssue issue,
);

/// Describes a validation failure without tying it to a specific locale.
///
/// Validation rules should return this object instead of already-localized
/// display text. Widgets can later resolve the issue into a localized string
/// using the active [CurrentValidationIssueTextResolver].
final class CurrentValidationIssue {
  /// Stable identifier for the validation failure.
  final String code;

  /// Optional structured arguments that a resolver can use when building text.
  final Map<String, Object?> arguments;

  /// Optional fallback text for environments that do not provide a resolver.
  final String? fallbackMessage;

  /// Optional builder used when display text depends on a [BuildContext].
  final CurrentValidationIssueContextTextBuilder? contextTextBuilder;

  /// Creates a validation issue with a stable [code].
  const CurrentValidationIssue(
    this.code, {
    this.arguments = const {},
    this.fallbackMessage,
    this.contextTextBuilder,
  });

  /// Creates an issue backed only by a fallback message.
  const CurrentValidationIssue.message(
    String message, {
    String code = 'current.validation.message',
    Map<String, Object?> arguments = const {},
    CurrentValidationIssueContextTextBuilder? contextTextBuilder,
  }) : this(
          code,
          arguments: arguments,
          fallbackMessage: message,
          contextTextBuilder: contextTextBuilder,
        );

  /// Allows creation of an issue with a context-dependent message.
  ///
  /// This allows you to generate a localized error message that requires access to a BuildContext.
  ///
  /// [textBuilder] is a function that takes a BuildContext and the issue itself, and returns a localized string.
  ///
  /// [code] is optional, but can be used if your localization implementation is based on error codes
  /// instead of full messages. If not provided, it defaults to 'current.validation.localize'.
  ///
  /// [arguments] can be used to pass structured data to the text builder, such as field names or validation parameters.
  ///
  /// [fallbackMessage] is optional text that can be used as a fallback when no resolver is available. This is useful for ensuring that some message is always available, even in non-localized environments or during development.
  const CurrentValidationIssue.localize({
    required CurrentValidationIssueContextTextBuilder? textBuilder,
    String code = 'current.validation.localize',
    Map<String, Object?> arguments = const {},
    String? fallbackMessage,
  }) : this(
          code,
          arguments: arguments,
          fallbackMessage: fallbackMessage,
          contextTextBuilder: textBuilder,
        );

  /// Creates an issue representing a required-value failure.
  const CurrentValidationIssue.requiredValue({
    String code = 'current.validation.requiredValue',
    Map<String, Object?> arguments = const {},
    String? fallbackMessage,
    CurrentValidationIssueContextTextBuilder? contextTextBuilder,
  }) : this(
          code,
          arguments: arguments,
          fallbackMessage: fallbackMessage,
          contextTextBuilder: contextTextBuilder,
        );

  /// Creates an issue representing a parse or invalid-value failure.
  const CurrentValidationIssue.invalidValue({
    String code = 'current.validation.invalidValue',
    Map<String, Object?> arguments = const {},
    String? fallbackMessage,
    CurrentValidationIssueContextTextBuilder? contextTextBuilder,
  }) : this(
          code,
          arguments: arguments,
          fallbackMessage: fallbackMessage,
          contextTextBuilder: contextTextBuilder,
        );

  /// Resolves this issue into display text.
  ///
  /// Resolution order is:
  /// 1. [contextTextBuilder], when [context] is provided
  /// 2. [resolver], when provided
  /// 3. [fallbackMessage], when available
  /// 4. [code] as a final development fallback
  String resolveText({
    BuildContext? context,
    CurrentValidationIssueTextResolver? resolver,
  }) {
    return (context != null ? contextTextBuilder?.call(context, this) : null) ??
        resolver?.call(this) ??
        fallbackMessage ??
        code;
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentValidationIssue &&
        other.code == code &&
        other.fallbackMessage == fallbackMessage &&
        other.contextTextBuilder == contextTextBuilder &&
        _mapsEqual(other.arguments, arguments);
  }

  @override
  int get hashCode => Object.hash(
        code,
        fallbackMessage,
        contextTextBuilder,
        Object.hashAllUnordered(
          arguments.entries.map((entry) => Object.hash(entry.key, entry.value)),
        ),
      );

  static bool _mapsEqual(
    Map<String, Object?> left,
    Map<String, Object?> right,
  ) {
    if (identical(left, right)) {
      return true;
    }

    if (left.length != right.length) {
      return false;
    }

    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) || right[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}

/// Represents the current validation metadata for a field.
///
/// This object is intentionally separate from [CurrentProperty].
/// [CurrentProperty] remains the source of truth for the underlying value,
/// while [CurrentValidationState] describes whether that value has been
/// validated, whether the field has been touched, and what the current error
/// issue is, if any.
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
  /// This is necessary for nullable fields like [issue], where passing
  /// `null` should clear the value, while omitting the argument should leave the
  /// existing value unchanged.
  ///
  /// Since Dart treats an omitted argument and a passed null the same way if the parameter is T? value = null,
  /// the _omitted is a unique object used to detect that nothing was passed at all.
  static const Object _omitted = Object();

  /// The current validation issue for the field.
  ///
  /// This is `null` when there is no validation error.
  final CurrentValidationIssue? issue;

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
    this.issue,
    this.isTouched = false,
    this.hasValidated = false,
    this.lastValidatedValue,
  });

  /// Creates the default untouched validation state.
  ///
  /// This is typically the starting state for a validator before any rules have
  /// executed.
  const CurrentValidationState.untouched()
      : issue = null,
        isTouched = false,
        hasValidated = false,
        lastValidatedValue = null;

  /// Whether the state currently contains a validation issue.
  bool get hasIssue => issue != null;

  /// Whether the current state is valid.
  bool get isValid => !hasIssue;

  /// Creates a copy of this validation state with selected values replaced.
  ///
  /// This is primarily used internally by [CurrentFieldValidation], but can
  /// be used publicly so you can update specific validation metadata without affecting other fields.
  /// For example, you might want to mark a field as touched without changing the current error state, or update the error message without affecting the touched state.
  CurrentValidationState copyWith({
    Object? issue = _omitted,
    bool? isTouched,
    bool? hasValidated,
    Object? lastValidatedValue = _omitted,
  }) {
    return CurrentValidationState(
      issue: identical(issue, _omitted)
          ? this.issue
          : issue as CurrentValidationIssue?,
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
        other.issue == issue &&
        other.isTouched == isTouched &&
        other.hasValidated == hasValidated &&
        other.lastValidatedValue == lastValidatedValue;
  }

  @override
  int get hashCode =>
      Object.hash(issue, isTouched, hasValidated, lastValidatedValue);
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
///   CurrentFieldValidation<String>? _emailValidation;
///   CurrentFieldValidation<String> get emailValidation =>
///       _emailValidation ??= email.createValidation(
///     rules: [
///       (value) => value.isEmpty
///           ? const CurrentValidationIssue(
///               'profile.email.required',
///               fallbackMessage: 'Email is required',
///             )
///           : null,
///       (value) => value.contains('@')
///           ? null
///           : const CurrentValidationIssue(
///               'profile.email.invalid',
///               fallbackMessage: 'Email is invalid',
///             ),
///     ],
///     validateOnPropertyChange: true,
///   );
///
///   @override
///   Iterable<CurrentProperty> get currentProps => [email];
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
  /// Validators created through
  /// [CurrentPropertyValidationExtensions.createValidation] are registered
  /// against the property automatically.
  ///
  /// If the property already belongs to a [CurrentViewModel], the validator
  /// attaches immediately. Otherwise it attaches the next time the property is
  /// assigned to a view model.
  CurrentFieldValidation(
    this.property, {
    Iterable<CurrentValidationRule<T>> rules = const [],
    this.validateOnPropertyChange = false,
  }) : _rules = List<CurrentValidationRule<T>>.from(rules);

  /// The current validation state.
  CurrentValidationState get state => _state;

  /// The current validation issue, if any.
  CurrentValidationIssue? get issue => _state.issue;

  /// Whether the validator currently has an issue.
  bool get hasIssue => _state.hasIssue;

  /// Whether the current validation state is valid.
  bool get isValid => _state.isValid;

  /// Whether the field has been marked as touched.
  bool get isTouched => _state.isTouched;

  /// Whether validation has run at least once.
  bool get hasValidated => _state.hasValidated;

  /// Adds a validation [rule] to this validator.
  ///
  /// Rules run in insertion order, and the first non-null issue wins.
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
    CurrentValidationIssue? issue;

    for (final rule in _rules) {
      final result = rule(property.value);

      if (result != null) {
        issue = result;
        break;
      }
    }

    final nextState = _state.copyWith(
      issue: issue,
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

  /// Sets a validation issue manually.
  ///
  /// This can be used to surface validation metadata produced outside the
  /// normal synchronous rule flow, such as controller parse failures or
  /// other external validation results.
  ///
  /// Passing `null` clears the current issue state.
  ///
  /// If [markTouched] is `true`, the field is also marked as touched.
  void setIssue(CurrentValidationIssue? issue, {bool markTouched = false}) {
    final nextState = _state.copyWith(
      issue: issue,
      isTouched: _state.isTouched || markTouched,
      hasValidated: true,
      lastValidatedValue: property.value,
    );

    _updateState(nextState);
  }

  /// Resolves the current issue into display text.
  String? resolveIssueText({
    BuildContext? context,
    CurrentValidationIssueTextResolver? resolver,
  }) {
    return issue?.resolveText(context: context, resolver: resolver);
  }

  /// Resets the validation metadata back to the untouched state.
  void reset() {
    _updateState(const CurrentValidationState.untouched());
  }

  @override

  /// Attaches this validator to the owning [CurrentViewModel].
  ///
  /// This is called automatically when the validator is registered against its
  /// property or when it is surfaced through [CurrentViewModel.currentBindings].
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
///   rules: [
///     (value) => value.isEmpty
///         ? const CurrentValidationIssue(
///             'profile.firstName.required',
///             fallbackMessage: 'First name is required',
///           )
///         : null,
///   ],
/// );
///
/// final ageValidation = age.createValidation(
///   rules: [
///     (value) => value < 18
///         ? const CurrentValidationIssue(
///             'profile.age.adultRequired',
///             fallbackMessage: 'Must be an adult',
///           )
///         : null,
///   ],
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

  /// Creates a group from properties that already have registered validators.
  factory CurrentValidationGroup.forProperties(
    Iterable<CurrentProperty<dynamic>> properties,
  ) {
    final validations = <CurrentFieldValidation<dynamic>>[];

    for (final property in properties) {
      final validation = property.tryGetValidation();

      if (validation != null) {
        validations.add(validation);
      }
    }

    return CurrentValidationGroup(validations);
  }

  /// Whether every validator in the group is currently valid.
  bool get isValid => validations.every((validation) => validation.isValid);

  /// Whether any validator in the group currently has an issue.
  bool get hasIssues => validations.any((validation) => validation.hasIssue);

  /// The first issue currently reported by the group, if any.
  CurrentValidationIssue? get firstIssue {
    for (final validation in validations) {
      if (validation.hasIssue) {
        return validation.issue;
      }
    }

    return null;
  }

  /// Resolves the first issue currently reported by the group, if any.
  String? resolveFirstIssueText({
    BuildContext? context,
    CurrentValidationIssueTextResolver? resolver,
  }) {
    return firstIssue?.resolveText(context: context, resolver: resolver);
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
  /// The first validation registered for this property, if any.
  CurrentFieldValidation<T>? tryGetValidation() {
    for (final binding in registeredBindings) {
      if (binding is CurrentFieldValidation &&
          identical(binding.property, this)) {
        return binding as CurrentFieldValidation<T>;
      }
    }

    return null;
  }

  /// The first validation registered for this property.
  ///
  /// Throws a [StateError] when no validation has been registered.
  CurrentFieldValidation<T> get validation {
    final registeredValidation = tryGetValidation();

    if (registeredValidation == null) {
      throw StateError(
        'No CurrentFieldValidation is registered for '
        '${propertyName ?? runtimeType}.',
      );
    }

    return registeredValidation;
  }

  /// Creates a [CurrentFieldValidation] for this property.
  ///
  /// This is a convenience wrapper around [CurrentFieldValidation.new] that
  /// keeps validation setup close to the property declaration.
  ///
  /// The created validator is registered against this property automatically,
  /// so it can attach immediately when the property already has a view model or
  /// later when the property is assigned to one.
  ///
  /// ## Example
  ///
  /// ```dart
  /// class ProfileViewModel extends CurrentViewModel {
  ///   final email = CurrentStringProperty('', propertyName: 'email');
  ///
  ///   CurrentFieldValidation<String>? _emailValidation;
  ///   CurrentFieldValidation<String> get emailValidation =>
  ///       _emailValidation ??= email.createValidation(
  ///         rules: [
  ///           (value) => value.isEmpty
  ///               ? const CurrentValidationIssue(
  ///                   'profile.email.required',
  ///                   fallbackMessage: 'Email is required',
  ///                 )
  ///               : null,
  ///         ],
  ///       );
  /// }
  /// ```
  CurrentFieldValidation<T> createValidation({
    Iterable<CurrentValidationRule<T>> rules = const [],
    bool validateOnPropertyChange = false,
  }) {
    final validation = CurrentFieldValidation<T>(
      this,
      rules: rules,
      validateOnPropertyChange: validateOnPropertyChange,
    );

    registerBinding(validation);

    return validation;
  }
}
