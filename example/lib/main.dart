import 'package:current/current.dart';
import 'package:current_counter_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

import 'application_view_model.dart';
import 'components/mission_control_shell.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key, ApplicationViewModel? viewModel})
      : viewModel = viewModel ?? ApplicationViewModel();

  final ApplicationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Current Mission Control',
      theme: SpaceMissionTheme.themeData,
      home: Current<ApplicationViewModel>(
        viewModel,
        child: MissionControlShell(viewModel: viewModel),
      ),
    );
  }
}
