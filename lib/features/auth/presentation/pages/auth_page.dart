import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/ergo_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.xl),
                const Icon(Icons.self_improvement_rounded,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: AppDimensions.md),
                Text('ErgoWorkCoach',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  'Tu coach de salud integral en el trabajo',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xl),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Iniciar sesión'),
                    Tab(text: 'Registrarse')
                  ],
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.lg),
                Text(
                  'Modo local de demostración. Los perfiles se guardan en este dispositivo; la contraseña no se verifica con un servicio de identidad.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.md),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) => _tabController.index == 0
                          ? _LoginForm(
                              formKey: _loginFormKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              obscurePassword: _obscurePassword,
                              onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              isLoading: isLoading,
                              onSubmit: () {
                                if (_loginFormKey.currentState!.validate()) {
                                  context
                                      .read<AuthBloc>()
                                      .add(AuthSignInRequested(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      ));
                                }
                              },
                            )
                          : _RegisterForm(
                              formKey: _registerFormKey,
                              nameController: _nameController,
                              emailController: _regEmailController,
                              passwordController: _regPasswordController,
                              isLoading: isLoading,
                              onSubmit: () {
                                if (_registerFormKey.currentState!.validate()) {
                                  context
                                      .read<AuthBloc>()
                                      .add(AuthSignUpRequested(
                                        email: _regEmailController.text.trim(),
                                        password: _regPasswordController.text,
                                        displayName:
                                            _nameController.text.trim(),
                                      ));
                                }
                              },
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: AppDimensions.md),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: onToggleObscure,
              ),
            ),
            validator: Validators.password,
          ),
          const SizedBox(height: AppDimensions.lg),
          ErgoButton(
              label: 'Iniciar sesión',
              onPressed: onSubmit,
              isLoading: isLoading),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Nombre completo',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: Validators.displayName,
          ),
          const SizedBox(height: AppDimensions.sm),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: AppDimensions.sm),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Contraseña (mín. 6 caracteres)',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: Validators.password,
          ),
          const SizedBox(height: AppDimensions.md),
          ErgoButton(
              label: 'Crear cuenta', onPressed: onSubmit, isLoading: isLoading),
        ],
      ),
    );
  }
}
