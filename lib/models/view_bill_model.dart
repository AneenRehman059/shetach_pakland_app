
class ViewBillRequest {
  final String brnCode;
  final String registrationNo;
  final String idNo;
  final int reportId;
  final String userName;
  final String billNo;
  final bool isStatement;

  ViewBillRequest({
    required this.brnCode,
    required this.registrationNo,
    required this.idNo,
    this.reportId = 512719,
    required this.userName,
    required this.billNo,
    this.isStatement = false,
  });

  Map<String, dynamic> toJson() => {
    "brn_code": brnCode,
    "registration_no": registrationNo,
    "id_no": idNo,
    "ReportId": reportId,
    "UserName": userName,
    "bill_no": billNo,
    "isstatement": isStatement,
  };
}

class ViewBillResponse {
  final bool success;
  final String reportUrl;

  ViewBillResponse({
    required this.success,
    required this.reportUrl,
  });

  factory ViewBillResponse.fromJson(Map<String, dynamic> json) {
    return ViewBillResponse(
      success: json['success'] ?? false,
      reportUrl: json['reportUrl'] ?? '',
    );
  }
}