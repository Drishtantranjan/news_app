import 'package:equatable/equatable.dart';
import '../../domain/entities/news.dart';

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
