class OtpRequest {
  final String mobile;
  final String deviceId;
  final String deviceName;

  OtpRequest({
    required this.mobile,
    required this.deviceId,
    required this.deviceName,
  });

  Map<String, dynamic> toJson() => {
    'mobile': mobile,
    'device_id': deviceId,
    'device_name': deviceName,
  };
}

class OtpResponse {
  final bool status;
  final bool notRegistered;
  final String message;
  final int otp;

  OtpResponse({
    required this.status,
    required this.notRegistered,
    required this.message,
    required this.otp,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) => OtpResponse(
    status: json['status'],
    notRegistered: json['notRegistered'] ?? false,
    message: json['message'],
    otp: json['otp'],
  );
}

class VerifyOtpRequest {
  final String mobile;
  final String otp;
  final String deviceId;
  final String deviceName;

  VerifyOtpRequest({
    required this.mobile,
    required this.otp,
    required this.deviceId,
    required this.deviceName,
  });

  Map<String, dynamic> toJson() => {
    'mobile': mobile,
    'otp': otp,
    'device_id': deviceId,
    'device_name': deviceName,
  };
}

class VerifyOtpResponse {
  final bool status;
  final String message;
  final String? token;
  final String? tokenType;
  final User? user;

  VerifyOtpResponse({
    required this.status,
    required this.message,
    this.token,
    this.tokenType,
    this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
    status: json['status'],
    message: json['message'],
    token: json['token'],
    tokenType: json['token_type'],
    user: json['user'] != null ? User.fromJson(json['user']) : null,
  );
}

class User {
  final int id;
  final String? name;
  final String mobile;
  final String? email; // ✅ FIX

  User({
    required this.id,
    this.name,
    required this.mobile,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    mobile: json['mobile'],
    email: json['email'], // now safe
  );
}