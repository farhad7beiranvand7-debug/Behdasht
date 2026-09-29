class Person {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String gender;
  final List<String> conditions;
  final bool isPregnant;
  final DateTime? pregnancyStartDate;

  Person({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.conditions,
    this.isPregnant = false,
    this.pregnancyStartDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        'conditions': conditions,
        'isPregnant': isPregnant,
        'pregnancyStartDate': pregnancyStartDate?.toIso8601String(),
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        gender: json['gender'] as String,
        conditions: (json['conditions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isPregnant: json['isPregnant'] as bool? ?? false,
        pregnancyStartDate: json['pregnancyStartDate'] != null
            ? DateTime.parse(json['pregnancyStartDate'] as String)
            : null,
      );

  int get ageYears {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
