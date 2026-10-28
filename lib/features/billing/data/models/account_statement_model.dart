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
  final String message;

  AccountStatementResponse({
    required this.success,
    required this.reportUrl,
    this.message = '',
  });

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      for (final entry in json.entries) {
        if (entry.key.toLowerCase() == key.toLowerCase() && entry.value != null) {
          return entry.value;
        }
      }
    }
    return null;
  }

  factory AccountStatementResponse.fromJson(Map<String, dynamic> json) {
    final obj = json['obj'] is Map<String, dynamic> ? json['obj'] as Map<String, dynamic> : const <String, dynamic>{};
    final rawSuccess = _pick(json, ['success']) ?? _pick(obj, ['success']);
    final url = (_pick(json, ['reportUrl', 'report_url']) ?? _pick(obj, ['reportUrl', 'report_url']) ?? '').toString().trim();

    return AccountStatementResponse(
      success: rawSuccess == null
          ? url.isNotEmpty
          : rawSuccess == true || rawSuccess.toString().toLowerCase() == 'true' || rawSuccess.toString() == '1',
      reportUrl: url,
      message: (_pick(json, ['message', 'msg']) ?? '').toString(),
    );
  }
}
