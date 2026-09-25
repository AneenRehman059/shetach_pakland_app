class CommunicationPolicyModel {
  final String brnCode;
  final String sectionCode;
  final String keyCode;
  final String keyValue;
  final String keyRemarks;
  final String valueType;

  CommunicationPolicyModel({
    required this.brnCode,
    required this.sectionCode,
    required this.keyCode,
    required this.keyValue,
    required this.keyRemarks,
    required this.valueType,
  });

  factory CommunicationPolicyModel.fromJson(Map<String, dynamic> json) {
    return CommunicationPolicyModel(
      brnCode: json['brn_code']?.toString() ?? '',
      sectionCode: json['section_code']?.toString() ?? '',
      keyCode: json['key_code']?.toString() ?? '',
      keyValue: json['key_value']?.toString() ?? '',
      keyRemarks: json['key_remarks']?.toString() ?? '',
      valueType: json['value_type']?.toString() ?? '',
    );
  }
}
