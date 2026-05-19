class TicketModel {
  final String brn_code;
  final String id;
  final String title;
  final String description;
  final String ticketPriority;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final List<String>? attachmentPath;
  final List<String>? commentAttachmentPath;
  final String userId;
  final double? latitude;
  final double? longitude;
  final String? userName;
  final String? purposeName;
  final String? OprationID;
  final String? AssignedToUserId;

  TicketModel({
    required this.brn_code,
    required this.id,
    required this.title,
    required this.description,
    required this.ticketPriority,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.attachmentPath,
    this.commentAttachmentPath,
    required this.userId,
    this.latitude,
    this.longitude,
    this.userName,
    this.purposeName,
    this.OprationID,
    this.AssignedToUserId,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      // brn_code: json['brn_code'],
      brn_code: (json['brn_code'] == null || json['brn_code'] == '')
          ? '00000'
          : json['brn_code'],
      id: json['Id'],
      title: json['Title'],
      description: json['Description'],
      ticketPriority: json['TicketPriority'],
      status: json['Status'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt:
      json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      dueDate:
      json['DueDate'] != null ? DateTime.parse(json['DueDate']) : null,
      attachmentPath:
      (json['AttachmentPath'] as List?)?.map((e) => e.toString()).toList(),
      commentAttachmentPath:
      (json['CommentAttachmentPath'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      userId: json['UserId'],
      latitude: (json['Latitude'] as num?)?.toDouble(),
      longitude: (json['Longitude'] as num?)?.toDouble(),
      userName: json['UserName'],
      purposeName: json['purposeName'],
      OprationID: json['OprationID'],
      AssignedToUserId: json['AssignedToUserId'],

    );

  }
}


class CreateTicketRequest {
  final String brn_code;
  final String title;
  final String oprationID;
  final String description;
  final String ticketPriority;
  final DateTime? dueDate;
  final String? attachmentPath; // MUST be string
  final String userId;
  final double? latitude;
  final double? longitude;


  CreateTicketRequest({
    required this.brn_code,
    required this.title,
    required this.oprationID,
    required this.description,
    required this.ticketPriority,
    required this.userId,
    this.dueDate,
    this.attachmentPath,
    this.latitude,
    this.longitude,

  });

  Map<String, dynamic> toJson() => {
    'brn_code': brn_code,
    'Title': title,
    'OprationID': oprationID,
    'Description': description,
    'TicketPriority': ticketPriority,
    'DueDate': dueDate?.toIso8601String(),
    'AttachmentPath': attachmentPath,
    'UserId': userId,
    'Latitude': latitude,
    'Longitude': longitude,

  };
}


class UpdateTicketRequest {
  final String id;
  final String title;
  final String description;
  final String OprationID;
  final String? attachmentPath;
  final DateTime? dueDate;
  final double? latitude;
  final double? longitude;
  final String userId;

  UpdateTicketRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.OprationID,
    this.dueDate,
    this.latitude,
    this.longitude,
    required this.userId,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Title': title,
    'Description': description,
    'OprationID': OprationID,
    'DueDate': dueDate?.toIso8601String(),
    'Latitude': latitude,
    'Longitude': longitude,
    'AttachmentPath': attachmentPath,
    'UserId': userId,
  };
}

class UpdateStatusPriorityRequest {
  final String id;
  final String userId;
  final String status;
  final String priority;

  UpdateStatusPriorityRequest({
    required this.id,
    required this.userId,
    required this.status,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'Status': status,
    'Priority': priority,
  };
}

class TicketCommentDTO {
  final String id;
  final int ticketId;
  final String userId;
  final String? text;
  final int? mediaId;
  final String commentType;
  final DateTime createdAt;
  final String? username;
  final String? mediaPath;

  TicketCommentDTO({
    required this.id,
    required this.ticketId,
    required this.userId,
    this.text,
    this.mediaId,
    required this.commentType,
    required this.createdAt,
    this.username,
    this.mediaPath,
  });

  factory TicketCommentDTO.fromJson(Map<String, dynamic> json) => TicketCommentDTO(
    id: json['Id'] ?? json['id'] ?? '',
    ticketId: json['TicketId'] ?? json['ticketId'] ?? 0,
    userId: json['UserId'] ?? json['userId'] ?? '',
    text: json['Text'] ?? json['text'],
    mediaId: json['MediaId'] ?? json['mediaId'],
    commentType: json['CommentType'] ?? json['commentType'] ?? 'Text',
    createdAt: json['CreatedAt'] != null
        ? DateTime.parse(json['CreatedAt'].toString())
        : (json['createdAt'] != null
        ? DateTime.parse(json['createdAt'].toString())
        : DateTime.now()),
    username: json['Username'] ?? json['username'],
    mediaPath: json['MediaPath'] ?? json['mediaPath'],
  );

  Map<String, dynamic> toJson() => {
    'TicketId': ticketId,
    'UserId': userId,
    'Text': text,
    'MediaId': mediaId,
    'CommentType': commentType,
  };
}

class UploadMediaDTO {
  final String filePath;
  final String fileType;
  final String userId;
  final String originalFileName;
  final DateTime uploadedAt;

  UploadMediaDTO({
    required this.filePath,
    required this.fileType,
    required this.userId,
    required this.originalFileName,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
    'FilePath': filePath,
    'FileType': fileType,
    'UserId': userId,
    'OriginalFileName': originalFileName,
    'UploadedAt': uploadedAt.toIso8601String(),
  };
}

class MediaDTO {
  final String id;
  final String userId;
  final String fileType;
  final String filePath;
  final String originalFileName;
  final DateTime uploadedAt;

  MediaDTO({
    required this.id,
    required this.userId,
    required this.fileType,
    required this.filePath,
    required this.originalFileName,
    required this.uploadedAt,
  });

  factory MediaDTO.fromJson(Map<String, dynamic> json) => MediaDTO(
    id: json['Id'] ?? json['id'] ?? '',
    userId: json['UserId'] ?? json['userId'] ?? '',
    fileType: json['FileType'] ?? json['fileType'] ?? '',
    filePath: json['FilePath'] ?? json['filePath'] ?? '',
    originalFileName: json['OriginalFileName'] ?? json['originalFileName'] ?? '',
    uploadedAt: json['UploadedAt'] != null
        ? DateTime.parse(json['UploadedAt'].toString())
        : (json['uploadedAt'] != null
        ? DateTime.parse(json['uploadedAt'].toString())
        : DateTime.now()),
  );
}

class AuditLogDTO {
  final String userId;
  final String module;
  final int moduleItemID;
  final String action;
  final String? description;
  final String? ipAddress;
  final String? device;

  AuditLogDTO({
    required this.userId,
    required this.module,
    required this.moduleItemID,
    required this.action,
    this.description,
    this.ipAddress,
    this.device,
  });

  Map<String, dynamic> toJson() => {
    'UserId': userId,
    'Module': module,
    'ModuleItemID': moduleItemID,
    'Action': action,
    'Description': description,
    'IPAddress': ipAddress,
    'Device': device,
  };
}

class AuditLogGETDTO {
  final int id;
  final String module;
  final int moduleItemID;
  final String action;
  final String? description;
  final DateTime createdAt;
  final String? username;
  final String? role;
  final String? phoneNo;

  AuditLogGETDTO({
    required this.id,
    required this.module,
    required this.moduleItemID,
    required this.action,
    this.description,
    required this.createdAt,
    this.username,
    this.role,
    this.phoneNo,
  });

  factory AuditLogGETDTO.fromJson(Map<String, dynamic> json) => AuditLogGETDTO(
    id: json['Id'] ?? json['id'] ?? 0,
    module: json['Module'] ?? json['module'] ?? '',
    moduleItemID: json['ModuleItemID'] ?? json['moduleItemID'] ?? 0,
    action: json['Action'] ?? json['action'] ?? '',
    description: json['Description'] ?? json['description'],
    createdAt: json['CreatedAt'] != null
        ? DateTime.parse(json['CreatedAt'].toString())
        : (json['createdAt'] != null
        ? DateTime.parse(json['createdAt'].toString())
        : DateTime.now()),
    username: json['Username'] ?? json['username'],
    role: json['Role'] ?? json['role'],
    phoneNo: json['PhoneNo'] ?? json['phoneNo'],
  );
}

// ===== TICKET ASSIGNMENT MODELS =====

class AssignTicketRequest {
  final String brn_code;
  final String ticketId;
  final String departmentId;
  final String? category;
  final String assignedToUserId;
  final String assignedByUserId;
  final DateTime? dueDate;
  final String? remarks;

  AssignTicketRequest({
    required this.brn_code,
    required this.ticketId,
    required this.departmentId,
    this.category,
    required this.assignedToUserId,
    required this.assignedByUserId,
    this.dueDate,
    this.remarks,
  });

  Map<String, dynamic> toJson() => {
    'brn_code': brn_code,
    'TicketId': ticketId,
    'DepartmentId': departmentId,
    'Category': category,
    'AssignedToUserId': assignedToUserId,
    'AssignedByUserId': assignedByUserId,
    'DueDate': dueDate?.toIso8601String(),
    'Remarks': remarks,
  };
}

class AssignTicketResponse {
  final String ticketId;
  final String assignedToUserId;
  final String status;
  final DateTime assignedAt;

  AssignTicketResponse({
    required this.ticketId,
    required this.assignedToUserId,
    required this.status,
    required this.assignedAt,
  });

  factory AssignTicketResponse.fromJson(Map<String, dynamic> json) => AssignTicketResponse(
    ticketId: json['TicketId'] ?? '',
    assignedToUserId: json['AssignedToUserId'] ?? '',
    status: json['Status'] ?? 'Assigned',
    assignedAt: DateTime.parse(json['AssignedAt']),
  );
}

class TicketAssignment {
  final String brn_code;
  final int assignmentId;
  final String ticketId;
  final String departmentId;
  final String? category;
  final String assignedToUserId;
  final String assignedByUserId;
  final DateTime assignedAt;
  final String status;
  final DateTime? dueDate;
  final String? remarks;
  final bool isActive;

  TicketAssignment({
    required this.brn_code,
    required this.assignmentId,
    required this.ticketId,
    required this.departmentId,
    this.category,
    required this.assignedToUserId,
    required this.assignedByUserId,
    required this.assignedAt,
    required this.status,
    this.dueDate,
    this.remarks,
    required this.isActive,
  });

  factory TicketAssignment.fromJson(Map<String, dynamic> json) => TicketAssignment(
    brn_code: json['brn_code'] ?? '',
    assignmentId: json['AssignmentId'] ?? 0,
    ticketId: json['TicketId'] ?? '',
    departmentId: json['DepartmentId'] ?? '',
    category: json['Category'],
    assignedToUserId: json['AssignedToUserId'] ?? '',
    assignedByUserId: json['AssignedByUserId'] ?? '',
    assignedAt: DateTime.parse(json['AssignedAt']),
    status: json['Status'] ?? 'Assigned',
    dueDate: json['DueDate'] != null ? DateTime.tryParse(json['DueDate'].toString()) : null,
    remarks: json['Remarks'],
    isActive: json['IsActive'] ?? true,
  );
}