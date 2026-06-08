class ApiConstants {
  static const String baseUrl = 'http://localhost:5000/api/';
  
  // Auth Endpoints
  static const String login = 'auth/login';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const String register = 'auth/register';
  static const String profile = 'auth/profile';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  
  // Complaints Endpoints
  static const String complaints = 'complaints';
  static const String myComplaints = 'complaints/my';
  static const String nearbyComplaints = 'complaints/nearby';
  static const String verifyComplaint = 'complaints/{id}/verify';
  static const String reopenComplaint = 'complaints/{id}/reopen';
}
