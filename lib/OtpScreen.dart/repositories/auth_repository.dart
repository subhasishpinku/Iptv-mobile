import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iptvmobile/services/api_service.dart';
import '../models/otp_models.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<OtpResponse> sendOtp(OtpRequest request) async {
    return await _apiService.sendOtp(request);
  }

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    final response = await _apiService.verifyOtp(request);
    
    if (response.status && response.token != null) {
      await _saveAuthData(response.token!, response.user);
    }
    
    return response;
  }

 Future<void> logout(String deviceId) async {
  try {
    final token = await getToken();
    print("Logout Repository - DeviceID: $deviceId");
    print("Logout Repository - Token: ${token != null ? "Exists" : "Missing"}");
    
    if (token != null) {
      await _apiService.logout(deviceId, token);
      print("Logout API success");
    }
  } catch (e) {
    print("Logout API error: $e");
  } finally {
    // Always clear local storage
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    print("Local storage cleared");
  }
}
  Future<void> _saveAuthData(String token, User? user) async {
    await _storage.write(key: _tokenKey, value: token);
    if (user != null) {
      await _storage.write(key: _userKey, value: userToJson(user));
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return userFromJson(userJson);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

 String userToJson(User user) {
  return '${user.id}|${user.name ?? ""}|${user.mobile}|${user.email ?? ""}';
}

User userFromJson(String json) {
  final parts = json.split('|');
  return User(
    id: int.parse(parts[0]),
    name: parts[1].isEmpty ? null : parts[1],
    mobile: parts[2],
    email: parts[3].isEmpty ? null : parts[3], // ✅ FIX
  );
}
}