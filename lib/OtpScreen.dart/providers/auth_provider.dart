import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iptvmobile/services/device_service.dart';
import '../models/otp_models.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());
final deviceServiceProvider = Provider((ref) => DeviceService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final deviceService = ref.read(deviceServiceProvider);
  return AuthNotifier(authRepository, deviceService);
});

class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;
  final bool isAuthenticated;
  final String? otpSentMessage;
  final int? lastSentOtp; // For debugging

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
    this.otpSentMessage,
    this.lastSentOtp,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    bool? isAuthenticated,
    String? otpSentMessage,
    int? lastSentOtp,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      otpSentMessage: otpSentMessage ?? this.otpSentMessage,
      lastSentOtp: lastSentOtp ?? this.lastSentOtp,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final DeviceService _deviceService;

  AuthNotifier(this._authRepository, this._deviceService) : super(AuthState());

  Future<void> sendOtp(String mobile) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final deviceId = await _deviceService.getDeviceId();
      final deviceName = await _deviceService.getDeviceName();
      
      print("Sending OTP with - DeviceID: $deviceId, DeviceName: $deviceName, Mobile: $mobile");

      final request = OtpRequest(
        mobile: mobile,
        deviceId: deviceId,
        deviceName: deviceName,
      );

      final response = await _authRepository.sendOtp(request);
      
      print("OTP Response: ${response.status}, OTP: ${response.otp}");
      
      if (response.status) {
        state = state.copyWith(
          isLoading: false,
          otpSentMessage: response.message,
          lastSentOtp: response.otp, // Store for debugging
          // error: response.notRegistered ? 'User not registered' : null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      print("Send OTP Error: $e");
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

Future<bool> verifyOtp(String mobile, String otp) async {
  if (mobile.isEmpty) {
    state = state.copyWith(
      isLoading: false,
      error: "Mobile number is required",
    );
    return false;
  }
  
  state = state.copyWith(isLoading: true, error: null);
  
  try {
    final deviceId = await _deviceService.getDeviceId();
    final deviceName = await _deviceService.getDeviceName();

    print("Verifying OTP - Mobile: $mobile, OTP: $otp, DeviceID: $deviceId");

    final request = VerifyOtpRequest(
      mobile: mobile, // ✅ mobile properly passed
      otp: otp,
      deviceId: deviceId,
      deviceName: deviceName,
    );

    final response = await _authRepository.verifyOtp(request);
    
    print("Verify Response: ${response.status}, Token: ${response.token}");
    
    if (response.status && response.token != null) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
        error: null,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
      return false;
    }
  } catch (e) {
    print("Verify OTP Error: $e");
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
    return false;
  }
}

  Future<bool> checkAuthStatus() async {
  final isLoggedIn = await _authRepository.isLoggedIn();
  if (isLoggedIn) {
    final user = await _authRepository.getUser();
    state = state.copyWith(isAuthenticated: true, user: user);
    return true;
  }
  return false;
}

Future<void> logout() async {
  print("Starting logout process...");
  
  try {
    final deviceId = await _deviceService.getDeviceId();
    final token = await _authRepository.getToken();
    
    print("Logout - DeviceID: $deviceId");
    print("Logout - Token exists: ${token != null}");
    
    if (token != null) {
      await _authRepository.logout(deviceId);
      print("Logout API call completed");
    } else {
      print("No token found, skipping API call");
    }
  } catch (e) {
    print("Logout error: $e");
  } finally {
    // Clear state immediately
    state = AuthState();
    print("Logout completed, state cleared");
  }
}

  void clearError() {
    state = state.copyWith(error: null);
  }
}