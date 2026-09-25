class LoginRequestModel {
  final String username;
  final String password;
  final String latitude;
  final String longitude;
  final String deviceId;

  LoginRequestModel({
    required this.username,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.deviceId,

  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "latitude": latitude,
      "longitude": longitude,
      "deviceId": deviceId
    };
  }
}
