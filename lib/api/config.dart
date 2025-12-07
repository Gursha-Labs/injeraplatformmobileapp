class ApiConfig {
  static const String baseUrl = 'http://192.168.137.1:8000/api';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
