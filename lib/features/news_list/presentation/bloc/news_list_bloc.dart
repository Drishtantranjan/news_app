import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/news.dart';
import '../../domain/repositories/news_repository.dart';
import 'dart:collection';

// Events
abstract class NewsListEvent extends Equatable {
  const NewsListEvent();

  @override
  List<Object> get props => [];
}

class LoadNews extends NewsListEvent {}
class LoadMoreNews extends NewsListEvent {}

// States
abstract class NewsListState extends Equatable {
  const NewsListState();

  @override
  List<Object> get props => [];
}

class NewsListInitial extends NewsListState {}

class NewsListLoading extends NewsListState {}

class NewsListLoaded extends NewsListState {
  final List<News> news;
  final bool hasReachedEnd;
  final bool isLoadingMore;
  final int apiCallCount;

  const NewsListLoaded(
    this.news, {
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.apiCallCount = 0,
  });

  @override
  List<Object> get props => [news, hasReachedEnd, isLoadingMore, apiCallCount];
}

class NewsListError extends NewsListState {
  final String message;

  const NewsListError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
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
    result.fold(
      (failure) => emit(NewsListError(failure.message)),
      (news) async {
        _allNews = news;
        _hasReachedEnd = news.length < 3;
        emit(NewsListLoaded(_allNews, hasReachedEnd: _hasReachedEnd, isLoadingMore: false, apiCallCount: _apiCallCount));
        // Prefetch next page
        await _prefetchNextPage();
      },
    );
  }

  Future<void> _onLoadMoreNews(
    LoadMoreNews event,
    Emitter<NewsListState> emit,
  ) async {
    if (_isFetching || _hasReachedEnd) return;
    _isFetching = true;
    emit(NewsListLoaded(_allNews, hasReachedEnd: _hasReachedEnd, isLoadingMore: true, apiCallCount: _apiCallCount));

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
    } else {
      _allNews.addAll(newArticles);
      if (newArticles.length < 3) _hasReachedEnd = true;
    }
    emit(NewsListLoaded(_allNews, hasReachedEnd: _hasReachedEnd, isLoadingMore: false, apiCallCount: _apiCallCount));
    _isFetching = false;

    // Prefetch the next page after serving this one
    await _prefetchNextPage();
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
        }
      },
    );
  }
} 