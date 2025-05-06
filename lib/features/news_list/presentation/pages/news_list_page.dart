import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/news_list_bloc.dart';
import '../bloc/news_list_event.dart';
import '../bloc/news_list_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_view.dart';

class NewsListPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const NewsListPage({super.key, required this.onThemeToggle});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final ScrollController _scrollController = ScrollController();
  bool isGrid = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsListBloc>().add(LoadMoreNews());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text(
          'Scroll Feed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: isGrid ? 'Show List View' : 'Show Grid View',
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: BlocConsumer<NewsListBloc, NewsListState>(
        listener: (context, state) {
          if (state is NewsListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is NewsListInitial) {
            context.read<NewsListBloc>().add(LoadNews());
            return const LoadingIndicator();
          } else if (state is NewsListLoading) {
            return const LoadingIndicator();
          } else if (state is NewsListError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<NewsListBloc>().add(LoadNews()),
            );
          } else if (state is NewsListLoaded) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: isGrid
                          ? GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: state.news.length,
                              itemBuilder: (context, index) {
                                final news = state.news[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/news-detail',
                                      arguments: news,
                                    );
                                  },
                                  child: Card(
                                    color: Theme.of(context).cardColor,
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: CachedNetworkImage(
                                            imageUrl: news.imageUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                news.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                news.source,
                                                style: TextStyle(
                                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: state.news.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                if (index >= state.news.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      key: Key('loading_more_indicator'),
                                    ),
                                  );
                                }
                                final news = state.news[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/news-detail',
                                      arguments: news,
                                    );
                                  },
                                  child: Card(
                                    color: Theme.of(context).cardColor,
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            news.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            news.description,
                                            style: TextStyle(
                                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          CachedNetworkImage(
                                            imageUrl: news.imageUrl,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const SizedBox(
                                              width: double.infinity,
                                              height: 200,
                                              child: Center(child: CircularProgressIndicator()),
                                            ),
                                            errorWidget: (context, url, error) => const SizedBox(
                                              width: double.infinity,
                                              height: 200,
                                              child: Icon(Icons.error, color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'API Calls: ${state.apiCallCount}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
} 