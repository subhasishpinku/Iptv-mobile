import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iptvmobile/HomeScreen/movie_model.dart';
import 'package:iptvmobile/LiveTvScreen/models/channel_model.dart';
import 'package:iptvmobile/OtpScreen.dart/models/otp_models.dart';

class ApiService {
  static const String baseUrl = 'https://iptv.yogayog.net';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 60),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          LogInterceptor(responseBody: true, requestBody: true),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              // ✅ এখানে Token যোগ করুন - সব request এর জন্য
              print("Request: ${options.method} ${options.path}");
              print("Query Parameters: ${options.queryParameters}");

              // Get token from secure storage
              final token = await _storage.read(key: 'auth_token');
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
                print("✅ Token added to request: Bearer $token");
              } else {
                print("⚠️ No token found for request");
              }

              return handler.next(options);
            },
            onError: (error, handler) async {
              print("Dio Error: ${error.message}");
              print("Dio Error Type: ${error.type}");
              if (error.response != null) {
                print("Response: ${error.response?.data}");
                print("Status Code: ${error.response?.statusCode}");

                // If 401 Unauthorized, clear token and redirect to login
                if (error.response?.statusCode == 401) {
                  await _storage.delete(key: 'auth_token');
                  await _storage.delete(key: 'user_data');
                  // You can emit an event to navigate to login screen
                }
              }
              return handler.next(error);
            },
          ),
        );

  Future<OtpResponse> sendOtp(OtpRequest request) async {
    try {
      final response = await _dio.post(
        '/api/sendOtp',
        queryParameters: request.toJson(),
      );

      print("Send OTP Response: ${response.data}");

      if (response.statusCode == 200) {
        return OtpResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        throw Exception('Server error: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _dio.post(
        '/api/verifyOtp',
        data: request.toJson(), //  correct
      );

      print("Verify OTP Response: ${response.data}");

      if (response.statusCode == 200) {
        return VerifyOtpResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to verify OTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        throw Exception('Server error: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> logout(String deviceId, String token) async {
    try {
      final response = await _dio.post(
        '/api/logout',
        queryParameters: {'device_id': deviceId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print("Logout Response: ${response.data}");
      print("Logout Status Code: ${response.statusCode}");
      return response.data;
    } on DioException catch (e) {
      print("Logout Error: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Status Code: ${e.response?.statusCode}");
        throw Exception('Logout failed: ${e.response?.data}');
      }
      throw Exception('Logout failed: ${e.message}');
    }
  }

  Future<List<Movie>> getMovies() async {
    try {
      final response = await _dio.get('/api/movies/home');

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load movies");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Channel>> getChannels() async {
    try {
      final response = await _dio.get('/api/getChannels');

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Channel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load channels");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
