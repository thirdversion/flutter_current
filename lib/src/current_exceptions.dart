import 'package:current/current.dart';

/// Base class for exceptions thrown by CurrentTextController when there is an issue with the CurrentProperty it is trying to control.
///
abstract class CurrentTextControllerException extends CurrentException {
  final CurrentProperty? property;

  CurrentTextControllerException(
    super.stack,
    super.type,
    this.property,
  );
}

/// Thrown when a [CurrentTextController] is initialized with a [CurrentProperty] type that is not compatible with the controller type requested.
///
class CurrentTextControllerCurrentPropertyTypeException
    extends CurrentTextControllerException {
  final String attemptedControllerType;
  final List<Type> validTypes;

  CurrentTextControllerCurrentPropertyTypeException(
    CurrentProperty property,
    this.attemptedControllerType,
    this.validTypes,
  ) : super(
          StackTrace.current,
          property.runtimeType,
          property,
        );

  @override
  String toString() =>
      'CurrentTextControllerCurrentPropertyTypeException: The property ${property?.propertyName ?? type} is not a valid CurrentProperty type for the controller type "$attemptedControllerType". Valid types are: ${validTypes.join(', ')}\nStack: $stack';
}

/// Thrown when a the [CurrentTextController.bind] is called more than once.
class CurrentTextControllerAlreadyInitializedException
    extends CurrentTextControllerException {
  CurrentTextControllerAlreadyInitializedException(
    CurrentProperty property,
  ) : super(StackTrace.current, property.runtimeType, property);

  @override
  String toString() =>
      'CurrentTextControllerAlreadyInitializedException: The CurrentTextController for the property ${property?.propertyName ?? type} has already been initialized. A CurrentTextController can only be initialized once per property.\nStack: $stack';
}

/// Thrown when a CurrentTextController is used before it has been initialized with a CurrentProperty via initState.
class CurrentTextControllerNotInitializedException<T>
    extends CurrentTextControllerException {
  CurrentTextControllerNotInitializedException()
      : super(StackTrace.current, CurrentTextController<T>, null);

  @override
  String toString() =>
      'CurrentTextControllerNotInitializedException: The CurrentTextController has not been initialized. You must initialize this controller inside the initCurrentControllers function. See CurrentTextControllersLifecycleMixin.\n\nStack: $stack';
}
