import '../config/api_endpoints.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Login with email and password
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<LoginResponse>(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      includeAuth: false,
      fromJson: (json) => LoginResponse.fromJson(json),
    );

    // Save token if login successful
    if (response.success && response.data?.accessToken != null) {
      _apiClient.setAuthToken(response.data!.accessToken);
    }

    return response;
  }

  /// Sign up with new account
  Future<ApiResponse<AuthResponse>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    return await _apiClient.post<AuthResponse>(
      ApiEndpoints.signup,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone': phone,
      },
      includeAuth: false,
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  /// Send OTP to email
  Future<ApiResponse<void>> sendOtp({required String email}) {
    return _apiClient.post<void>(
      ApiEndpoints.verifyOtp,
      body: {'email': email},
      includeAuth: false,
    );
  }

  /// Verify OTP
  Future<ApiResponse<AuthResponse>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _apiClient.post<AuthResponse>(
      ApiEndpoints.verifyOtp,
      body: {'email': email, 'otp': otp},
      includeAuth: false,
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  /// Reset password
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _apiClient.post<void>(
      ApiEndpoints.passwordReset,
      body: {
        'email': email,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      includeAuth: false,
    );
  }

  /// Logout (clears token)
  Future<ApiResponse<void>> logout() async {
    final response = await _apiClient.post<void>(ApiEndpoints.logout);

    _apiClient.clearAuthToken();
    return response;
  }

  /// Refresh authentication token
  Future<ApiResponse<LoginResponse>> refreshToken() {
    return _apiClient.post<LoginResponse>(
      ApiEndpoints.refreshToken,
      includeAuth: true,
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }
}

class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final UserData user;
  final int expiresIn;

  LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
      expiresIn: json['expires_in'] as int? ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_in': expiresIn,
    };
  }
}

class AuthResponse {
  final UserData user;
  final String? message;

  AuthResponse({required this.user, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'message': message};
  }
}

class UserData {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profileImage;
  final DateTime? createdAt;

  UserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profileImage,
    this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}
