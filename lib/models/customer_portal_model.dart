class CustomerPortalResponse {
  final String statusCode;
  final String message;
  final CustomerPortalObj obj;

  CustomerPortalResponse({
    required this.statusCode,
    required this.message,
    required this.obj,
  });

  factory CustomerPortalResponse.fromJson(Map<String, dynamic> json) {
    return CustomerPortalResponse(
      statusCode: json["StatusCode"] ?? "",
      message: json["Message"] ?? "",
      obj: CustomerPortalObj.fromJson(json["obj"] ?? {}),
    );
  }
}

class CustomerPortalObj {
  final String name;
  final String cnic;
  final int totalFiles;
  final String address;
  final String address1;
  final String address2;
  final String address3;

  final int total;
  final int active;
  final int reserve;
  final int canceled;

  final int totalAmount;
  final int totalReceived;
  final int totalOS;
  final int totalOverdue;

  CustomerPortalObj({
    required this.name,
    required this.cnic,
    required this.totalFiles,
    required this.address,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.total,
    required this.active,
    required this.reserve,
    required this.canceled,
    required this.totalAmount,
    required this.totalReceived,
    required this.totalOS,
    required this.totalOverdue,
  });

  factory CustomerPortalObj.fromJson(Map<String, dynamic> json) {
    return CustomerPortalObj(
      name: json["Name"] ?? "",
      cnic: json["CNIC"] ?? "",
      totalFiles: (json["TotalFiles"] ?? 0).toInt(),
      address: json["member_add"] ?? "",
      address1: json["add1"] ?? "",
      address2: json["add2"] ?? "",
      address3: json["add3"] ?? "",
      total: json["TotalFiles"] ?? 0,
      active: json["normal"] ?? 0,
      reserve: json["locked"] ?? 0,
      canceled: json["cancel"] ?? 0,
      totalAmount: (json["TotalPrice"] ?? 0).toInt(),
      totalReceived: (json["AmountReceived"] ?? 0).toInt(),
      totalOS: (json["OsAmount"] ?? 0).toInt(),
      totalOverdue: (json["OverDueAmount"] ?? 0).toInt(),
    );
  }
}
