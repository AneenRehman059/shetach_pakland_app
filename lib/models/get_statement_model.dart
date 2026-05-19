import 'package:intl/intl.dart';

class ContractResponse {
  final String statusCode;
  final String message;
  final ContractData obj;

  ContractResponse({
    required this.statusCode,
    required this.message,
    required this.obj,
  });

  factory ContractResponse.fromJson(Map<String, dynamic> json) {
    return ContractResponse(
      statusCode: json['StatusCode'] ?? '200',
      message: json['Message'] ?? 'Success',
      obj: ContractData.fromJson(json['obj'] ?? {}),
    );
  }
}

class ContractData {
  final dynamic contractAlert;
  final int totalRecords;
  final dynamic totDueAmt;
  final dynamic totRebatAmt;
  final dynamic totRecievedAmt;
  final dynamic totOverDue;
  final dynamic dueTillToday;
  final bool isPayPro;
  final bool isJazzCash;
  final bool isStripe;
  final bool isUbl;
  final bool isBlurr;
  final bool contractExists;
  final dynamic paymentMethod;
  final dynamic brnCode;
  final dynamic cnic;
  final dynamic brnName;
  final dynamic brnImage;
  final dynamic id;
  final dynamic isCheck;
  final int totalFiles;
  final dynamic name;
  final String fhName;
  final String fhType;
  final String memberName;
  final dynamic memberAdd;
  final String registrationNo;
  final dynamic overDueAmount1;
  final double dueAmount;
  final double totalPrice;
  final double netPrice;
  final double amountReceived;
  final double osAmount;
  final double overDueAmount;
  final double extraOverDue;
  final bool isSelected;
  final String paymentCode;
  final dynamic unit;
  final String emailAddress;
  final dynamic email;
  final String phoneNo;
  final String mobileNo;
  final String phoneOffice;
  final String blockNo;
  final dynamic blockName;
  final String plotNo;
  final String registrationStatus;
  final String plotType;
  final String plotNature;
  final String plotSize;
  final dynamic city;
  final dynamic country;
  final dynamic alert;
  final String add1;
  final String add2;
  final String add3;
  final dynamic grp;
  final dynamic dollarRate;
  final dynamic fixedCharges;
  final dynamic perCharges;
  final dynamic otherCharges;
  final dynamic imagePath;
  final dynamic image;
  final int locked;
  final int normal;
  final int cancel;
  final dynamic acceptContracts;
  final dynamic rejectContracts;
  final double previousOverDueAmount;
  final String transactionId;
  final dynamic blockDrop;
  final dynamic clientDetailList;
  final List<Statement> statementList;
  final dynamic receiptList;
  final dynamic branchList;
  final dynamic receiptLog;
  final dynamic logBy;
  final DateTime logDate;

  ContractData({
    required this.contractAlert,
    required this.totalRecords,
    required this.totDueAmt,
    required this.totRebatAmt,
    required this.totRecievedAmt,
    required this.totOverDue,
    required this.dueTillToday,
    required this.isPayPro,
    required this.isJazzCash,
    required this.isStripe,
    required this.isUbl,
    required this.isBlurr,
    required this.contractExists,
    required this.paymentMethod,
    required this.brnCode,
    required this.cnic,
    required this.brnName,
    required this.brnImage,
    required this.id,
    required this.isCheck,
    required this.totalFiles,
    required this.name,
    required this.fhName,
    required this.fhType,
    required this.memberName,
    required this.memberAdd,
    required this.registrationNo,
    required this.overDueAmount1,
    required this.dueAmount,
    required this.totalPrice,
    required this.netPrice,
    required this.amountReceived,
    required this.osAmount,
    required this.overDueAmount,
    required this.extraOverDue,
    required this.isSelected,
    required this.paymentCode,
    required this.unit,
    required this.emailAddress,
    required this.email,
    required this.phoneNo,
    required this.mobileNo,
    required this.phoneOffice,
    required this.blockNo,
    required this.blockName,
    required this.plotNo,
    required this.registrationStatus,
    required this.plotType,
    required this.plotNature,
    required this.plotSize,
    required this.city,
    required this.country,
    required this.alert,
    required this.add1,
    required this.add2,
    required this.add3,
    required this.grp,
    required this.dollarRate,
    required this.fixedCharges,
    required this.perCharges,
    required this.otherCharges,
    required this.imagePath,
    required this.image,
    required this.locked,
    required this.normal,
    required this.cancel,
    required this.acceptContracts,
    required this.rejectContracts,
    required this.previousOverDueAmount,
    required this.transactionId,
    required this.blockDrop,
    required this.clientDetailList,
    required this.statementList,
    required this.receiptList,
    required this.branchList,
    required this.receiptLog,
    required this.logBy,
    required this.logDate,
  });

  factory ContractData.fromJson(Map<String, dynamic> json) {
    return ContractData(
      contractAlert: json['Contractalert'],
      totalRecords: (json['total_records'] ?? 0).toInt(),
      totDueAmt: json['tot_due_amt'],
      totRebatAmt: json['tot_rebat_amt'],
      totRecievedAmt: json['tot_recieved_amt'],
      totOverDue: json['tot_over_due'],
      dueTillToday: json['Due_till_today'],
      isPayPro: json['ispaypro'] ?? false,
      isJazzCash: json['isJazzCash'] ?? false,
      isStripe: json['isstripe'] ?? false,
      isUbl: json['isubl'] ?? false,
      isBlurr: json['isblurr'] ?? false,
      contractExists: json['ContractExists'] ?? false,
      paymentMethod: json['paymentmethod'],
      brnCode: json['brn_code'],
      cnic: json['CNIC'],
      brnName: json['brn_name'],
      brnImage: json['brn_image'],
      id: json['Id'],
      isCheck: json['isCheck'],
      totalFiles: (json['TotalFiles'] ?? 0).toInt(),
      name: json['Name'],
      fhName: json['fh_name'] ?? '',
      fhType: json['fh_type'] ?? '',
      memberName: json['member_name'] ?? '',
      memberAdd: json['member_add'],
      registrationNo: json['Registration_no'] ?? '',
      overDueAmount1: json['OverDueAmount_1'],
      dueAmount: (json['DueAmount'] ?? 0).toDouble(),
      totalPrice: (json['TotalPrice'] ?? 0).toDouble(),
      netPrice: (json['net_price'] ?? 0).toDouble(),
      amountReceived: (json['AmountReceived'] ?? 0).toDouble(),
      osAmount: (json['OsAmount'] ?? 0).toDouble(),
      overDueAmount: (json['OverDueAmount'] ?? 0).toDouble(),
      extraOverDue: (json['ExtraOverDue'] ?? 0).toDouble(),
      isSelected: json['isSelectetd'] ?? false,
      paymentCode: json['payment_code'] ?? '',
      unit: json['unit'],
      emailAddress: json['email_address'] ?? '',
      email: json['email'],
      phoneNo: json['phone_no'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      phoneOffice: json['phone_office'] ?? '',
      blockNo: json['block_no'] ?? '',
      blockName: json['block_name'],
      plotNo: json['plot_no'] ?? '',
      registrationStatus: json['registration_status'] ?? '',
      plotType: json['plot_type'] ?? '',
      plotNature: json['plot_nature'] ?? '',
      plotSize: json['plot_size'] ?? '',
      city: json['city'],
      country: json['country'],
      alert: json['alert'],
      add1: json['add1'] ?? '',
      add2: json['add2'] ?? '',
      add3: json['add3'] ?? '',
      grp: json['grp'],
      dollarRate: json['dollar_rate'],
      fixedCharges: json['fixed_charges'],
      perCharges: json['per_charges'],
      otherCharges: json['other_charges'],
      imagePath: json['image_path'],
      image: json['image'],
      locked: (json['locked'] ?? 0).toInt(),
      normal: (json['normal'] ?? 0).toInt(),
      cancel: (json['cancel'] ?? 0).toInt(),
      acceptContracts: json['accept_contracts'],
      rejectContracts: json['reject_Contracts'],
      previousOverDueAmount: (json['PreviousOverDueAmount'] ?? 0).toDouble(),
      transactionId: json['tranactionId'] ?? '00000000-0000-0000-0000-000000000000',
      blockDrop: json['block_drop'],
      clientDetailList: json['Clientdetaillist'],
      statementList: (json['Statementlist'] as List<dynamic>? ?? [])
          .map((e) => Statement.fromJson(e))
          .toList(),
      receiptList: json['Receiptlist'],
      branchList: json['Branchlist'],
      receiptLog: json['receiptLog'],
      logBy: json['log_by'],
      logDate: DateTime.parse(json['log_date'] ?? '0001-01-01T00:00:00'),
    );
  }
}

class Statement {
  final String grp;
  final String registrationNo;
  final String brnCode;
  final String paymentType;
  final int installmentNo;
  final DateTime dates;
  final dynamic installmentDate;
  final double dueAmt;
  final double amtReceived;
  final double osAmt;
  final double rebatAmt;

  Statement({
    required this.grp,
    required this.registrationNo,
    required this.brnCode,
    required this.paymentType,
    required this.installmentNo,
    required this.dates,
    required this.installmentDate,
    required this.dueAmt,
    required this.amtReceived,
    required this.osAmt,
    required this.rebatAmt,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;

    try {
      if (json['Dates'] != null && json['Dates'].toString().isNotEmpty) {
        parsedDate = DateFormat("M/d/yyyy h:mm:ss a").parse(json['Dates']);
      } else {
        parsedDate = DateTime(0001, 01, 01);
      }
    } catch (_) {
      parsedDate = DateTime(0001, 01, 01);
    }

    return Statement(
      grp: json['grp'] ?? '',
      registrationNo: json['registration_no'] ?? '',
      brnCode: json['brn_code'] ?? '',
      paymentType: json['payment_type'] ?? '',
      installmentNo: (json['installment_no'] ?? 0).toInt(),
      dates: parsedDate,
      installmentDate: json['installment_date'],
      dueAmt: (json['due_amt'] ?? 0).toDouble(),
      amtReceived: (json['amt_received'] ?? 0).toDouble(),
      osAmt: (json['os_amt'] ?? 0).toDouble(),
      rebatAmt: (json['rebat_amt'] ?? 0).toDouble(),
    );
  }

}