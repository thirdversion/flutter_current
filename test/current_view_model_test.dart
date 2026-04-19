import 'package:current/current.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestFailureEvent extends ErrorEvent<String> {
  _TestFailureEvent(super.error);
}

class _TestViewModel extends CurrentViewModel {
  final name = CurrentStringProperty('Bob');
  final age = CurrentIntProperty(20);

  @override
  Iterable<CurrentProperty> get currentProps => [name, age];
}

class _CollectionViewModel extends CurrentViewModel {
  final items = CurrentListProperty<String>.empty();

  @override
  Iterable<CurrentProperty> get currentProps => [items];
}

class _CollectionResetViewModel extends CurrentViewModel {
  final items = CurrentListProperty<String>(['Earth']);
  final data = CurrentMapProperty<String, String>({'planet': 'Earth'});

  @override
  Iterable<CurrentProperty> get currentProps => [items, data];
}

void main() {
  late _TestViewModel viewModel;
  late _CollectionViewModel collectionViewModel;
  late _CollectionResetViewModel collectionResetViewModel;

  setUp(() {
    viewModel = _TestViewModel();
    collectionViewModel = _CollectionViewModel();
    collectionResetViewModel = _CollectionResetViewModel();
  });

  test(
      'resetAll - change property values - All values equal their original value',
      () {
    const changedName = 'Steve';
    const changedAge = 100;
    final originalName = viewModel.name.value;
    final originalAge = viewModel.age.value;

    viewModel.name(changedName);
    viewModel.age(changedAge);

    expect(viewModel.name.value, equals(changedName));
    expect(viewModel.age.value, equals(changedAge));

    viewModel.resetAll();

    expect(viewModel.name.value, equals(originalName));
    expect(viewModel.age.value, equals(originalAge));
  });

  test('setBusyStatus', () {
    const taskKeyOne = 'taskOne';
    const taskKeyTwo = 'taskTwo';
    const taskKeyThree = 'taskThree';

    //Set all tasks to busy
    viewModel.setBusyStatus(isBusy: true, busyTaskKey: taskKeyOne);

    expect(viewModel.busy, isTrue);

    bool isTaskKeyOneBusy = viewModel.isTaskInProgress(taskKeyOne);

    expect(isTaskKeyOneBusy, isTrue);

    viewModel.setBusyStatus(isBusy: true, busyTaskKey: taskKeyTwo);

    expect(viewModel.busy, isTrue);

    bool isTaskKeyTwoBusy = viewModel.isTaskInProgress(taskKeyTwo);

    expect(isTaskKeyTwoBusy, isTrue);

    viewModel.setBusyStatus(isBusy: true, busyTaskKey: taskKeyThree);

    expect(viewModel.busy, isTrue);

    bool isTaskKeyThreeBusy = viewModel.isTaskInProgress(taskKeyThree);

    expect(isTaskKeyThreeBusy, isTrue);

    //Incrementally remove busy status
    viewModel.setBusyStatus(isBusy: false, busyTaskKey: taskKeyOne);

    isTaskKeyOneBusy = viewModel.isTaskInProgress(taskKeyOne);

    expect(isTaskKeyOneBusy, isFalse);
    expect(viewModel.busy, isTrue);

    viewModel.setBusyStatus(isBusy: false, busyTaskKey: taskKeyTwo);

    isTaskKeyTwoBusy = viewModel.isTaskInProgress(taskKeyTwo);

    expect(isTaskKeyTwoBusy, isFalse);
    expect(viewModel.busy, isTrue);

    viewModel.setBusyStatus(isBusy: false, busyTaskKey: taskKeyThree);

    isTaskKeyThreeBusy = viewModel.isTaskInProgress(taskKeyThree);

    expect(isTaskKeyThreeBusy, isFalse);
    expect(viewModel.busy, isFalse);
  });

  test('isDirty - change property values - isDirty is true', () {
    expect(viewModel.isDirty, isFalse);

    viewModel.name('Steve');

    expect(viewModel.isDirty, isTrue);
  });

  test('isDirty - change property values and reset - isDirty is false', () {
    viewModel.name('Steve');
    viewModel.age(100);

    expect(viewModel.isDirty, isTrue);

    viewModel.resetAll();

    expect(viewModel.isDirty, isFalse);
  });

  test(
      'isDirty - change property values, update original value, reset - isDirty is true',
      () {
    viewModel.name('Steve');
    viewModel.age(100);

    expect(viewModel.isDirty, isTrue);

    viewModel.name.setOriginalValueToCurrent();
    viewModel.age.setOriginalValueToCurrent();

    expect(viewModel.isDirty, isFalse);
  });

  test('isDirty - collection properties at original values - isDirty is false',
      () {
    expect(collectionViewModel.items.isDirty, isFalse);
    expect(collectionViewModel.isDirty, isFalse);
  });

  test('isDirty - collection properties after mutation - isDirty is true', () {
    collectionViewModel.items.add('Mars', notifyChanges: false);

    expect(collectionViewModel.items.isDirty, isTrue);
    expect(collectionViewModel.isDirty, isTrue);
  });

  test('resetAll - collection properties restore original values', () {
    collectionResetViewModel.items.add('Mars', notifyChanges: false);
    collectionResetViewModel.data.add('moon', 'Luna', notifyChanges: false);

    collectionResetViewModel.resetAll();

    expect(collectionResetViewModel.items.value, equals(['Earth']));
    expect(
      collectionResetViewModel.data.value,
      equals({'planet': 'Earth'}),
    );
  });

  test('resetAll - collection properties do not alias original values', () {
    collectionResetViewModel.items.add('Mars', notifyChanges: false);
    collectionResetViewModel.data.add('moon', 'Luna', notifyChanges: false);

    collectionResetViewModel.resetAll();

    collectionResetViewModel.items.add('Venus', notifyChanges: false);
    collectionResetViewModel.data.add('star', 'Sun', notifyChanges: false);

    expect(collectionResetViewModel.items.originalValue, equals(['Earth']));
    expect(
      collectionResetViewModel.data.originalValue,
      equals({'planet': 'Earth'}),
    );

    collectionResetViewModel.resetAll();

    expect(collectionResetViewModel.items.value, equals(['Earth']));
    expect(
      collectionResetViewModel.data.value,
      equals({'planet': 'Earth'}),
    );
  });

  test('addAnyErrorEventListener receives general error events', () async {
    ErrorEvent? receivedEvent;

    final subscription = viewModel.addAnyErrorEventListener((event) {
      receivedEvent = event;
    });

    viewModel.notifyError(_TestFailureEvent('boom'));
    await Future<void>.microtask(() {});

    expect(receivedEvent, isNotNull);
    expect(receivedEvent, isA<_TestFailureEvent>());
    expect(receivedEvent?.error, 'boom');

    await subscription.cancel();
  });
}
