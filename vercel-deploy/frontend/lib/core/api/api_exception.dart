class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final data = error.response.data;
      final statusCode = error.response.statusCode;

      // Handle validation errors (422)
      if (statusCode == 422 && data is Map<String, dynamic>) {
        return ApiException(
          message: data['message'] ?? 'Validation failed',
          statusCode: statusCode,
          errors: data['errors'] != null
              ? Map<String, dynamic>.from(data['errors'])
              : null,
        );
      }

      // Handle unauthorized (401)
      if (statusCode == 401) {
        return ApiException(
          message: 'Session expired. Please login again.',
          statusCode: statusCode,
        );
      }

      // Handle server error (500)
      if (statusCode == 500) {
        return ApiException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      }

      // Generic error
      return ApiException(
        message: data['message'] ?? 'Something went wrong',
        statusCode: statusCode,
      );
    }

    // Network error
    return ApiException(message: 'No internet connection');
  }

  @override
  String toString() => message;
}
