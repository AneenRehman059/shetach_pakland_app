class TimeLineModel {
  final int id;
  final String module;
  final String moduleItemId;
  final String action;
  final String description;
  final DateTime createdAt;
  final String username;
  final String role;
  final String phoneNo;
  final String? newstatus;
  final String? newpriority;

  TimeLineModel({
    required this.id,
    required this.module,
    required this.moduleItemId,
    required this.action,
    required this.description,
    required this.createdAt,
    required this.username,
    required this.role,
    required this.phoneNo,
    this.newstatus,
    this.newpriority,
  });

  factory TimeLineModel.fromJson(Map<String, dynamic> json) {
    return TimeLineModel(
      id: _safeInt(json['Id'] ?? json['id']) ?? 0,
      module: json['Module'] ?? json['module'] ?? '',
      moduleItemId: (json['ModuleItemID'] ?? json['moduleItemID'] ?? '').toString(),
      action: json['Action'] ?? json['action'] ?? '',
      description: json['Description'] ?? json['description'] ?? '',
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      username: json['Username'] ?? '',
      role: json['Role'] ?? '',
      phoneNo: json['PhoneNo'] ?? '',
      newstatus: json['NewStatus']?.toString(),
      newpriority: json['NewPriority']?.toString(),
    );
  }

  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Module': module,
      'ModuleItemID': moduleItemId,
      'Action': action,
      'Description': description,
      'CreatedAt': createdAt.toIso8601String(),
      'username': username,
      'role': role,
      'phoneNo': phoneNo,
      'NewStatus': newstatus,
      'NewPriority': newpriority,
    };
  }

  @override
  String toString() {
    return 'TimeLineModel(id: $id, module: $module, moduleItemId: $moduleItemId, '
        'action: $action, description: $description, createdAt: $createdAt, '
        'username: $username, role: $role, phoneNo: $phoneNo, '
        'newstatus: $newstatus, newpriority: $newpriority)';
  }
}
