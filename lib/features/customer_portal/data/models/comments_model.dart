class CommentsModel {
  CommentsModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.text,
    this.mediaPath,
    this.mediaId,
    required this.commentType,
    required this.createdAt,
    this.username,
  });

  final int id;
  final String ticketId;
  final String userId;
  final String text;
  final String? mediaPath;
  final int? mediaId;
  final String commentType;
  final DateTime createdAt;
  final String? username;

  /// Convert JSON to model
  factory CommentsModel.fromJson(Map<String, dynamic> json) {
    return CommentsModel(
      id: json['Id'] ?? json['id'] ?? 0,
      ticketId: json['TicketId'] ?? json['ticketId'] ?? '',
      userId: json['UserId'] ?? json['userId'] ?? '',
      text: json['Text'] ?? json['text'] ?? '',
      mediaPath: json['MediaPath'] ?? json['mediaPath'],
      mediaId: json['MediaId'] ?? json['mediaId'],
      commentType: json['CommentType'] ?? json['commentType'] ?? '',
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'].toString())
          : DateTime.now(),
      username: json['Username'] ?? json['username'],
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'TicketId': ticketId,
      'UserId': userId,
      'Text': text,
      'MediaPath': mediaPath,
      'MediaId': mediaId,
      'CommentType': commentType,
      'CreatedAt': createdAt.toIso8601String(),
      'Username': username,
    };
  }

  /// Create a request payload for adding a comment
  static Map<String, dynamic> createRequest({
    required String ticketId,
    required String userId,
    required String text,
    int? mediaId,
    required String commentType,
  }) {
    return {
      'TicketId': ticketId,
      'UserId': userId,
      'Text': text,
      // Send null if no media to avoid FK error
      'MediaId': (mediaId == null || mediaId == 0) ? null : mediaId,
      'CommentType': commentType,
    };
  }
}
