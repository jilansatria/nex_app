import 'package:dio/dio.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio _dio;

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            // Token expired or invalid — clear stored token
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('access_token');
            print('⚠️ Token expired or invalid. Please login again.');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<bool> checkConnection() async {
    try {
      // Trying to hit the root endpoint
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        print('✅ Backend Connected: ${response.data}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Backend Connection Failed: $e');
      return false;
    }
  }
}
