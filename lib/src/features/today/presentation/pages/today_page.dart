import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/nutrition/presentation/navigation/nutrition_page_arguments.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/weight_picker_sheet.dart';
import 'package:starter_app/src/features/today/presentation/viewmodels/today_viewmodel.dart';
import 'package:starter_app/src/features/today/presentation/viewstate/today_view_state.dart';
import 'package:starter_app/src/features/today/presentation/widgets/nutrition_summary_card.dart';
import 'package:starter_app/src/features/today/presentation/widgets/today_quick_actions_row.dart';
import 'package:starter_app/src/features/today/presentation/widgets/training_summary_card.dart';
import 'package:starter_app/src/features/today/presentation/widgets/weight_summary_card.dart';

/// Today dashboard page displaying daily nutrition progress.
///
/// Shows the user's calorie budget, consumed macros, and remaining
/// targets for the current day.
class TodayPage extends StatelessWidget {
  /// Creates the today page.
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<TodayViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.hasError
            ? _ErrorState(
                message: state.errorMessage ?? 'Something went wrong.',
              )
            : _buildContent(context, vm),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TodayViewModel vm) {
    final state = vm.state;
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, MMM d').format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TodayHeader(
              formattedDate: formattedDate,
              state: state,
            ),
            const SizedBox(height: 24),
            _TodayCalorieHero(
              state: state,
              onTap: () => _onCalorieHeroTap(context),
            ),
            const SizedBox(height: 16),
            TodayQuickActionsRow(
              onLogFood: () => _onLogFoodTap(context),
              onLogWeight: () => _onLogWeightTap(context),
              onStartWorkout: () => _onStartWorkoutTap(context),
            ),
            const SizedBox(height: 16),
            NutritionSummaryCard(
              consumedCalories: state.consumedCalories,
              targetCalories: state.plan?.dailyCalories.round() ?? 0,
              consumedProtein: state.consumedProtein,
              targetProtein: state.plan?.proteinGrams ?? 0,
              consumedCarbs: state.consumedCarbs,
              targetCarbs: state.plan?.carbGrams ?? 0,
              consumedFat: state.consumedFat,
              targetFat: state.plan?.fatGrams ?? 0,
              onTap: () => _onLogFoodTap(context),
            ),
            const SizedBox(height: 12),
            TrainingSummaryCard(
              nextTitle: state.nextWorkoutTitle ?? 'No program set up yet',
              nextSubtitle: state.nextWorkoutSubtitle,
              lastTitle:
                  state.lastWorkoutTitle ?? 'You haven’t logged a session yet.',
              lastSubtitle: state.lastWorkoutSubtitle,
              onTapNext: () => _onStartWorkoutTap(context),
              onTapLast: () => _onStartWorkoutTap(context),
            ),
            const SizedBox(height: 12),
            WeightSummaryCard(
              lastWeightLabel: state.lastWeightKg != null
                  ? '${state.lastWeightKg!.toStringAsFixed(1)} kg'
                  : 'No weight logged yet',
              trendLabel: state.weightDeltaLabel,
              showTrend: state.hasWeightTrend,
              onWeighIn: () => _onLogWeightTap(context),
              onTap: () => _onLogWeightTap(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _onCalorieHeroTap(BuildContext context) {
    _onLogFoodTap(context);
  }

  void _onLogFoodTap(BuildContext context) {
    context.go(
      '/nutrition',
      extra: const NutritionPageArguments(showQuickAddSheet: true),
    );
  }

  Future<void> _onLogWeightTap(BuildContext context) async {
    final vm = context.read<TodayViewModel>();
    final initialKg = vm.state.lastWeightKg ?? 75;
    await showWeightPickerSheet(
      context: context,
      unit: UnitSystem.metric,
      current: BodyWeight.fromKg(initialKg),
    );
  }

  void _onStartWorkoutTap(BuildContext context) {
    context.go('/training');
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({
    required this.formattedDate,
    required this.state,
  });

  final String formattedDate;
  final TodayViewState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.inkSubtle,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (state.planLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.heroChip,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              border: Border.all(color: colors.ringTrack),
            ),
            child: Text(
              state.planLabel!,
              style: textTheme.labelSmall?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _TodayCalorieHero extends StatelessWidget {
  const _TodayCalorieHero({
    required this.state,
    required this.onTap,
  });

  final TodayViewState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final remaining =
        (state.plan?.dailyCalories.round() ?? 0) - state.consumedCalories;
    final target = state.plan?.dailyCalories.round() ?? 0;
    final eaten = state.consumedCalories;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: colors.ringTrack),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                remaining.toString(),
                style: textTheme.displayMedium?.copyWith(
                  color: colors.ink,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'kcal remaining',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.inkSubtle,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$eaten eaten · $target target',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.inkSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(color: colors.ink),
        textAlign: TextAlign.center,
      ),
    );
  }
}
