import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news_list/domain/entities/news.dart';
import 'package:news_app/features/news_list/domain/repositories/news_repository.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_bloc.dart';

@GenerateMocks([NewsRepository])
import 'news_list_bloc_test.mocks.dart';

void main() {
  late MockNewsRepository mockNewsRepository;
  late NewsListBloc newsListBloc;

  setUp(() {
    mockNewsRepository = MockNewsRepository();
    newsListBloc = NewsListBloc(newsRepository: mockNewsRepository);
  });

  tearDown(() {
    newsListBloc.close();
  });

  test('initial state should be NewsListInitial', () {
    expect(newsListBloc.state, equals(NewsListInitial()));
  });

  final tNews = [
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

  blocTest<NewsListBloc, NewsListState>(
    'emits [NewsListLoading, NewsListLoaded] when news is loaded successfully',
    build: () {
      when(mockNewsRepository.getNews())
          .thenAnswer((_) async => Right(tNews));
      return newsListBloc;
    },
    act: (bloc) => bloc.add(LoadNews()),
    expect: () => [
      NewsListLoading(),
      NewsListLoaded(tNews),
    ],
    verify: (_) {
      verify(mockNewsRepository.getNews()).called(1);
    },
  );

  blocTest<NewsListBloc, NewsListState>(
    'emits [NewsListLoading, NewsListError] when news loading fails',
    build: () {
      when(mockNewsRepository.getNews())
          .thenAnswer((_) async => Left(ServerFailure(message: 'Error')));
      return newsListBloc;
    },
    act: (bloc) => bloc.add(LoadNews()),
    expect: () => [
      NewsListLoading(),
      NewsListError('Error'),
    ],
    verify: (_) {
      verify(mockNewsRepository.getNews()).called(1);
    },
  );
} 