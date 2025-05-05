import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app/features/news_list/domain/entities/news.dart';
import 'package:news_app/features/news_list/presentation/pages/news_detail_page.dart';
import 'core/network/dio_client.dart';
import 'features/news_list/data/datasources/news_remote_data_source.dart';
import 'features/news_list/data/repositories/news_repository_impl.dart';
import 'features/news_list/domain/repositories/news_repository.dart';
import 'features/news_list/presentation/bloc/news_list_bloc.dart';
import 'features/news_list/presentation/pages/news_list_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';

final getIt = GetIt.instance;
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
}

Future<void> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('theme_mode');
  if (theme == 'dark') {
    themeModeNotifier.value = ThemeMode.dark;
  } else if (theme == 'light') {
    themeModeNotifier.value = ThemeMode.light;
  } else {
    themeModeNotifier.value = ThemeMode.system;
  }
}

void setupDependencies() {
  // Core
  getIt.registerLazySingleton(() => DioClient());

  // Data sources
  getIt.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(dioClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(remoteDataSource: getIt()),
  );

  // BLoCs
  getIt.registerFactory(
    () => NewsListBloc(newsRepository: getIt()),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadThemeMode();
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'News App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
            scaffoldBackgroundColor: Colors.grey[200],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            cardColor: Colors.white,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF181818),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardColor: const Color(0xFF232323),
            useMaterial3: true,
          ),
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/news-list': (context) => BlocProvider(
                  create: (context) => getIt<NewsListBloc>(),
                  child: NewsListPage(onThemeToggle: () async {
                    if (themeModeNotifier.value == ThemeMode.light) {
                      themeModeNotifier.value = ThemeMode.dark;
                      await saveThemeMode(ThemeMode.dark);
                    } else {
                      themeModeNotifier.value = ThemeMode.light;
                      await saveThemeMode(ThemeMode.light);
                    }
                  }),
                ),
            '/news-detail': (context) {
              final news = ModalRoute.of(context)!.settings.arguments as News;
              return NewsDetailPage(news: news);
            },
          },
        );
      },
    );
  }
}
