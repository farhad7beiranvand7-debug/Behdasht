class HealthRule {
  final String id;
  final String title;
  final String careType;
  final String source;
  final String schedule;
  final String? targetGender;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final String? conditionKey;

  const HealthRule({
    required this.id,
    required this.title,
    required this.careType,
    required this.source,
    required this.schedule,
    this.targetGender,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.conditionKey,
  });
}

class HealthRules {
  static const List<Map<String, dynamic>> vaccinationSchedule = [
    {'title': 'بدو تولد (هپاتیت B، ب ث ژ، فلج اطفال خوراکی)', 'months': 0},
    {'title': '۲ ماهگی (پنتاوالان نوبت اول، فلج اطفال خوراکی)', 'months': 2},
    {'title': '۴ ماهگی (پنتاوالان نوبت دوم، فلج اطفال خوراکی و تزریقی)', 'months': 4},
    {'title': '۶ ماهگی (پنتاوالان نوبت سوم، فلج اطفال خوراکی)', 'months': 6},
    {'title': '۱۲ ماهگی (MMR نوبت اول: سرخک، سرخجه، اوریون)', 'months': 12},
    {'title': '۱۸ ماهگی (یادآور اول سه گانه، فلج اطفال خوراکی، MMR)', 'months': 18},
    {'title': '۶ سالگی (یادآور دوم سه گانه، فلج اطفال خوراکی)', 'months': 72},
  ];

  static const List<HealthRule> vaccineRules = [
    HealthRule(id: 'v_0m', title: 'واکسن بدو تولد (هپاتیت B، ب ث ژ، فلج اطفال)', careType: 'vaccine', source: 'دستورالعمل واکسیناسیون کشوری', schedule: 'بدو تولد', maxAgeMonths: 1),
    HealthRule(id: 'v_2m', title: 'واکسن ۲ ماهگی (پنتاوالان، فلج اطفال)', careType: 'vaccine', source: 'دستورالعمل واکسیناسیون کشوری', schedule: '۲ ماهگی', minAgeMonths: 2, maxAgeMonths: 3),
    HealthRule(id: 'v_4m', title: 'واکسن ۴ ماهگی (پنتاوالان، فلج اطفال تزریقی و خوراکی)', careType: 'vaccine', source: 'دستورالعمل واکسیناسیون کشوری', schedule: '۴ ماهگی', minAgeMonths: 4, maxAgeMonths: 5),
    HealthRule(id: 'v_6m', title: 'واکسن ۶ ماهگی (پنتاوالان، فلج اطفال)', careType: 'vaccine', source: 'دستورالعمل واکسیناسیون کشوری', schedule: '۶ ماهگی', minAgeMonths: 6, maxAgeMonths: 7),
    HealthRule(id: 'v_12m', title: 'واکسن ۱۲ ماهگی (MMR)', careType: 'vaccine', source: 'دستورالعمل واکسیناسیون کشوری', schedule: '۱۲ ماهگی', minAgeMonths: 12, maxAgeMonths: 13),
    HealthRule(id: 'v_18m', title: 'واکسن ۱۸ ماهگی (سه گانه، فلج اطفال، MMR)', careType: 'vaccine', source: 'دستورالعمل واکسیناسیون کشوری', schedule: '۱۸ ماهگی', minAgeMonths: 18, maxAgeMonths: 20),
    HealthRule(id: 'v_6y', title: 'واکسن ۶ سالگی (یادآور دوم سه گانه و فلج اطفال)', careType: 'vaccine', source: 'دستورالعمل واکسیناسیون کشوری', schedule: '۶ سالگی', minAgeMonths: 70, maxAgeMonths: 84),
  ];

  static const List<String> conditionOptions = [
    'دیابت',
    'فشار خون بالا',
    'آسم یا بیماری تنفسی',
    'کم خونی',
    'بیماری قلبی عروقی',
    'اختلالات تیروئید',
    'چربی خون بالا',
    'چاقی',
    'بیماری کلیوی',
    'صرع یا تشنج',
    'سرطان یا سابقه بدخیمی',
  ];

  static const List<HealthRule> conditionRules = [
    HealthRule(id: 'c_dm', title: 'پیگیری کنترل قند خون و آزمایش HbA1c', careType: 'chronic', source: 'راهنمای بالینی دیابت', schedule: 'هر ۳ ماه یک بار', conditionKey: 'دیابت'),
    HealthRule(id: 'c_htn', title: 'کنترل دوره‌ای فشار خون و بررسی وضعیت قلب', careType: 'chronic', source: 'راهنمای بالینی پرفشاری خون', schedule: 'ماهانه', conditionKey: 'فشار خون بالا'),
    HealthRule(id: 'c_thyroid', title: 'آزمایش دوره‌ای عملکرد تیروئید (TSH)', careType: 'chronic', source: 'راهنمای بالینی تیروئید', schedule: 'هر ۶ ماه یک بار', conditionKey: 'اختلالات تیروئید'),
  ];

  static const List<HealthRule> pregnancyRules = [
    HealthRule(id: 'p_w12', title: 'مراقبت پیش از هفته ۱۲ بارداری و سونوگرافی NT', careType: 'pregnancy', source: 'راهنمای کشوری مراقبت بارداری', schedule: 'هفته ۶ تا ۱۰ بارداری', targetGender: 'female'),
    HealthRule(id: 'p_w20', title: 'سونوگرافی آنومالی اسکن و مراقبت نیمه دوم', careType: 'pregnancy', source: 'راهنمای کشوری مراقبت بارداری', schedule: 'هفته ۱۶ تا ۲۰ بارداری', targetGender: 'female'),
    HealthRule(id: 'p_w28', title: 'غربالگری دیابت بارداری (OGTT) و آنتی دی', careType: 'pregnancy', source: 'راهنمای کشوری مراقبت بارداری', schedule: 'هفته ۲۴ تا ۲۸ بارداری', targetGender: 'female'),
    HealthRule(id: 'p_w36', title: 'مراقبت پایانی بارداری و بررسی وضعیت زایمان', careType: 'pregnancy', source: 'راهنمای کشوری مراقبت بارداری', schedule: 'هفته ۳۵ تا ۳۷ بارداری', targetGender: 'female'),
  ];

  static List<Map<String, dynamic>> getUpcomingVaccines(DateTime birthDate) {
    DateTime now = DateTime.now();
    int ageInMonths = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) {
      ageInMonths--;
    }
    
    return vaccinationSchedule.where((item) => item['months'] >= ageInMonths).toList();
  }
}
