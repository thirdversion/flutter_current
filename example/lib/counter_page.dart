import 'dart:async';

import 'package:current/current.dart';
import 'package:current_counter_example/answer_to_life_found_event.dart';
import 'package:current_counter_example/failed_to_recite_pi.dart';
import 'package:flutter/material.dart';
import 'application_view_model.dart';
import 'counter_view_model.dart';

class CounterPage extends CurrentWidget<CounterViewModel> {
  const CounterPage({super.key, required super.viewModel});

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, CounterViewModel>
      createCurrent() => _CounterPageState(viewModel);
}

class _CounterPageState extends CurrentState<CounterPage, CounterViewModel>
    with CurrentTextControllersLifecycleMixin {
  _CounterPageState(super.viewModel);

  static const double _textFieldWidth = 200;

  final formKey = GlobalKey<FormState>();
  final countController = TextEditingController();
  final nameController = CurrentTextController.string();

  late ApplicationViewModel appViewModel;

  StreamSubscription? countChangedSubscription;

  @override
  void bindCurrentControllers() {
    nameController.bindString(
      property: viewModel.name,
      lifecycleProvider: this,
    );
  }

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

    // Can also listen to error events. Error events are a separate stream from state changed events.
    // You can listen to specific error events (like FailedToRecitePi) or listen to all error events by subscribing to [ErrorEvent].
    viewModel.addOnErrorEventListener<FailedToRecitePi>((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            error.error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 96),
          ),
        ),
      );
    });
    super.initState();
  }

  Future<void> resumeCountChangeSubscription() async {
    countChangedSubscription?.resume();
    viewModel.changeBackgroundOnCountChange(true);
  }

  Future<void> pauseCountChangeSubscription() async {
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
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: _textFieldWidth,
                          child: TextFormField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(text: 'Hey ', children: [
                            TextSpan(
                              text: viewModel.name.value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text:
                                  ', You have pushed the button this many times:',
                            ),
                          ]),
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
                            if (viewModel
                                .changeBackgroundOnCountChange.isFalse) {
                              await resumeCountChangeSubscription();
                            } else {
                              await pauseCountChangeSubscription();
                            }
                          },
                          child: Text(
                              viewModel.changeBackgroundOnCountChange.isFalse
                                  ? 'Randomize Background Color on Count Change'
                                  : 'Turn Off Random Backgrounds'),
                        ),
                        SizedBox(
                          width: _textFieldWidth,
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
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: viewModel.recitePi,
                          child: const Text('Try To Recite PI'),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 32),
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text:
                                  'Notice that the name TextFormField is using a CurrentTextController, and the count TextFormField is using a regular TextEditingController. ',
                              children: [
                                TextSpan(
                                  text:
                                      '\n\nThe CurrentTextController automatically keeps the value of the TextFormField in sync with the value of the associated CurrentProperty, so when the `name` resets to its original value, the TextFormField will automatically update to reflect that change',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      ' while the `count` TextFormField will not.',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            viewModel.resetAll();
                            appViewModel.reset();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
