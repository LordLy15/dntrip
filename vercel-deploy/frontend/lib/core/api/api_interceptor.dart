import 'package:dio/dio.dart';
import '../storage/hive_storage.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final HiveStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip token injection for public auth endpoints
    final publicEndpoints = [
      AppConstants.baseUrl + '/register',
      AppConstants.baseUrl + '/login',
    ];

    if (publicEndpoints.contains(options.uri.toString())) {
      return handler.next(options);
    }

    final token = _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid - clear storage
      _storage.clearAll();
    }
    return handler.next(err);
  }
}
