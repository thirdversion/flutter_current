import 'dart:async';

import 'current_property.dart';
import 'current_view_model.dart';

typedef CurrentValidationRule<T> = String? Function(T value);

class CurrentValidationState {
  static const Object _sentinel = Object();

  final String? errorText;
  final bool isTouched;
  final bool hasValidated;
  final Object? lastValidatedValue;

  const CurrentValidationState({
    this.errorText,
    this.isTouched = false,
    this.hasValidated = false,
    this.lastValidatedValue,
  });

  const CurrentValidationState.untouched()
      : errorText = null,
        isTouched = false,
        hasValidated = false,
        lastValidatedValue = null;

  bool get hasError => errorText != null && errorText!.isNotEmpty;

  bool get isValid => !hasError;

  CurrentValidationState copyWith({
    Object? errorText = _sentinel,
    bool? isTouched,
    bool? hasValidated,
    Object? lastValidatedValue = _sentinel,
  }) {
    return CurrentValidationState(
      errorText: identical(errorText, _sentinel)
          ? this.errorText
          : errorText as String?,
      isTouched: isTouched ?? this.isTouched,
      hasValidated: hasValidated ?? this.hasValidated,
      lastValidatedValue: identical(lastValidatedValue, _sentinel)
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

class CurrentValidationChanged
    extends CurrentStateChanged<CurrentValidationState> {
  final int validationSourceHashCode;

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

class CurrentFieldValidation<T> implements CurrentViewModelBinding {
  final CurrentProperty<T> property;
  final bool validateOnPropertyChange;
  final int validationSourceHashCode = identityHashCode(Object());

  final List<CurrentValidationRule<T>> _rules;
  StreamSubscription<CurrentStateChanged>? _propertySubscription;
  CurrentValidationState _state = const CurrentValidationState.untouched();

  CurrentFieldValidation(
    this.property, {
    Iterable<CurrentValidationRule<T>> rules = const [],
    this.validateOnPropertyChange = false,
  }) : _rules = List<CurrentValidationRule<T>>.from(rules);

  CurrentValidationState get state => _state;

  String? get errorText => _state.errorText;

  bool get hasError => _state.hasError;

  bool get isValid => _state.isValid;

  bool get isTouched => _state.isTouched;

  bool get hasValidated => _state.hasValidated;

  CurrentFieldValidation<T> addRule(CurrentValidationRule<T> rule) {
    _rules.add(rule);
    return this;
  }

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

  void markTouched() {
    _updateState(_state.copyWith(isTouched: true));
  }

  void setError(String? errorText, {bool markTouched = false}) {
    final nextState = _state.copyWith(
      errorText: errorText,
      isTouched: _state.isTouched || markTouched,
      hasValidated: true,
      lastValidatedValue: property.value,
    );

    _updateState(nextState);
  }

  void reset() {
    _updateState(const CurrentValidationState.untouched());
  }

  @override
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

class CurrentValidationGroup {
  final List<CurrentFieldValidation<dynamic>> validations;

  CurrentValidationGroup(Iterable<CurrentFieldValidation<dynamic>> validations)
      : validations = List<CurrentFieldValidation<dynamic>>.from(validations);

  bool get isValid => validations.every((validation) => validation.isValid);

  bool get hasErrors => validations.any((validation) => validation.hasError);

  String? get firstErrorText {
    for (final validation in validations) {
      if (validation.hasError) {
        return validation.errorText;
      }
    }

    return null;
  }

  bool validateAll({bool markTouched = true}) {
    for (final validation in validations) {
      validation.validate(markTouched: markTouched);
    }

    return isValid;
  }

  void resetAll() {
    for (final validation in validations) {
      validation.reset();
    }
  }
}

extension CurrentPropertyValidationExtensions<T> on CurrentProperty<T> {
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
