// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app/core/network/dio_client.dart';
import 'package:news_app/features/news_list/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news_list/domain/repositories/news_repository.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_bloc.dart';
import 'package:news_app/features/news_list/domain/entities/news.dart';
import 'package:news_app/main.dart';
import 'package:news_app/features/splash/presentation/pages/splash_page.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app/features/news_list/presentation/pages/news_list_page.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_state.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_event.dart';

@GenerateMocks([NewsRepository, NewsRemoteDataSource, DioClient])
import 'widget_test.mocks.dart';

class MockCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const MockCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      color: Colors.grey,
    );
  }
}

void main() {
  late MockNewsRepository mockNewsRepository;
  late NewsListBloc newsListBloc;
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.instance;
    getIt.reset();

    mockNewsRepository = MockNewsRepository();
    newsListBloc = NewsListBloc(newsRepository: mockNewsRepository);

    // Set up mock responses
    when(mockNewsRepository.getNews(page: anyNamed('page'))).thenAnswer((_) async => Right([
      News(
        id: '1',
        title: 'Test News',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        source: 'Test Source',
        publishedAt: DateTime.now(),
        url: 'https://example.com',
      ),
    ]));

    // Register dependencies
    getIt.registerSingleton<DioClient>(MockDioClient());
    getIt.registerSingleton<NewsRemoteDataSource>(MockNewsRemoteDataSource());
    getIt.registerSingleton<NewsRepository>(mockNewsRepository);
    getIt.registerFactory<NewsListBloc>(() => newsListBloc);
  });

  tearDown(() {
    newsListBloc.close();
    getIt.reset();
  });

  testWidgets('News app smoke test', (WidgetTester tester) async {
    // Set up a fake asset bundle
    await tester.binding.setSurfaceSize(const Size(400, 800));
    TestWidgetsFlutterBinding.ensureInitialized();

    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(SplashPage), findsOneWidget);
    
    // Wait for splash screen timer
    await tester.pump(const Duration(seconds: 2)); // Wait for splash screen
    await tester.pump(); // Process navigation
  });

  testWidgets('News list page shows news', (WidgetTester tester) async {
    // Manually emit the state before building the widget
    newsListBloc.emit(NewsListLoaded([
      News(
        id: '1',
        title: 'Test News',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        source: 'Test Source',
        publishedAt: DateTime.now(),
        url: 'https://example.com',
      ),
    ]));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: newsListBloc,
          child: NewsListPage(onThemeToggle: () {}),
        ),
      ),
    );

    // Wait for widget to build
    await tester.pump();

    // Switch to grid view
    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pump();

    // Should show news list
    expect(find.text('Test News'), findsOneWidget);
    expect(find.text('Test Source'), findsOneWidget);
  });
}
