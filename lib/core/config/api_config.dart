class ApiConfig {
  static const String baseUrl = 'https://api.thenewsapi.com/v1';
  static const String apiKey = 'yt16iW2mNCX2DV78KYOR6wgsel8dZLBE7bi3Aat4';
  
  // Endpoints
  static const String newsEndpoint = '/news/all';
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Query Parameters
  static Map<String, dynamic> get defaultQueryParams => {
    'api_token': apiKey,
    'language': 'en',

  };
}
