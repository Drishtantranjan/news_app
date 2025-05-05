import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/dio_client.dart';
import '../models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getNews({int page = 1});
  Future<NewsModel> getNewsById(String id);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final DioClient dioClient;

  NewsRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<NewsModel>> getNews({int page = 1}) async {
    try {
      final response = await dioClient.dio.get(
        ApiConfig.newsEndpoint,
        queryParameters: {
          'api_token': ApiConfig.apiKey,
          'language': 'en',
          'limit': 3,
          'page': page,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        return jsonList.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }

  @override
  Future<NewsModel> getNewsById(String id) async {
    try {
      final response = await dioClient.dio.get(
        '${ApiConfig.newsEndpoint}/$id',
        queryParameters: {
          'api_token': ApiConfig.apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        return NewsModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch news by id: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch news by id: $e');
    }
  }
} 