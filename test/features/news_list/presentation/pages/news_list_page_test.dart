import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/features/news_list/domain/entities/news.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_bloc.dart';
import 'package:news_app/features/news_list/presentation/pages/news_list_page.dart';

class MockNewsListBloc extends Mock implements NewsListBloc {}

void main() {
  late MockNewsListBloc mockNewsListBloc;

  setUp(() {
    mockNewsListBloc = MockNewsListBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<NewsListBloc>.value(
        value: mockNewsListBloc,
        child: const NewsListPage(),
      ),
    );
  }

  testWidgets('shows loading indicator when state is loading',
      (WidgetTester tester) async {
    when(mockNewsListBloc.state).thenReturn(NewsListLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error view when state is error', (WidgetTester tester) async {
    when(mockNewsListBloc.state).thenReturn(const NewsListError('Error'));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Error'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('shows news grid when state is loaded', (WidgetTester tester) async {
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

    when(mockNewsListBloc.state).thenReturn(NewsListLoaded(news));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Test News'), findsOneWidget);
    expect(find.text('Test Source'), findsOneWidget);
  });
} 