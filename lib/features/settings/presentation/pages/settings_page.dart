import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajustes')),
        body: ListView(
          children: [
            const _SectionHeader(label: 'Apariencia'),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  AppDimensions.sm,
                  AppDimensions.screenPadding,
                  AppDimensions.md,
                ),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                      label: Text('Sistema'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text('Claro'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text('Oscuro'),
                    ),
                  ],
                  selected: {mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      context.read<ThemeCubit>().setMode(selection.first),
                ),
              ),
            ),
            const Divider(),
            const _SectionHeader(label: 'Cuenta'),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Mi perfil'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showComingSoon(context, 'Mi perfil'),
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.accent),
              title: const Text('Suscripción'),
              subtitle: const Text('Plan Gratuito'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Premium',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              onTap: () => _showComingSoon(context, 'Suscripción'),
            ),
            const Divider(),
            const _SectionHeader(label: 'Notificaciones'),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Pausas activas'),
              subtitle: const Text('Cada 45 minutos en horario laboral'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showComingSoon(context, 'Pausas activas'),
            ),
            ListTile(
              leading: const Icon(Icons.air_rounded),
              title: const Text('Recordatorio de respiración'),
              subtitle: const Text('12:00 PM y 6:00 PM'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showComingSoon(context, 'Recordatorios'),
            ),
            const Divider(),
            const _SectionHeader(label: 'Legal'),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Política de privacidad'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showComingSoon(context, 'Política de privacidad'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Términos de servicio'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showComingSoon(context, 'Términos de servicio'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
            ),
            const SizedBox(height: AppDimensions.lg),
            Center(
              child: Text(
                'ErgoWorkCoach v1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.screenPadding,
          AppDimensions.md, AppDimensions.screenPadding, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
