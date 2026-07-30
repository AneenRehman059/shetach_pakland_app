class ViewBillReceiptRequest {
  final String brnCode;
  final String registrationNo;
  final String idNo;
  final int reportId;
  final String userName;
  final String billNo;
  final String receiptNo; // ✅ added
  final bool isStatement;

  ViewBillReceiptRequest({
    required this.brnCode,
    required this.registrationNo,
    required this.idNo,
    this.reportId = 512162,
    required this.userName,
    required this.billNo,
    required this.receiptNo, // ✅ added
    this.isStatement = false,
  });

  Map<String, dynamic> toJson() => {
    "brn_code": brnCode,
    "registration_no": registrationNo,
    "id_no": idNo,
    "ReportId": reportId,
    "UserName": userName,
    "bill_no": billNo,
    "receipt_no": receiptNo, // ✅ added
    "isstatement": isStatement,
  };
}


class ViewBillReceiptResponse {
  final bool success;
  final String reportUrl;

  ViewBillReceiptResponse({
    required this.success,
    required this.reportUrl,
  });

  factory ViewBillReceiptResponse.fromJson(Map<String, dynamic> json) {
    return ViewBillReceiptResponse(
      success: json['success'] ?? false,
      reportUrl: json['reportUrl'] ?? '',
    );
  }
}
