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
          builder: (context, child) {
            // Emulates standard 390px mobile viewport on wide screens
            return Container(
              color: const Color(0xFF111C24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: ClipRect(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F8F6),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 24,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
