class SOSNotificationRequest {
  final String ticketId;
  final String userName;
  final String userId;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final String timestamp;
  final String message;
  final String emergencyType;
  final String department;
  final String brnCode;

  SOSNotificationRequest({
    required this.ticketId,
    required this.userName,
    required this.userId,
    required this.phoneNumber,
    this.latitude,
    this.longitude,
    required this.timestamp,
    required this.message,
    required this.emergencyType,
    required this.department,
    required this.brnCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'TicketId': ticketId,
      'UserName': userName,
      'UserId': userId,
      'PhoneNumber': phoneNumber,
      'Latitude': latitude,
      'Longitude': longitude,
      'Timestamp': timestamp,
      'Message': message,
      'EmergencyType': emergencyType,
      'Department': department,
      'brn_code': brnCode,
    };
  }
}

class HelpOnTheWayRequest {
  final String ticketId;
  final String userId;
  final String message;
  final String timestamp;

  HelpOnTheWayRequest({
    required this.ticketId,
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'TicketId': ticketId,
      'UserId': userId,
      'Message': message,
      'Timestamp': timestamp,
    };
  }
}

class FCMTokenUpdateRequest {
  final String userId;
  final String fcmToken;

  FCMTokenUpdateRequest({required this.userId, required this.fcmToken});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fcmToken': fcmToken,
    };
  }
}
class AdminUser {
  final String userId;
  final String userName;
  final String fcmToken;
  final String userType;
  final String department;
  final String email;
  final String mobileNumber;
  final String userCategory;
  final String departmentId;

  AdminUser({
    required this.userId,
    required this.userName,
    required this.fcmToken,
    required this.userType,
    required this.department,
    required this.email,
    required this.mobileNumber,
    required this.userCategory,
    required this.departmentId,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userId: json['UserId'] ?? '',
      userName: json['UserName'] ?? '',
      fcmToken: json['FCMToken'] ?? '',
      userType: json['UserType'] ?? '',
      department: json['Department'] ?? '',
      email: json['Email'] ?? '',
      mobileNumber: json['MobileNumber'] ?? '',
      userCategory: json['UserCategory'] ?? '',
      departmentId: json['DepartmentId'] ?? '',
    );
  }
}

class SOSNotificationResponse {
  final List<AdminUser> allSOSUsers;
  final int totalUsers;
  final String message;

  SOSNotificationResponse({
    required this.allSOSUsers,
    required this.totalUsers,
    required this.message,
  });

  factory SOSNotificationResponse.fromJson(Map<String, dynamic> json) {
    var usersList = json['AllSOSUsers'] as List? ?? [];
    return SOSNotificationResponse(
      allSOSUsers: usersList.map((user) => AdminUser.fromJson(user)).toList(),
      totalUsers: json['TotalUsers'] ?? 0,
      message: json['Message'] ?? '',
    );
  }
}

class SOSPermissionResponse {
  final bool canReceiveSOS;
  final String userType;
  final bool isInSOSDepartment;
  final String message;

  SOSPermissionResponse({
    required this.canReceiveSOS,
    required this.userType,
    required this.isInSOSDepartment,
    required this.message,
  });

  factory SOSPermissionResponse.fromJson(Map<String, dynamic> json) {
    return SOSPermissionResponse(
      canReceiveSOS: json['CanReceiveSOS'] ?? false,
      userType: json['UserType'] ?? '',
      isInSOSDepartment: json['IsInSOSDepartment'] ?? false,
      message: json['Message'] ?? '',
    );
  }
}

class SOSTicketDTO {
  String ticketId;
  String title;
  String description;
  String status;
  String ticketPriority;
  DateTime createdAt;
  String reportedByUserId;
  String reportedByUserName;
  String reportedByMobile;
  double? latitude;
  double? longitude;
  String emergencyType;

  SOSTicketDTO({
    required this.ticketId,
    required this.title,
    required this.description,
    required this.status,
    required this.ticketPriority,
    required this.createdAt,
    required this.reportedByUserId,
    required this.reportedByUserName,
    required this.reportedByMobile,
    this.latitude,
    this.longitude,
    required this.emergencyType,
  });

  factory SOSTicketDTO.fromJson(Map<String, dynamic> json) {
    return SOSTicketDTO(
      ticketId: json['TicketId'] ?? '',
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      status: json['Status'] ?? '',
      ticketPriority: json['TicketPriority'] ?? '',
      createdAt: DateTime.parse(json['CreatedAt'] ?? DateTime.now().toString()),
      reportedByUserId: json['ReportedByUserId'] ?? '',
      reportedByUserName: json['ReportedByUserName'] ?? '',
      reportedByMobile: json['ReportedByMobile'] ?? '',
      latitude: json['Latitude'] != null ? double.parse(json['Latitude'].toString()) : null,
      longitude: json['Longitude'] != null ? double.parse(json['Longitude'].toString()) : null,
      emergencyType: json['EmergencyType'] ?? '',
    );
  }
}

class ApiResponse<T> {
  final String statusCode;
  final String message;
  final T? obj;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.obj,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse(
      statusCode: json['StatusCode'] ?? '',
      message: json['Message'] ?? '',
      obj: fromJson != null && json['obj'] != null ? fromJson(json['obj']) : null,
    );
  }

  bool get isSuccess => statusCode == '200';
}

class StopSOSAlarmResponse {
  final String ticketId;
  final String status;
  final String message;

  StopSOSAlarmResponse({
    required this.ticketId,
    required this.status,
    required this.message,
  });

  factory StopSOSAlarmResponse.fromJson(Map<String, dynamic> json) {
    final data = json['obj'] ?? json;

    return StopSOSAlarmResponse(
      ticketId: data['TicketId'] ?? data['ticketId'] ?? '',
      status: data['Status'] ?? data['status'] ?? '',
      message: data['Message'] ?? data['message'] ?? '',
    );
  }
}

class RespondToSOSRequest {
  final String ticketId;
  final String responderUserId;
  final String responderName;
  final String? remarks;

  RespondToSOSRequest({
    required this.ticketId,
    required this.responderUserId,
    required this.responderName,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'TicketId': ticketId,
      'ResponderUserId': responderUserId,
      'ResponderName': responderName,
      'Remarks': remarks,
    };
  }
}

class RespondToSOSResponse {
  final String ticketId;
  final String status;
  final String message;
  final String userFCMToken;
  final String userName;
  final String userMobile;

  RespondToSOSResponse({
    required this.ticketId,
    required this.status,
    required this.message,
    required this.userFCMToken,
    required this.userName,
    required this.userMobile,
  });

  factory RespondToSOSResponse.fromJson(Map<String, dynamic> json) {
    final data = json['obj'] ?? json;
    return RespondToSOSResponse(
      ticketId: data['TicketId'] ?? data['ticketId'] ?? '',
      status: data['Status'] ?? data['status'] ?? '',
      message: data['Message'] ?? data['message'] ?? '',
      userFCMToken: data['UserFCMToken'] ?? data['userFCMToken'] ?? '',
      userName: data['UserName'] ?? data['userName'] ?? '',
      userMobile: data['UserMobile'] ?? data['userMobile'] ?? '',
    );
  }
}