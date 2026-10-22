import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/auth_bloc.dart';
import 'core/bloc/job_bloc.dart';
import 'core/repositories/mock_job_repository.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BiTadilatApp());
}

class BiTadilatApp extends StatelessWidget {
  const BiTadilatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mockJobRepository = MockJobRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: mockJobRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(
            create: (_) => JobBloc(repository: mockJobRepository)
              ..add(const LoadCustomerJobsEvent())
              ..add(const LoadProJobsEvent()),
          ),
        ],
        child: MaterialApp.router(
          title: 'BiTadilat',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
