class BranchModel {
  final String statusCode;
  final String message;
  final List<Branch> branchList;

  BranchModel({
    required this.statusCode,
    required this.message,
    required this.branchList,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      statusCode: json['StatusCode'] ?? '',
      message: json['Message'] ?? '',
      branchList: (json['obj']?['Branchlist'] as List<dynamic>? ?? [])
          .map((item) => Branch.fromJson(item))
          .toList(),
    );
  }
}

class Branch {
  final String brnCode;
  final String brnName;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? address4;
  final String? emailAddress;
  final String? phoneNo;
  final String? imageUrl;
  final String? portfolioUrl;

  Branch({
    required this.brnCode,
    required this.brnName,
    this.address1,
    this.address2,
    this.address3,
    this.address4,
    this.emailAddress,
    this.phoneNo,
    this.imageUrl,
    this.portfolioUrl,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      brnCode: (json['brn_code'] ?? '').toString(),
      brnName: (json['brn_name'] ?? '').trim(),
      address1: json['add_1'],
      address2: json['add_2'],
      address3: json['add_3'],
      address4: json['add_4'],
      emailAddress: json['email_address'],
      phoneNo: json['phone_no'],
      imageUrl: json['image_url'],
      portfolioUrl: json['portfolio_url'],
    );
  }
}
