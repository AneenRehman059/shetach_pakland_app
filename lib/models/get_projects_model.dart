class Branch {
  final String brnCode;
  final String brnName;

  Branch({required this.brnCode, required this.brnName});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      brnCode: json['brn_code'] ?? '',
      brnName: (json['brn_name'] ?? '').trim(),
    );
  }
}
