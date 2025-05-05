import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/news.dart';
import 'package:hive/hive.dart';

part 'news_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class NewsModel extends News {
  @HiveField(0)
  @JsonKey(name: 'uuid')
  final String id;
  @HiveField(1)
  @JsonKey(name: 'title')
  final String title;
  @HiveField(2)
  @JsonKey(name: 'description')
  final String description;
  @HiveField(3)
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @HiveField(4)
  @JsonKey(name: 'source')
  final String source;
  @HiveField(5)
  @JsonKey(name: 'published_at')
  final DateTime publishedAt;
  @HiveField(6)
  @JsonKey(name: 'url')
  final String url;

  const NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.url,
  }) : super(
          id: id,
          title: title,
          description: description,
          imageUrl: imageUrl,
          source: source,
          publishedAt: publishedAt,
          url: url,
        );

  factory NewsModel.fromJson(Map<String, dynamic> json) =>
      _$NewsModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        source,
        publishedAt,
        url,
      ];
} 