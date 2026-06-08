import 'package:current_core/current_core.dart';
import 'package:flutter/foundation.dart';

///A ViewModel is an abstraction of the view it is bound to and represents the current state of
///the data in your model.
///
///This is where any logic that manipulates your model should be. An [CurrentWidget] and it's
///accompanying state always has access to it's view model via the viewModel property.
///
///Update events are automatically emitted whenever the value of an [CurrentProperty] is changed.
///The [CurrentState] the ViewModel is bound to will update itself each time an [CurrentProperty] value
///is changed and call the states build function, updating the UI.
abstract class CurrentViewModel extends CurrentStateViewModel
    with ChangeNotifier {
  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    disposeViewModel();
  }
}
