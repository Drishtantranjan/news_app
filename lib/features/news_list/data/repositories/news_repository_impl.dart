import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/news.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';
import '../models/news_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<News>>> getNews({int page = 1}) async {
    try {
      final newsList = await remoteDataSource.getNews(page: page);
      return Right(newsList);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, News>> getNewsById(String id) async {
    try {
      final news = await remoteDataSource.getNewsById(id);
      return Right(news);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
} 