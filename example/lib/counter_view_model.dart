import 'package:current/current.dart';
import 'package:current_counter_example/failed_to_recite_pi.dart';

class CounterViewModel extends CurrentViewModel {
  final name = CurrentProperty.string(initialValue: 'You');
  final count = CurrentProperty.integer(propertyName: 'count');

  final changeBackgroundOnCountChange = CurrentBoolProperty(false);

  @override
  List<CurrentProperty> get currentProps {
    return [name, count, changeBackgroundOnCountChange];
  }

  Future<void> incrementCounter() async {
    count.increment();
  }

  void toggleProductivity() {
    if (busy) {
      setNotBusy();
    } else {
      setBusy();
    }
  }

  void recitePi() {
    notifyError(FailedToRecitePi('🤯'));
  }
}
