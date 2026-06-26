import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator alias for localhost
  final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  ApiService() : dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      }
    ));
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }
}
