class BillReceiptResponse {
  final String statusCode;
  final String message;
  final List<BillReceipt> receipts;

  BillReceiptResponse({
    required this.statusCode,
    required this.message,
    required this.receipts,
  });

  factory BillReceiptResponse.fromJson(Map<String, dynamic> json) {
    return BillReceiptResponse(
      statusCode: json['StatusCode']?.toString() ?? '0',
      message: json['Message']?.toString() ?? '',
      receipts: _parseReceipts(json['obj']),
    );
  }

  static List<BillReceipt> _parseReceipts(dynamic objData) {
    if (objData == null) return [];

    if (objData is List) {
      return objData
          .where((item) => item is Map<String, dynamic>)
          .map((item) => BillReceipt.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}

class BillReceipt {
  final String brnCode;
  final int receiptNo;
  final String registrationNo;
  final String paymentMode;
  final double receivedAmt;
  final String? receivedDate;
  final String receiptStatus;
  final String? postBy;
  final String? postingDate;
  final String? bankCode;
  final String? branchCode;
  final String? instrumentNo;
  final String? instrumentDate;
  final String? paymentFlag;
  final String? referenceNo;
  final String? depositDate;
  final double advanceAmt;
  final String? voucherType;
  final String? paymentCategory;
  final String? blockNo;
  final String? plotNo;
  final int lastBillNo;

  BillReceipt({
    required this.brnCode,
    required this.receiptNo,
    required this.registrationNo,
    required this.paymentMode,
    required this.receivedAmt,
    this.receivedDate,
    required this.receiptStatus,
    this.postBy,
    this.postingDate,
    this.bankCode,
    this.branchCode,
    this.instrumentNo,
    this.instrumentDate,
    this.paymentFlag,
    this.referenceNo,
    this.depositDate,
    required this.advanceAmt,
    this.voucherType,
    this.paymentCategory,
    this.blockNo,
    this.plotNo,
    required this.lastBillNo,
  });

  factory BillReceipt.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    return BillReceipt(
      brnCode: parseString(json['brn_code']) ?? '',
      receiptNo: parseInt(json['receipt_no']),
      registrationNo: parseString(json['registration_no']) ?? '',
      paymentMode: parseString(json['payment_mode']) ?? 'N/A',
      receivedAmt: parseDouble(json['received_amt']),
      receivedDate: parseString(json['received_date']),
      receiptStatus: parseString(json['receipt_status']) ?? 'N/A',
      postBy: parseString(json['post_by']),
      postingDate: parseString(json['posting_date']),
      bankCode: parseString(json['bank_code']),
      branchCode: parseString(json['branch_code']),
      instrumentNo: parseString(json['instrument_no']),
      instrumentDate: parseString(json['instrument_date']),
      paymentFlag: parseString(json['payment_flag']),
      referenceNo: parseString(json['reference_no']),
      depositDate: parseString(json['deposit_date']),
      advanceAmt: parseDouble(json['advance_amt']),
      voucherType: parseString(json['voucher_type']),
      paymentCategory: parseString(json['payment_category']),
      blockNo: parseString(json['block_no']),
      plotNo: parseString(json['plot_no']),
      lastBillNo: parseInt(json['last_bill_no']),
    );
  }

  String get formattedDate {
    String? dateString = receivedDate ?? postingDate;

    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime != null) {
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      }

      return dateString.split('T')[0];
    } catch (e) {
      return dateString;
    }
  }

  double get paidAmt => receivedAmt;

  String get displayDate => formattedDate;
}