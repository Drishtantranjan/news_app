// Events
abstract class NewsListEvent extends Equatable {
  const NewsListEvent();

  @override
  List<Object> get props => [];
}

class LoadNews extends NewsListEvent {}
class LoadMoreNews extends NewsListEvent {}


