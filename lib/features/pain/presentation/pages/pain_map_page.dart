import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/ergo_button.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/pain_record.dart';
import '../bloc/pain_bloc.dart';
import '../bloc/pain_event.dart';
import '../bloc/pain_state.dart';
import '../widgets/body_map_widget.dart';
import '../widgets/exercise_card_widget.dart';
import '../widgets/exercise_demo_widget.dart';
import '../widgets/pain_scale_widget.dart';

class PainMapPage extends StatelessWidget {
  const PainMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PainBloc, PainState>(
      listenWhen: (previous, current) =>
          (current.recordSaved && !previous.recordSaved) ||
          (current.error != null && current.error != previous.error),
      listener: (context, state) {
        if (state.recordSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Registro guardado'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<PainBloc>().add(const PainSaveAcknowledged());
          context.read<PainBloc>().add(const PainHistoryLoaded());
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.error!), backgroundColor: AppColors.error),
          );
          context.read<PainBloc>().add(const PainErrorAcknowledged());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestor de dolor'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                onPressed: () => _showHistory(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Dónde sientes dolor?',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.info),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        'Orientación general de autocuidado. No reemplaza una evaluación médica o de fisioterapia.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                BodyMapWidget(
                  selectedRegion: state.selectedRegion,
                  onRegionTap: (r) =>
                      context.read<PainBloc>().add(PainRegionSelected(r)),
                ),
                if (state.selectedRegion != null) ...[
                  const SizedBox(height: AppDimensions.xl),
                  const Divider(),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'Zona: ${state.selectedRegion!.displayName}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.painModule),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  PainScaleWidget(
                    value: state.evaScore,
                    onChanged: (v) =>
                        context.read<PainBloc>().add(PainEvaChanged(v)),
                  ),
                  if (state.evaScore == 0) ...[
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Selecciona un nivel mayor a 0 para recibir ejercicios asociados al dolor.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  if (state.evaScore >= 8) ...[
                    const SizedBox(height: AppDimensions.sm),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.medical_services_outlined,
                              size: 18, color: AppColors.warning),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: Text(
                              'El dolor es intenso. Considera consultar a un profesional antes de iniciar ejercicios.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.lg),
                  Text('Tipo de dolor',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDimensions.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PainType.values
                        .map((t) => ChoiceChip(
                              label: Text(_painTypeLabel(t)),
                              selected: state.selectedType == t,
                              onSelected: (_) => context
                                  .read<PainBloc>()
                                  .add(PainTypeSelected(t)),
                              selectedColor:
                                  AppColors.painModule.withValues(alpha: 0.2),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  ErgoButton(
                    label: 'Guardar y ver ejercicios',
                    isLoading: state.isSaving || state.isLoadingExercises,
                    color: AppColors.painModule,
                    icon: Icons.save_rounded,
                    onPressed: state.selectedType == null || state.evaScore == 0
                        ? null
                        : () => _saveAndShowExercises(context, state),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveAndShowExercises(BuildContext context, PainState state) {
    final record = PainRecord(
      id: const Uuid().v4(),
      region: state.selectedRegion!,
      type: state.selectedType!,
      evaScore: state.evaScore,
      recordedAt: DateTime.now(),
    );
    context.read<PainBloc>().add(PainRecordSavedAndExercisesRequested(record));
    _showExerciseSheet(context);
  }

  void _showExerciseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PainBloc>(),
        child: const _ExerciseSheet(),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    context.read<PainBloc>().add(const PainHistoryLoaded());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PainBloc>(),
        child: const _HistorySheet(),
      ),
    );
  }

  String _painTypeLabel(PainType t) {
    switch (t) {
      case PainType.punzante:
        return 'Punzante';
      case PainType.ardor:
        return 'Ardor';
      case PainType.presion:
        return 'Presión';
      case PainType.constante:
        return 'Constante';
      case PainType.intermitente:
        return 'Intermitente';
    }
  }
}

class _ExerciseSheet extends StatefulWidget {
  const _ExerciseSheet();

  @override
  State<_ExerciseSheet> createState() => _ExerciseSheetState();
}

class _ExerciseSheetState extends State<_ExerciseSheet> {
  Exercise? _activeExercise;
  int _repeatCount = 0;

  void _startExercise(Exercise exercise) {
    setState(() {
      _activeExercise = exercise;
      _repeatCount = 0;
    });
  }

  void _addRepetition() {
    if (_activeExercise == null) return;
    setState(() {
      if (_repeatCount < _activeExercise!.reps) {
        _repeatCount += 1;
      }
    });
  }

  void _resetRepetitions() {
    setState(() => _repeatCount = 0);
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.90;

    return BlocBuilder<PainBloc, PainState>(
      builder: (context, state) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Cabecera fija ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding,
                    AppDimensions.sm,
                    AppDimensions.screenPadding,
                    AppDimensions.sm,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        'Ejercicios recomendados',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),

                // ── Contenido scrollable ────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.screenPadding,
                      0,
                      AppDimensions.screenPadding,
                      AppDimensions.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_activeExercise != null) ...[
                          ExerciseDemoWidget(
                            exercise: _activeExercise!,
                            completedReps: _repeatCount,
                            onAddRepetition: _addRepetition,
                            onReset: _resetRepetitions,
                          ),
                        ] else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppDimensions.md),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusLg),
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
                            ),
                            child: Text(
                              'Selecciona un ejercicio para ver el video de movimiento y sus instrucciones.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        const SizedBox(height: AppDimensions.lg),
                        if (state.isLoadingExercises)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (state.exercises.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                                child: Text(
                                    'No hay ejercicios disponibles para esta zona')),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: state.exercises.length,
                            itemBuilder: (context, i) {
                              final ex = state.exercises[i];
                              return ExerciseCardWidget(
                                exercise: ex,
                                onStart: () => _startExercise(ex),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistorySheet extends StatelessWidget {
  const _HistorySheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, controller) => BlocBuilder<PainBloc, PainState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding),
                child: Text('Historial de dolor',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: AppDimensions.md),
              Expanded(
                child: state.history.isEmpty
                    ? const Center(child: Text('Sin registros de dolor aún'))
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.screenPadding),
                        itemCount: state.history.length,
                        itemBuilder: (context, i) {
                          final r = state.history[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.painModule.withValues(alpha: 0.15),
                              child: Text('${r.evaScore}',
                                  style: const TextStyle(
                                      color: AppColors.painModule,
                                      fontWeight: FontWeight.w700)),
                            ),
                            title: Text(r.region.displayName),
                            subtitle: Text(
                              '${_painTypeHistoryLabel(r.type)} · ${DateFormat('dd/MM/yyyy HH:mm').format(r.recordedAt)}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _painTypeHistoryLabel(PainType type) {
  switch (type) {
    case PainType.punzante:
      return 'Punzante';
    case PainType.ardor:
      return 'Ardor';
    case PainType.presion:
      return 'Presión';
    case PainType.constante:
      return 'Constante';
    case PainType.intermitente:
      return 'Intermitente';
  }
}
