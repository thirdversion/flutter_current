import 'package:current/current.dart';

final class AnswerToLifeFoundEvent extends CurrentStateChanged<int> {
  @override
  String get description =>
      '$nextValue is the answer to life, the universe, and everything! Take that previous value of $previousValue!';

  AnswerToLifeFoundEvent(int previousValue) : super(42, previousValue);
}
