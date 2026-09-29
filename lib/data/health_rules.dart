import '../models/care_item.dart';

class VaccineRule {
  final int monthsOffset;
  final String title;
  final String description;

  const VaccineRule({
    required this.monthsOffset,
    required this.title,
    required this.description,
  });
}

class HealthRule {
  final String id;
  final String title;
  final String description;
  final CareType type;
  final int? minAgeYears;
  final int? maxAgeYears;
  final String? gender;
  final String? requiredCondition;
  final int repeatDays;

  const HealthRule({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.minAgeYears,
    this.maxAgeYears,
    this.gender,
    this.requiredCondition,
    this.repeatDays = 365,
  });
}

final List<VaccineRule> nationalVaccineRules = [
  const VaccineRule(monthsOffset: 0, title: 'واکسن بدو تولد', description: 'ب ث ژ، فلج اطفال خوراکی، هپاتیت ب'),
  const VaccineRule(monthsOffset: 2, title: 'واکسن ۲ ماهگی', description: 'پنج‌گانه (پنتاوالان) نوبت اول + فلج اطفال خوراکی'),
  const VaccineRule(monthsOffset: 4, title: 'واکسن ۴ ماهگی', description: 'پنج‌گانه نوبت دوم + فلج اطفال خوراکی + فلج اطفال تزریقی'),
  const VaccineRule(monthsOffset: 6, title: 'واکسن ۶ ماهگی', description: 'پنج‌گانه نوبت سوم + فلج اطفال خوراکی'),
  const VaccineRule(monthsOffset: 12, title: 'واکسن ۱۲ ماهگی', description: 'ام‌ام‌آر (MMR) نوبت اول'),
  const VaccineRule(monthsOffset: 18, title: 'واکسن ۱۸ ماهگی', description: 'سه‌گانه (DTP) یادآور اول + فلج اطفال + MMR یادآور'),
  const VaccineRule(monthsOffset: 72, title: 'واکسن ۶ سالگی', description: 'سه‌گانه یادآور دوم + فلج اطفال خوراکی یادآور'),
];

final List<String> commonConditions = [
  'دیابت',
  'فشار خون بالا',
  'بیماری قلبی-عروقی',
  'کم‌کاری تیروئید',
  'آسم یا بیماری مزمن ریوی',
  'بیماری مزمن کلیوی',
  'کبد چرب',
  'چربی خون بالا',
  'سابقه سرطان',
  'نقص ایمنی',
  'سایر موارد مزمن',
];

final List<HealthRule> conditionRules = [
  const HealthRule(
    id: 'dm_checkup',
    title: 'مراقبت دوره‌ای دیابت',
    description: 'بررسی قند خون ناشتا، HbA1c، معاینه پا و ارزیابی کلیوی طبق راهنمای کشوری',
    type: CareType.checkup,
    requiredCondition: 'دیابت',
    repeatDays: 90,
  ),
  const HealthRule(
    id: 'htn_checkup',
    title: 'مراقبت دوره‌ای فشار خون',
    description: 'اندازه‌گیری و ثبت فشار خون، ارزیابی سبک زندگی و پایبندی دارویی',
    type: CareType.checkup,
    requiredCondition: 'فشار خون بالا',
    repeatDays: 60,
  ),
  const HealthRule(
    id: 'hypothyroid_checkup',
    title: 'بررسی دوره‌ای کم‌کاری تیروئید',
    description: 'آزمایش TSH و تنظیم دوز دارو تحت نظر پزشک',
    type: CareType.checkup,
    requiredCondition: 'کم‌کاری تیروئید',
    repeatDays: 180,
  ),
];
