import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news_list/domain/entities/news.dart';
import 'package:news_app/features/news_list/domain/repositories/news_repository.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_bloc.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_event.dart';
import 'package:news_app/features/news_list/presentation/bloc/news_list_state.dart';

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

  final tMoreNews = [
    News(
      id: '2',
      title: 'More Test News',
      description: 'More Test Description',
      imageUrl: 'https://example.com/image2.jpg',
      source: 'Test Source 2',
      publishedAt: DateTime.now(),
      url: 'https://example.com/2',
    ),
  ];

  group('LoadNews', () {
    blocTest<NewsListBloc, NewsListState>(
      'emits [NewsListLoading, NewsListLoaded] when news is loaded successfully',
      build: () {
        when(mockNewsRepository.getNews(page: 1))
            .thenAnswer((_) async => Right(tNews));
        when(mockNewsRepository.getNews(page: 2))
            .thenAnswer((_) async => Right(tMoreNews));
        return newsListBloc;
      },
      act: (bloc) => bloc.add(LoadNews()),
      expect: () => [
        NewsListLoading(),
        NewsListLoaded(tNews, apiCallCount: 1),
        NewsListLoaded(tNews, apiCallCount: 2),
      ],
      verify: (_) {
        verify(mockNewsRepository.getNews(page: 1)).called(1);
        verify(mockNewsRepository.getNews(page: 2)).called(1);
      },
    );

    blocTest<NewsListBloc, NewsListState>(
      'emits [NewsListLoading, NewsListError] when news loading fails',
      build: () {
        when(mockNewsRepository.getNews(page: 1))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Error')));
        return newsListBloc;
      },
      act: (bloc) => bloc.add(LoadNews()),
      expect: () => [
        NewsListLoading(),
        NewsListError('Error'),
      ],
      verify: (_) {
        verify(mockNewsRepository.getNews(page: 1)).called(1);
      },
    );

    blocTest<NewsListBloc, NewsListState>(
      'emits [NewsListLoading, NewsListLoaded] with empty list when no news is available',
      build: () {
        when(mockNewsRepository.getNews(page: 1))
            .thenAnswer((_) async => const Right([]));
        return newsListBloc;
      },
      act: (bloc) => bloc.add(LoadNews()),
      expect: () => [
        NewsListLoading(),
        NewsListLoaded(const [], hasReachedEnd: true, apiCallCount: 1),
      ],
      verify: (_) {
        verify(mockNewsRepository.getNews(page: 1)).called(1);
      },
    );
  });

  group('LoadMoreNews', () {
    blocTest<NewsListBloc, NewsListState>(
      'emits updated NewsListLoaded with more news when loading more succeeds',
      seed: () => NewsListLoaded(tNews, apiCallCount: 1),
      build: () {
        when(mockNewsRepository.getNews(page: 2))
            .thenAnswer((_) async => Right(tMoreNews));
        when(mockNewsRepository.getNews(page: 3))
            .thenAnswer((_) async => Right([]));
        return newsListBloc;
      },
      act: (bloc) => bloc.add(LoadMoreNews()),
      expect: () => [
        NewsListLoaded([...tNews, ...tMoreNews], isLoadingMore: true, apiCallCount: 1),
        NewsListLoaded([...tNews, ...tMoreNews], apiCallCount: 2),
        NewsListLoaded([...tNews, ...tMoreNews], hasReachedEnd: true, apiCallCount: 3),
      ],
      verify: (_) {
        verify(mockNewsRepository.getNews(page: 2)).called(1);
        verify(mockNewsRepository.getNews(page: 3)).called(1);
      },
    );

    blocTest<NewsListBloc, NewsListState>(
      'emits NewsListLoaded with error when loading more fails',
      seed: () => NewsListLoaded(tNews, apiCallCount: 1),
      build: () {
        when(mockNewsRepository.getNews(page: 2))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Error loading more')));
        return newsListBloc;
      },
      act: (bloc) => bloc.add(LoadMoreNews()),
      expect: () => [
        NewsListLoaded(tNews, isLoadingMore: true, apiCallCount: 1),
        NewsListLoaded(tNews, hasReachedEnd: true, apiCallCount: 2),
      ],
      verify: (_) {
        verify(mockNewsRepository.getNews(page: 2)).called(1);
      },
    );

    blocTest<NewsListBloc, NewsListState>(
      'does not emit new state when already loading more',
      seed: () => NewsListLoaded([...tNews, ...tMoreNews], isLoadingMore: true, apiCallCount: 1),
      build: () {
        when(mockNewsRepository.getNews(page: 2))
            .thenAnswer((_) async => Right(tMoreNews));
        when(mockNewsRepository.getNews(page: 3))
            .thenAnswer((_) async => Right([]));
        return newsListBloc;
      },
      act: (bloc) => bloc.add(LoadMoreNews()),
      expect: () => [],
      verify: (_) {
        verifyNever(mockNewsRepository.getNews(page: 2));
        verifyNever(mockNewsRepository.getNews(page: 3));
      },
    );

    blocTest<NewsListBloc, NewsListState>(
      'emits updated NewsListLoaded with empty list when no more news is available',
      seed: () => NewsListLoaded(tNews, apiCallCount: 1),
      build: () {
        when(mockNewsRepository.getNews(page: 2))
            .thenAnswer((_) async => const Right([]));
        return newsListBloc;
      },
      act: (bloc) => bloc.add(LoadMoreNews()),
      expect: () => [
        NewsListLoaded(tNews, isLoadingMore: true, apiCallCount: 1),
        NewsListLoaded(tNews, hasReachedEnd: true, apiCallCount: 2),
      ],
      verify: (_) {
        verify(mockNewsRepository.getNews(page: 2)).called(1);
      },
    );
  });
} 