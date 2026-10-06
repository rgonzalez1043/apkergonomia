import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../gamification/presentation/cubit/gamification_cubit.dart';
import '../../domain/entities/breathing_technique.dart';
import '../bloc/breathing_bloc.dart';
import '../bloc/breathing_event.dart';
import '../bloc/breathing_state.dart';
import '../widgets/breathing_circle_widget.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _pause() {
    final bloc = context.read<BreathingBloc>();
    if (bloc.state.isRunning) bloc.add(const BreathingSessionPaused());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TickerMode.of(context)) _pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BreathingBloc, BreathingState>(
      listenWhen: (previous, current) =>
          !previous.isComplete && current.isComplete,
      listener: (context, _) =>
          context.read<GamificationCubit>().completeBreathingSession(),
      builder: (context, state) {
        if (state.selectedTechnique != null &&
            state.phase != BreathingPhase.idle) {
          return _SessionView(
              technique: state.selectedTechnique!, state: state);
        }
        return _SelectionView(state: state);
      },
    );
  }
}

class _SelectionView extends StatelessWidget {
  final BreathingState state;
  const _SelectionView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Respiración')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              children: [
                if (state.error != null) ...[
                  Text(state.error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  TextButton(
                      onPressed: () => context
                          .read<BreathingBloc>()
                          .add(const BreathingTechniquesLoaded()),
                      child: const Text('Reintentar')),
                ],
                Text(
                  'Elige una técnica',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'Cada técnica está diseñada para un momento específico de tu día.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.lg),
                ...state.techniques.map((t) => _TechniqueCard(technique: t)),
              ],
            ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final BreathingTechnique technique;
  const _TechniqueCard({required this.technique});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context
            .read<BreathingBloc>()
            .add(BreathingTechniqueSelected(technique));
        context.read<BreathingBloc>().add(const BreathingSessionStarted());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.md),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: technique.ambientColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
              color: technique.ambientColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: technique.ambientColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.air_rounded, color: Colors.white70),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(technique.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(technique.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _PillLabel(
                          label: _scenarioLabel(technique.scenario),
                          color: technique.ambientColor),
                      const SizedBox(width: 8),
                      _PillLabel(
                        label:
                            '${technique.totalCycles} ciclos · ${technique.totalDurationSeconds ~/ 60} min',
                        color: AppColors.textMutedDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_rounded,
                size: 32, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  String _scenarioLabel(BreathingScenario s) {
    switch (s) {
      case BreathingScenario.deporte:
        return 'Deporte';
      case BreathingScenario.estres:
        return 'Estrés';
      case BreathingScenario.calma:
        return 'Calma';
      case BreathingScenario.foco:
        return 'Foco';
      case BreathingScenario.emergencia:
        return 'Emergencia';
      case BreathingScenario.recuperacion:
        return 'Recuperación';
      case BreathingScenario.pausa:
        return 'Pausa';
      case BreathingScenario.energia:
        return 'Energía';
    }
  }
}

class _PillLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _PillLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style:
              Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}

class _SessionView extends StatelessWidget {
  final BreathingTechnique technique;
  final BreathingState state;
  const _SessionView({required this.technique, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: technique.ambientColor.withValues(alpha: 0.05),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context
              .read<BreathingBloc>()
              .add(const BreathingSessionStopped()),
        ),
        title: Text(technique.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: state.isComplete
                    ? _CompletionView(technique: technique)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BreathingCircleWidget(
                            phase: state.phase,
                            secondsRemaining: state.secondsRemaining,
                            ambientColor: technique.ambientColor,
                            isRunning: state.isRunning,
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          Text(
                            'Ciclo ${state.currentCycle + 1} de ${technique.totalCycles}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            technique.avatarGuideScript,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Row(
              children: [
                if (!state.isComplete) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isRunning
                          ? () => context
                              .read<BreathingBloc>()
                              .add(const BreathingSessionPaused())
                          : () => context
                              .read<BreathingBloc>()
                              .add(const BreathingSessionResumed()),
                      icon: Icon(state.isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      label: Text(state.isRunning ? 'Pausar' : 'Continuar'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context
                        .read<BreathingBloc>()
                        .add(const BreathingSessionStopped()),
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Terminar'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  final BreathingTechnique technique;
  const _CompletionView({required this.technique});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 64,
          color: AppColors.success,
        ),
        const SizedBox(height: AppDimensions.md),
        Text('¡Sesión completa!',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppDimensions.sm),
        Text(
          '${technique.totalCycles} ciclos · ${technique.totalDurationSeconds ~/ 60} minutos',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text('+50 XP',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.accent)),
      ],
    );
  }
}
