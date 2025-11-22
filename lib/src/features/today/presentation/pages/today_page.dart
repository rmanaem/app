import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/today/presentation/viewmodels/today_viewmodel.dart';

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
            : state.plan == null
            ? Center(
                child: Text(
                  state.errorMessage ?? 'No Plan Found',
                  style: TextStyle(color: colors.ink),
                ),
              )
            : _buildContent(context, vm),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TodayViewModel vm) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final state = vm.state;
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, MMM d').format(now);

    return Padding(
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: textTheme.headlineMedium?.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),

          // THE BIG NUMBER (Placeholder for Ring)
          Center(
            child: Column(
              children: [
                Text(
                  '${vm.remainingCalories}',
                  style: textTheme.displayLarge?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'KCAL REMAINING',
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.inkSubtle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // MACRO DEBUG ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroStat(
                'Protein',
                state.consumedProtein,
                state.plan!.proteinGrams,
                colors,
                textTheme,
              ),
              _macroStat(
                'Fats',
                state.consumedFat,
                state.plan!.fatGrams,
                colors,
                textTheme,
              ),
              _macroStat(
                'Carbs',
                state.consumedCarbs,
                state.plan!.carbGrams,
                colors,
                textTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroStat(
    String label,
    int current,
    int target,
    AppColors colors,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
        ),
        const SizedBox(height: 4),
        Text(
          '$current / $target g',
          style: textTheme.bodyLarge?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
