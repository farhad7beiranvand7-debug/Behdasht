import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/person.dart';
import 'models/care_item.dart';
import 'data/health_rules.dart';
import 'services/care_engine.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  try {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  } catch (_) {}

  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'پزشک خانواده و سلامت',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF7FBF9),
        cardTheme: CardTheme(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<Person> _family = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('family_members');
    if (raw != null) {
      final List dec = jsonDecode(raw);
      _family = dec.map((e) => Person.fromJson(e)).toList();
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveData() async {
    final sp = await SharedPreferences.getInstance();
    final enc = jsonEncode(_family.map((e) => e.toJson()).toList());
    await sp.setString('family_members', enc);
    setState(() {});
  }

  void _addOrEditPerson(Person p) {
    final idx = _family.indexWhere((x) => x.id == p.id);
    if (idx >= 0) {
      _family[idx] = p;
    } else {
      _family.add(p);
    }
    _saveData();
  }

  void _removePerson(String id) {
    _family.removeWhere((x) => x.id == id);
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      DashboardTab(
        family: _family,
        onAddMember: () => _openPersonForm(context),
      ),
      FamilyTab(
        family: _family,
        onAddMember: () => _openPersonForm(context),
        onEditMember: (p) => _openPersonForm(context, person: p),
        onDeleteMember: _removePerson,
      ),
      const HealthCentersTab(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'میز خدمت'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'اعضای خانواده'),
          NavigationDestination(icon: Icon(Icons.local_hospital_outlined), selectedIcon: Icon(Icons.local_hospital), label: 'مراکز بهداشت'),
        ],
      ),
    );
  }

  void _openPersonForm(BuildContext context, {Person? person}) async {
    final result = await showModalBottomSheet<Person>(
      context: context,
      isScrollExtentLimited: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => PersonFormSheet(person: person),
    );

    if (result != null) {
      _addOrEditPerson(result);
    }
  }
}

class DashboardTab extends StatelessWidget {
  final List<Person> family;
  final VoidCallback onAddMember;

  const DashboardTab({super.key, required this.family, required this.onAddMember});

  @override
  Widget build(BuildContext context) {
    List<CareItem> allCares = [];
    for (var m in family) {
      allCares.addAll(CareEngine.generateCareItems(m));
    }
    allCares.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('پزشک خانواده و سلامت'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.health_and_safety_outlined, size: 54, color: Colors.white),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'دستیار هوشمند سلامت خانواده',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تعداد اعضا: ${family.length} نفر  |  مراقبت‌های فعال: ${allCares.length}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('اقدامات و مراقبت‌های پیش‌رو', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${allCares.length} مورد', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          if (family.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.person_add_alt_1, size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('هنوز هیچ عضوی ثبت نشده است.'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: onAddMember,
                      icon: const Icon(Icons.add),
                      label: const Text('افزودن عضو جدید'),
                    ),
                  ],
                ),
              ),
            )
          else if (allCares.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('هیچ مراقبت فعالی در حال حاضر وجود ندارد.'),
              ),
            )
          else
            ...allCares.map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: Icon(_getCareIcon(c.type), color: Colors.teal.shade700),
                    ),
                    title: Text('${c.title} (${c.personName})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.description),
                        const SizedBox(height: 4),
                        Text(
                          'سررسید: ${DateFormat('yyyy/MM/dd').format(c.dueDate)}  •  ${c.source}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                )),
        ],
      ),
    );
  }

  IconData _getCareIcon(CareType type) {
    switch (type) {
      case CareType.vaccine:
        return Icons.vaccines;
      case CareType.pregnancy:
        return Icons.pregnant_woman;
      case CareType.checkup:
        return Icons.medical_services;
      case CareType.screening:
        return Icons.search;
      default:
        return Icons.event_note;
    }
  }
}

class FamilyTab extends StatelessWidget {
  final List<Person> family;
  final VoidCallback onAddMember;
  final ValueChanged<Person> onEditMember;
  final ValueChanged<String> onDeleteMember;

  const FamilyTab({
    super.key,
    required this.family,
    required this.onAddMember,
    required this.onEditMember,
    required this.onDeleteMember,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت اعضای خانواده'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddMember,
        child: const Icon(Icons.person_add),
      ),
      body: family.isEmpty
          ? const Center(child: Text('عضوی تعریف نشده است. با دکمه پایین اضافه کنید.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: family.length,
              itemBuilder: (ctx, i) {
                final p = family[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: p.gender == 'female' ? Colors.pink.shade50 : Colors.blue.shade50,
                      child: Icon(
                        p.gender == 'female' ? Icons.female : Icons.male,
                        color: p.gender == 'female' ? Colors.pink : Colors.blue,
                      ),
                    ),
                    title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'سن: ${p.ageYears} سال | بیماری‌ها: ${p.conditions.isEmpty ? "ندارد" : p.conditions.join("، ")}'
                      '${p.isPregnant ? " | باردار" : ""}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') onEditMember(p);
                        if (val == 'delete') onDeleteMember(p.id);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                        const PopupMenuItem(value: 'delete', child: Text('حذف')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class HealthCentersTab extends StatelessWidget {
  const HealthCentersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پایگاه‌ها و مراکز سلامت'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_in_talk, color: Colors.green),
              title: const Text('سامانه پاسخگویی وزارت بهداشت (۱۹۰)'),
              subtitle: const Text('مشاوره دارویی، شکایات، اطلاعات مراکز بهداشتی درمانی'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emergency, color: Colors.red),
              title: const Text('اورژانس کشور (۱۱۵)'),
              subtitle: const Text('خدمات فوریت‌های پزشکی شبانه‌روزی'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.teal),
              title: const Text('نزدیک‌ترین خانه یا پایگاه سلامت'),
              subtitle: const Text('برای دریافت رایگان خدمات واکسیناسیون، غربالگری و مراقبت‌های اولیه به نزدیک‌ترین پایگاه بهداشت محله خود مراجعه فرمایید.'),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonFormSheet extends StatefulWidget {
  final Person? person;
  const PersonFormSheet({super.key, this.person});

  @override
  State<PersonFormSheet> createState() => _PersonFormSheetState();
}

class _PersonFormSheetState extends State<PersonFormSheet> {
  final _nameCtrl = TextEditingController();
  DateTime _birthDate = DateTime(2000, 1, 1);
  String _gender = 'male';
  final List<String> _selectedConditions = [];
  bool _isPregnant = false;

  @override
  void initState() {
    super.initState();
    if (widget.person != null) {
      _nameCtrl.text = widget.person!.fullName;
      _birthDate = widget.person!.birthDate;
      _gender = widget.person!.gender;
      _selectedConditions.addAll(widget.person!.conditions);
      _isPregnant = widget.person!.isPregnant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.person == null ? 'افزودن عضو جدید' : 'ویرایش اطلاعات', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'نام و نام‌خانوادگی', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text('تاریخ تولد: ${DateFormat('yyyy/MM/dd').format(_birthDate)}'),
                ),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _birthDate,
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _birthDate = d);
                  },
                  child: const Text('انتخاب تاریخ'),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('جنسیت:'),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('مرد'),
                  selected: _gender == 'male',
                  onSelected: (s) => setState(() => _gender = 'male'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('زن'),
                  selected: _gender == 'female',
                  onSelected: (s) => setState(() => _gender = 'female'),
                ),
              ],
            ),
            if (_gender == 'female') ...[
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('باردار است'),
                value: _isPregnant,
                onChanged: (val) => setState(() => _isPregnant = val),
              ),
            ],
            const SizedBox(height: 12),
            const Text('سابقه بیماری یا وضعیت خاص:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 6,
              children: commonConditions.map((c) {
                final exists = _selectedConditions.contains(c);
                return FilterChip(
                  label: Text(c, style: const TextStyle(fontSize: 12)),
                  selected: exists,
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _selectedConditions.add(c);
                      } else {
                        _selectedConditions.remove(c);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                if (_nameCtrl.text.trim().isEmpty) return;
                final p = Person(
                  id: widget.person?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  fullName: _nameCtrl.text.trim(),
                  birthDate: _birthDate,
                  gender: _gender,
                  conditions: _selectedConditions,
                  isPregnant: _gender == 'female' && _isPregnant,
                  pregnancyStartDate: (_gender == 'female' && _isPregnant) ? DateTime.now().subtract(const Duration(days: 60)) : null,
                );
                Navigator.pop(context, p);
              },
              child: const Text('ذخیره و ثبت'),
            ),
          ],
        ),
      ),
    );
  }
}
