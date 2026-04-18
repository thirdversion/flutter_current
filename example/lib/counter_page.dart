import 'dart:async';

import 'package:current/current.dart';
import 'package:current_counter_example/answer_to_life_found_event.dart';
import 'package:flutter/material.dart';
import 'application_view_model.dart';
import 'counter_view_model.dart';

class CounterPage extends CurrentWidget<CounterViewModel> {
  const CounterPage({super.key, required super.viewModel});

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, CounterViewModel>
      createCurrent() => _CounterPageState(viewModel);
}

class _CounterPageState extends CurrentState<CounterPage, CounterViewModel> {
  _CounterPageState(super.viewModel);

  final formKey = GlobalKey<FormState>();
  final countController = TextEditingController();

  late ApplicationViewModel appViewModel;

  StreamSubscription? countChangedSubscription;

  @override
  void initState() {
    // Can listen to specific events
    viewModel.addStateChangedListener<AnswerToLifeFoundEvent>((event) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.description),
        ),
      );
    }, filter: (event) => event.nextValue == 42);

    // Can also listen to all events and filter by property name
    countChangedSubscription =
        viewModel.addStateChangedListener((CurrentStateChanged event) {
      if (viewModel.changeBackgroundOnCountChange.isTrue) {
        appViewModel.randomizeBackgroundColor();
      }

      // Can also publish additional events in response to other events.
      // In this case, we're publishing an AnswerToLifeFoundEvent when the count reaches 42.
      if (event.nextValue == 42) {
        viewModel.notifyChange(AnswerToLifeFoundEvent(event.previousValue));
      }
    }, propertyName: "count");

    // Can listen to changes in the busy status of the view model
    // Setting the ViewModel to busy will always trigger a UI update, but this allows you to perform additional
    // side effects in response to busy status changes.
    viewModel.addBusyStatusChangedListener((event) {
      if (event.isBusy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations on being productive!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Good job on whatever you were doing!'),
          ),
        );
      }
    });
    super.initState();
  }

  Future<void> subscribeToCountChanges() async {
    countChangedSubscription?.resume();
    viewModel.changeBackgroundOnCountChange(true);
  }

  Future<void> unsubscribeToCountChanges() async {
    countChangedSubscription?.pause();
    viewModel.changeBackgroundOnCountChange(false);
  }

  @override
  void didChangeDependencies() {
    appViewModel = Current.of<ApplicationViewModel>(context).viewModel();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appViewModel.backgroundColor.value,
      appBar: AppBar(
        title: Text(appViewModel.title.value),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '${viewModel.count}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () =>
                    Current.viewModelOf<ApplicationViewModel>(context)
                        .changeBackgroundColor(Colors.red),
                child: const Text('Red'),
              ),
              TextButton(
                onPressed: () =>
                    Current.viewModelOf<ApplicationViewModel>(context)
                        .changeBackgroundColor(Colors.white),
                child: const Text('White'),
              ),
              TextButton(
                onPressed: () async {
                  if (viewModel.changeBackgroundOnCountChange.isFalse) {
                    await subscribeToCountChanges();
                  } else {
                    await unsubscribeToCountChanges();
                  }
                },
                child: Text(viewModel.changeBackgroundOnCountChange.isFalse
                    ? 'Randomize Background Color on Count Change'
                    : 'Turn Off Random Backgrounds'),
              ),
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: countController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Set Count',
                      suffix: IconButton(
                          onPressed: () {
                            // Can invoke the `set` function which will trigger the appropriate events and UI updates.
                            // The set function can be useful as you can use it as a function tear-off.
                            // For example, you could use it on this TextFormFieldss onFieldSubmitted callback:
                            // onFieldSubmitted: viewModel.count.set
                            viewModel.count.set(
                              int.tryParse(countController.text) ?? 0,
                            );
                          },
                          icon: Icon(Icons.save))),
                  onFieldSubmitted: (value) {
                    // Can directly set the value of the property, which will trigger the appropriate events and UI updates.
                    // This is more concise and idiomatic. If you want the new value to be treated as the original value, you can use the `set` function with the `setAsOriginal` argument set to true.
                    viewModel.count.value = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: viewModel.toggleProductivity,
                    child: ifBusy(
                      const Text('Stop Being Productive'),
                      otherwise: const Text('Be Productive'),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isBusy
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.work_off),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  viewModel.reset();
                  appViewModel.reset();
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
