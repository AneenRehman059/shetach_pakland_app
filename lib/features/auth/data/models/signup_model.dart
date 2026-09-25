class SignUpRequestModel {
  final String cnic;
  final String password;
  final String mobileNo;
  final String emailAddress;
  final String address;
  final String userName;
  final String otp;
  final String otpVia;
  final String deviceId;
  final String deviceModel;
  final String platform;
  final String osVersion;
  final String latitude;
  final String longitude;
  final String manufacturer;
  final String operatingSystem;
  final String webViewVersion;

  SignUpRequestModel({
    required this.cnic,
    required this.password,
    required this.mobileNo,
    required this.emailAddress,
    required this.address,
    required this.userName,
    required this.otp,
    required this.otpVia,
    required this.deviceId,
    required this.deviceModel,
    required this.platform,
    required this.osVersion,
    required this.latitude,
    required this.longitude,
    required this.manufacturer,
    required this.operatingSystem,
    required this.webViewVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      "cnic": cnic,
      "password": password,
      "mobile_no": mobileNo,
      "email_address": emailAddress,
      "address": address,
      "user_name": userName,
      "OTP": otp,
      "otp_via": otpVia,
      "deviceId": deviceId,
      "deviceModel": deviceModel,
      "platform": platform,
      "osVersion": osVersion,
      "latitude": latitude,
      "longitude": longitude,
      "manufacturer": manufacturer,
      "operatingSystem": operatingSystem,
      "webViewVersion": webViewVersion,
    };
  }
}
