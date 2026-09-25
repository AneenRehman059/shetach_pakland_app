class FaqModel {
  final int? id;
  final String question;
  final String answer;

  FaqModel({
    this.id,
    required this.question,
    required this.answer,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json["ID"],
      question: json["Question"] ?? "",
      answer: json["Answer"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ID": id,
      "Question": question,
      "Answer": answer,
    };
  }
}
