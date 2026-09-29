import '../models/person.dart';
import '../models/care_item.dart';
import '../data/health_rules.dart';

class CareEngine {
  static List<CareItem> generateCareItems(Person person) {
    final List<CareItem> items = [];
    final now = DateTime.now();

    for (final v in nationalVaccineRules) {
      final dueDate = DateTime(
        person.birthDate.year,
        person.birthDate.month + v.monthsOffset,
        person.birthDate.day,
      );

      if (dueDate.isAfter(now.subtract(const Duration(days: 30)))) {
        items.add(
          CareItem(
            id: 'vac_${person.id}_${v.monthsOffset}',
            personId: person.id,
            personName: person.fullName,
            title: v.title,
            description: v.description,
            dueDate: dueDate,
            type: CareType.vaccine,
            source: 'سامانه سیب / برنامه ایمن‌سازی کشوری',
          ),
        );
      }
    }

    for (final cond in person.conditions) {
      final rules = conditionRules.where((r) => r.requiredCondition == cond);
      for (final r in rules) {
        items.add(
          CareItem(
            id: 'rule_${person.id}_${r.id}',
            personId: person.id,
            personName: person.fullName,
            title: r.title,
            description: r.description,
            dueDate: now.add(Duration(days: r.repeatDays)),
            type: r.type,
            source: 'راهنمای بالینی مراقبت‌های ادغام‌یافته سلامت',
          ),
        );
      }
    }

    if (person.isPregnant && person.pregnancyStartDate != null) {
      final pregWeeks = [12, 20, 28, 36];
      for (final w in pregWeeks) {
        final dueDate = person.pregnancyStartDate!.add(Duration(days: w * 7));
        if (dueDate.isAfter(now.subtract(const Duration(days: 14)))) {
          items.add(
            CareItem(
              id: 'preg_${person.id}_$w',
              personId: person.id,
              personName: person.fullName,
              title: 'مراقبت بارداری هفته $w',
              description: 'سونوگرافی/آزمایش/پایش وزن و فشار مادر و سلامت جنین',
              dueDate: dueDate,
              type: CareType.pregnancy,
              source: 'راهنمای کشوری مراقبت مادری و نوزادی',
            ),
          );
        }
      }
    }

    items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }
}
