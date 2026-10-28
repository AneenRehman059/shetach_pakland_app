class ClientBillModel {
  final String statusCode;
  final String message;
  final List<Bill> bills;

  ClientBillModel({
    required this.statusCode,
    required this.message,
    required this.bills,
  });

  factory ClientBillModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> billList = json['obj'] ?? [];
    return ClientBillModel(
      statusCode: json['StatusCode']?.toString() ?? '500',
      message: json['Message']?.toString() ?? 'No message',
      bills: billList.map<Bill>((item) => Bill.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'StatusCode': statusCode,
      'Message': message,
      'obj': bills.map((bill) => bill.toJson()).toList(),
    };
  }
}

class Bill {
  final int billNo;
  final int billForMonth;
  final int billForYear;
  final double rentDueAmt;
  final DateTime billDueDate;
  final double beforeDueDateAmt;
  final String registrationNo;
  final String registeredName;
  final double rentArrears;
  final double surchargeAmt;
  final double surchargePercent;
  final double rentOsAmt;
  final double rentReceivedAmt;
  final String plotNo;
  final String blockNo;
  final String meterNo;
  final String meterCategory;

  Bill({
    required this.billNo,
    required this.billForMonth,
    required this.billForYear,
    required this.rentDueAmt,
    required this.billDueDate,
    required this.beforeDueDateAmt,
    required this.registrationNo,
    required this.registeredName,
    required this.rentArrears,
    required this.surchargeAmt,
    required this.surchargePercent,
    required this.rentOsAmt,
    required this.rentReceivedAmt,
    required this.plotNo,
    required this.blockNo,
    required this.meterNo,
    required this.meterCategory,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    String safeParseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    DateTime parseDate(dynamic dateValue) {
      try {
        if (dateValue == null) return DateTime.now();
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        }
        return DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    return Bill(
      billNo: safeParseInt(json['bill_no']),
      billForMonth: safeParseInt(json['bill_for_month']),
      billForYear: safeParseInt(json['bill_for_year']),
      rentDueAmt: safeParseDouble(json['rent_due_amt']),
      billDueDate: parseDate(json['bill_due_date']),
      beforeDueDateAmt: safeParseDouble(json['before_due_date_amt']),
      registrationNo: safeParseString(json['registration_no']),
      registeredName: safeParseString(json['registered_name']),
      rentArrears: safeParseDouble(json['rent_arears']),
      surchargeAmt: safeParseDouble(json['surcharge_amt']),
      surchargePercent: safeParseDouble(json['surcharge_percent']),
      rentOsAmt: safeParseDouble(json['rent_os_amt']),
      rentReceivedAmt: safeParseDouble(json['rent_received_amt']),
      plotNo: safeParseString(json['plot_no']),
      blockNo: safeParseString(json['block_no']),
      meterNo: safeParseString(json['meter_no']),
      meterCategory: safeParseString(json['meter_category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bill_no': billNo,
      'bill_for_month': billForMonth,
      'bill_for_year': billForYear,
      'rent_due_amt': rentDueAmt,
      'bill_due_date': billDueDate.toIso8601String(),
      'before_due_date_amt': beforeDueDateAmt,
      'registration_no': registrationNo,
      'registered_name': registeredName,
      'rent_arears': rentArrears,
      'surcharge_amt': surchargeAmt,
      'surcharge_percent': surchargePercent,
      'rent_os_amt': rentOsAmt,
      'rent_received_amt': rentReceivedAmt,
      'plot_no': plotNo,
      'block_no': blockNo,
      'meter_no': meterNo,
      'meter_category': meterCategory,
    };
  }

  double get totalAmountDue => rentDueAmt + rentArrears + surchargeAmt;

  double get remainingAmount => rentOsAmt - rentReceivedAmt;

  bool get isOverdue => billDueDate.isBefore(DateTime.now());

  bool get isFullyPaid => rentReceivedAmt >= totalAmountDue;

  double get payableBeforeDueDate => beforeDueDateAmt;

  String get monthYearDisplay {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[billForMonth - 1]} $billForYear';
  }

  String get formattedDueDate {
    return '${billDueDate.day}/${billDueDate.month}/${billDueDate.year}';
  }

  String get propertyAddress => 'Plot $plotNo, Block $blockNo';

  @override
  String toString() {
    return 'Bill{billNo: $billNo, registrationNo: $registrationNo, name: $registeredName, '
        'month: $billForMonth/$billForYear, rentDue: $rentDueAmt, arrears: $rentArrears, '
        'rentOs: $rentOsAmt, received: $rentReceivedAmt, plot: $plotNo, block: $blockNo}';
  }

  Bill copyWith({
    int? billNo,
    int? billForMonth,
    int? billForYear,
    double? rentDueAmt,
    DateTime? billDueDate,
    double? beforeDueDateAmt,
    String? registrationNo,
    String? registeredName,
    double? rentArrears,
    double? surchargeAmt,
    double? surchargePercent,
    double? rentOsAmt,
    double? rentReceivedAmt,
    String? plotNo,
    String? blockNo,
    String? meterNo,
    String? meterCategory,
  }) {
    return Bill(
      billNo: billNo ?? this.billNo,
      billForMonth: billForMonth ?? this.billForMonth,
      billForYear: billForYear ?? this.billForYear,
      rentDueAmt: rentDueAmt ?? this.rentDueAmt,
      billDueDate: billDueDate ?? this.billDueDate,
      beforeDueDateAmt: beforeDueDateAmt ?? this.beforeDueDateAmt,
      registrationNo: registrationNo ?? this.registrationNo,
      registeredName: registeredName ?? this.registeredName,
      rentArrears: rentArrears ?? this.rentArrears,
      surchargeAmt: surchargeAmt ?? this.surchargeAmt,
      surchargePercent: surchargePercent ?? this.surchargePercent,
      rentOsAmt: rentOsAmt ?? this.rentOsAmt,
      rentReceivedAmt: rentReceivedAmt ?? this.rentReceivedAmt,
      plotNo: plotNo ?? this.plotNo,
      blockNo: blockNo ?? this.blockNo,
      meterNo: meterNo ?? this.meterNo,
      meterCategory: meterCategory ?? this.meterCategory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Bill &&
              runtimeType == other.runtimeType &&
              billNo == other.billNo &&
              registrationNo == other.registrationNo &&
              billForMonth == other.billForMonth &&
              billForYear == other.billForYear;

  @override
  int get hashCode =>
      billNo.hashCode ^
      registrationNo.hashCode ^
      billForMonth.hashCode ^
      billForYear.hashCode;
}