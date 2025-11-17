import 'package:flutter/material.dart';

import 'package:starter_app/src/features/sample_counter/domain/use_cases/increment_counter.dart';
import 'package:starter_app/src/features/sample_counter/presentation/viewmodels/sample_counter_view_model.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Demo feature page showcasing how MVVM composes the atomic widgets.
class SampleCounterPage extends StatelessWidget {
  /// Creates the page with a supplied [viewModel].
  const SampleCounterPage({required this.viewModel, super.key});

  /// Convenience factory wiring minimal dependencies for demos/tests.
  factory SampleCounterPage.sample() => SampleCounterPage(
    viewModel: SampleCounterViewModel(
      IncrementCounter(),
    ),
  );

  /// Read-only ViewModel provided by DI.
  final SampleCounterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sample Counter Feature')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${viewModel.value}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: viewModel.isBusy ? 'Loading…' : 'Increment',
                  onPressed: viewModel.isBusy ? null : viewModel.increment,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
