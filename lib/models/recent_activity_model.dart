class RecentActivityModel {
  final String logDate;
  final String longitude;
  final String latitude;

  RecentActivityModel({
    required this.logDate,
    required this.longitude,
    required this.latitude,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      logDate: json['LogDate'] ?? "",
      longitude: json['Longitude'] ?? "",
      latitude: json['Latitude'] ?? "",
    );
  }
}
