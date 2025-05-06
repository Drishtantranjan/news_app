import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:news_app/features/news_list/domain/entities/news.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_bloc.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_event.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_state.dart';
import 'package:news_app/features/news_list/presentation/pages/news_list_page.dart';
import 'package:news_app/shared/widgets/loading_indicator.dart';
import 'package:news_app/shared/widgets/error_view.dart';

class MockNewsListBloc extends Mock implements NewsListBloc {
  final _stateController = BehaviorSubject<NewsListState>.seeded(NewsListInitial());

  @override
  Stream<NewsListState> get stream => _stateController.stream;

  @override
  NewsListState get state => _stateController.value;

  void emit(NewsListState state) {
    _stateController.add(state);
  }

  void dispose() {
    _stateController.close();
  }
}

void main() {
  late MockNewsListBloc mockNewsListBloc;

  setUp(() {
    mockNewsListBloc = MockNewsListBloc();
  });

  tearDown(() {
    mockNewsListBloc.dispose();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<NewsListBloc>.value(
        value: mockNewsListBloc,
        child: NewsListPage(
          onThemeToggle: () {},
        ),
      ),
    );
  }

  testWidgets('shows loading indicator when state is loading',
      (WidgetTester tester) async {
    mockNewsListBloc.emit(NewsListLoading());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(LoadingIndicator), findsOneWidget);
  });

  testWidgets('shows error view when state is error', (WidgetTester tester) async {
    const errorMessage = 'Error';
    mockNewsListBloc.emit(const NewsListError(errorMessage));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == errorMessage &&
            widget.style?.color == Colors.red &&
            widget.style?.fontSize == 16,
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows news list when state is loaded', (WidgetTester tester) async {
    final news = [
      News(
        id: '1',
        title: 'Test News',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        source: 'Test Source',
        publishedAt: DateTime.now(),
        url: 'https://example.com',
      ),
    ];

    mockNewsListBloc.emit(NewsListLoaded(news));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == 'Test News' &&
            widget.style?.fontWeight == FontWeight.bold &&
            widget.style?.fontSize == 16,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == 'Test Description' &&
            widget.style?.fontSize == 12,
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads news when initial state is shown', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(LoadingIndicator), findsOneWidget);
  });

  testWidgets('toggles between grid and list view', (WidgetTester tester) async {
    final news = [
      News(
        id: '1',
        title: 'Test News',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        source: 'Test Source',
        publishedAt: DateTime.now(),
        url: 'https://example.com',
      ),
    ];

    mockNewsListBloc.emit(NewsListLoaded(news));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Initially shows list view
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(GridView), findsNothing);

    // Tap the view toggle button
    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Now shows grid view
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('shows loading indicator when loading more news',
      (WidgetTester tester) async {
    final news = [
      News(
        id: '1',
        title: 'Test News',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        source: 'Test Source',
        publishedAt: DateTime.now(),
        url: 'https://example.com',
      ),
    ];

    mockNewsListBloc.emit(NewsListLoaded(news, isLoadingMore: true));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(
      find.descendant(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.symmetric(vertical: 16),
        ),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
  });

  testWidgets('handles theme toggle', (WidgetTester tester) async {
    bool themeToggled = false;
    final news = [
      News(
        id: '1',
        title: 'Test News',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        source: 'Test Source',
        publishedAt: DateTime.now(),
        url: 'https://example.com',
      ),
    ];

    mockNewsListBloc.emit(NewsListLoaded(news));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<NewsListBloc>.value(
          value: mockNewsListBloc,
          child: NewsListPage(
            onThemeToggle: () {
              themeToggled = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap the theme toggle button
    await tester.tap(find.byIcon(Icons.nightlight_round));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(themeToggled, true);
  });
} 