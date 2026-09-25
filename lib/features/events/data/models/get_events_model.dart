class EventsResponse {
  final String statusCode;
  final String message;
  final EventsObj obj;

  EventsResponse({
    required this.statusCode,
    required this.message,
    required this.obj,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      statusCode: json['StatusCode'] ?? '',
      message: json['Message'] ?? '',
      obj: EventsObj.fromJson(json['obj'] ?? {}),
    );
  }
}

class EventsObj {
  final List<Event> events;
  final List<DevelopmentProgress> developmentProgress;

  EventsObj({
    required this.events,
    required this.developmentProgress,
  });

  factory EventsObj.fromJson(Map<String, dynamic> json) {
    var eventsList = json['events'] as List? ?? [];
    var devList = json['development_progress'] as List? ?? [];

    return EventsObj(
      events: eventsList.map((i) => Event.fromJson(i)).toList(),
      developmentProgress:
      devList.map((i) => DevelopmentProgress.fromJson(i)).toList(),
    );
  }
}

class Event {
  final int id;
  final String imagePath;
  final String imageName;
  final String eventName;
  final String eventId;

  Event({
    required this.id,
    required this.imagePath,
    required this.imageName,
    required this.eventName,
    required this.eventId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      imageName: json['image_name'] ?? '',
      eventName: json['event_name'] ?? '',
      eventId: json['eventid'] ?? '',
    );
  }
}

class DevelopmentProgress {
  final int id;
  final String brnCode;
  final String imagePath;
  final String imageName;
  final String eventName;
  final String eventId;

  DevelopmentProgress({
    required this.id,
    required this.brnCode,
    required this.imagePath,
    required this.imageName,
    required this.eventName,
    required this.eventId,
  });

  factory DevelopmentProgress.fromJson(Map<String, dynamic> json) {
    return DevelopmentProgress(
      id: json['id'] ?? 0,
      brnCode: json['brn_code'] ?? '',
      imagePath: json['image_path'] ?? '',
      imageName: json['image_name'] ?? '',
      eventName: json['event_name'] ?? '',
      eventId: json['eventid'] ?? '',
    );
  }
}
