import 'package:current/current.dart';

class CounterViewModel extends CurrentViewModel {
  final count = CurrentIntProperty.zero(propertyName: 'count');
  final changeBackgroundOnCountChange = CurrentBoolProperty(false);

  @override
  List<CurrentProperty> get currentProps {
    return [count, changeBackgroundOnCountChange];
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

  void reset() {
    count.reset();
    changeBackgroundOnCountChange.reset();
  }
}
