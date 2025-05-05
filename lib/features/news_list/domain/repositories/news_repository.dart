import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/news.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<News>>> getNews({int page = 1});
  Future<Either<Failure, News>> getNewsById(String id);
} 