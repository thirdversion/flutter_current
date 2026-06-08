import 'package:flutter_test/flutter_test.dart';
import 'package:current/current.dart';

class _TestViewModel extends CurrentViewModel {
  @override
  Iterable<CurrentProperty> get currentProps => [];
}

void main() {
  group('CurrentViewModel Tests', () {
    test('dispose calls disposeViewModel and sets disposed to true', () {
      final viewModel = _TestViewModel();
      
      expect(viewModel.disposed, isFalse);
      
      viewModel.dispose();
      
      expect(viewModel.disposed, isTrue);
    });
  });
}
