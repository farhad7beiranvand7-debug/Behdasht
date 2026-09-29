enum CareType {
  vaccine,
  checkup,
  screening,
  pregnancy,
  periodic,
  reminder,
}

class CareItem {
  final String id;
  final String personId;
  final String personName;
  final String title;
  final String description;
  final DateTime dueDate;
  final CareType type;
  final String source;

  CareItem({
    required this.id,
    required this.personId,
    required this.personName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    required this.source,
  });
}
