import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/news.dart';
import '../../domain/repositories/news_repository.dart';
import 'dart:collection';
import 'news_list_event.dart';
import 'news_list_state.dart';


class NewsListBloc extends Bloc<NewsListEvent, NewsListState> {
  final NewsRepository newsRepository;
  int _currentPage = 1;
  bool _isFetching = false;
  List<News> _allNews = [];
  bool _hasReachedEnd = false;
  final Queue<List<News>> _prefetchQueue = Queue<List<News>>();
  int _apiCallCount = 0;

  NewsListBloc({required this.newsRepository}) : super(NewsListInitial()) {
    on<LoadNews>(_onLoadNews);
    on<LoadMoreNews>(_onLoadMoreNews);
  }

  Future<void> _onLoadNews(
    LoadNews event,
    Emitter<NewsListState> emit,
  ) async {
    emit(NewsListLoading());
    _currentPage = 1;
    _allNews = [];
    _hasReachedEnd = false;
    _prefetchQueue.clear();
    _apiCallCount = 0;

    _apiCallCount++;
    final result = await newsRepository.getNews(page: _currentPage);
    await result.fold(
      (failure) async => emit(NewsListError(failure.message)),
      (news) async {
        _allNews = news;
        _hasReachedEnd = news.isEmpty;
        emit(NewsListLoaded(
          _allNews,
          hasReachedEnd: _hasReachedEnd,
          isLoadingMore: false,
          apiCallCount: _apiCallCount,
        ));

        if (!_hasReachedEnd) {
          // Prefetch next page
          await _prefetchNextPage();
          if (!emit.isDone) {
            emit(NewsListLoaded(
              _allNews,
              hasReachedEnd: _hasReachedEnd,
              isLoadingMore: false,
              apiCallCount: _apiCallCount,
            ));
          }
        }
      },
    );
  }

  Future<void> _onLoadMoreNews(
    LoadMoreNews event,
    Emitter<NewsListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NewsListLoaded || currentState.isLoadingMore || _hasReachedEnd) return;

    _isFetching = true;
    _allNews = List.from(currentState.news);
    _apiCallCount = currentState.apiCallCount;
    emit(NewsListLoaded(
      _allNews,
      hasReachedEnd: currentState.hasReachedEnd,
      isLoadingMore: true,
      apiCallCount: _apiCallCount,
    ));

    List<News> nextPageNews;
    if (_prefetchQueue.isNotEmpty) {
      nextPageNews = _prefetchQueue.removeFirst();
      _currentPage++;
    } else {
      _currentPage++;
      _apiCallCount++;
      final result = await newsRepository.getNews(page: _currentPage);
      final news = result.fold((failure) => <News>[], (news) => news);
      nextPageNews = news;
    }

    final newArticles = nextPageNews.where((n) => !_allNews.any((a) => a.id == n.id)).toList();
    if (newArticles.isEmpty) {
      _hasReachedEnd = true;
      emit(NewsListLoaded(
        _allNews,
        hasReachedEnd: true,
        isLoadingMore: false,
        apiCallCount: _apiCallCount,
      ));
    } else {
      _allNews.addAll(newArticles);
      emit(NewsListLoaded(
        _allNews,
        hasReachedEnd: false,
        isLoadingMore: false,
        apiCallCount: _apiCallCount,
      ));

      // Prefetch the next page after serving this one
      await _prefetchNextPage();
      if (!emit.isDone) {
        emit(NewsListLoaded(
          _allNews,
          hasReachedEnd: _hasReachedEnd,
          isLoadingMore: false,
          apiCallCount: _apiCallCount,
        ));
      }
    }
    _isFetching = false;
  }

  Future<void> _prefetchNextPage() async {
    if (_hasReachedEnd) return;
    final nextPage = _currentPage + 1;
    _apiCallCount++;
    final result = await newsRepository.getNews(page: nextPage);
    result.fold(
      (failure) {},
      (news) {
        if (news.isNotEmpty) {
          _prefetchQueue.add(news);
        } else {
          _hasReachedEnd = true;
        }
      },
    );
  }
} 