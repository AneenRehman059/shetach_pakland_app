class AccountStatementRequest {
  final String brnCode;
  final String registrationNo;
  final String idNo;
  final int reportId;
  final String userName;
  final bool isStatement;
  final String receiptNo;
  final List<String> copies;

  AccountStatementRequest({
    required this.brnCode,
    required this.registrationNo,
    required this.idNo,
    required this.reportId,
    required this.userName,
    this.isStatement = false,
    required this.receiptNo,
    required this.copies,
  });

  Map<String, dynamic> toJson() => {
    "brn_code": brnCode,
    "registration_no": registrationNo,
    "id_no": idNo,
    "ReportId": reportId,
    "UserName": userName,
    "isstatement": isStatement,
    "receipt_no": receiptNo,
    "copies": copies,
  };
}

class AccountStatementResponse {
  final bool success;
  final String reportUrl;

  AccountStatementResponse({
    required this.success,
    required this.reportUrl,
  });

  factory AccountStatementResponse.fromJson(Map<String, dynamic> json) {
    return AccountStatementResponse(
      success: json['success'] ?? false,
      reportUrl: json['reportUrl'] ?? '',
    );
  }
}