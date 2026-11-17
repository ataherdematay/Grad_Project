import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/auth_bloc.dart';
import 'core/bloc/job_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'core/repositories/job_repository.dart';
import 'core/repositories/mock_job_repository.dart';
import 'core/supabase/app_config.dart';
import 'core/supabase/supabase_job_repository.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Real database only when SUPABASE_URL and SUPABASE_ANON_KEY are given (see app_config.dart); otherwise the mock data is used.
  if (AppConfig.useSupabase) {
    await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  }
  runApp(const BiTadilatApp());
}

class BiTadilatApp extends StatelessWidget {
  const BiTadilatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final JobRepository jobRepository =
        AppConfig.useSupabase ? SupabaseJobRepository(Supabase.instance.client) : MockJobRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<JobRepository>.value(value: jobRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(
            create: (_) => JobBloc(repository: jobRepository)
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
