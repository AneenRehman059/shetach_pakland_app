// models/receipt_model.dart
class ReceiptResponse {
  final String statusCode;
  final String message;
  final ReceiptObj obj;

  ReceiptResponse({
    required this.statusCode,
    required this.message,
    required this.obj,
  });

  factory ReceiptResponse.fromJson(Map<String, dynamic> json) {
    return ReceiptResponse(
      statusCode: json['StatusCode']?.toString() ?? '0',
      message: json['Message']?.toString() ?? '',
      obj: ReceiptObj.fromJson(json['obj'] ?? {}),
    );
  }
}

class ReceiptObj {
  final List<Receipt> receiptList;
  final int totalRecords;

  ReceiptObj({
    required this.receiptList,
    required this.totalRecords,
  });

  factory ReceiptObj.fromJson(Map<String, dynamic> json) {
    final receiptData = json['Receiptlist'] as List?;

    return ReceiptObj(
      receiptList: receiptData != null
          ? receiptData.map((item) => Receipt.fromJson(item)).toList()
          : [],
      totalRecords: json['total_records'] ?? 0,
    );
  }
}

class Receipt {
  final String? registrationNo;
  final String? brnCode;
  final String? bankCode;
  final int receiptNo;
  final String paymentMode;
  final String? instrumentNo;
  final String paidDate;
  final double paidAmt;

  Receipt({
    this.registrationNo,
    this.brnCode,
    this.bankCode,
    required this.receiptNo,
    required this.paymentMode,
    this.instrumentNo,
    required this.paidDate,
    required this.paidAmt,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    // Handle paidAmt conversion safely
    double parsePaidAmt(dynamic value) {
      if (value == null) return 0.0;

      if (value is int) {
        return value.toDouble();
      }

      if (value is double) {
        return value;
      }

      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }

      return 0.0;
    }

    // Handle receiptNo conversion safely
    int parseReceiptNo(dynamic value) {
      if (value == null) return 0;

      if (value is int) {
        return value;
      }

      if (value is double) {
        return value.toInt();
      }

      if (value is String) {
        return int.tryParse(value) ?? 0;
      }

      return 0;
    }

    return Receipt(
      registrationNo: json['registration_no']?.toString(),
      brnCode: json['brn_code']?.toString(),
      bankCode: json['bank_code']?.toString(),
      receiptNo: parseReceiptNo(json['receipt_no']),
      paymentMode: json['payment_mode']?.toString() ?? 'N/A',
      instrumentNo: json['instrument_no']?.toString(),
      paidDate: json['paid_date']?.toString() ?? 'N/A',
      paidAmt: parsePaidAmt(json['paid_amt']),
    );
  }

  // Helper method to format date for display
  String get formattedDate {
    try {
      final dateParts = paidDate.split(' ')[0].split('/');
      if (dateParts.length == 3) {
        return '${dateParts[1]}/${dateParts[0]}/${dateParts[2]}';
      }
      return paidDate;
    } catch (e) {
      return paidDate;
    }
  }

  // Helper method to format amount
  String get formattedAmount {
    return paidAmt.toStringAsFixed(2);
  }
}