import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide Person;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'data/health_rules.dart';
import 'models/person.dart';
import 'models/care_item.dart';
import 'services/care_engine.dart';

final notifications = FlutterLocalNotificationsPlugin();
final dateFormat = DateFormat('yyyy/MM/dd');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await notifications.initialize(settings);
  if (Platform.isAndroid) {
    final plugin = notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await plugin?.requestNotificationsPermission();
  }
  runApp(const FamilyDoctorApp());
}

class FamilyDoctorApp extends StatelessWidget {
  const FamilyDoctorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'پزشک خانواده',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF176B87), fontFamily: 'sans'),
        locale: const Locale('fa'),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Person> people = [];
  bool loading = true;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('people');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      people = list.map((e) => Person.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    setState(() => loading = false);
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('people', jsonEncode(people.map((e) => e.toJson()).toList()));
  }

  Future<void> _addOrEdit({Person? person}) async {
    final result = await Navigator.push<Person>(context, MaterialPageRoute(builder: (_) => PersonForm(person: person)));
    if (result == null) return;
    setState(() {
      final i = people.indexWhere((x) => x.id == result.id);
      if (i == -1) people.add(result); else people[i] = result;
    });
    await _save();
  }

  Future<void> _delete(Person person) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('حذف عضو خانواده'),
      content: Text('اطلاعات «${person.fullName}» حذف شود؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف'))
      ],
    ));
    if (ok == true) {
      setState(() => people.removeWhere((x) => x.id == person.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final all = people.expand((p) => CareEngine.build(p, DateTime.now())).toList()..sort((a,b) => a.dueDate.compareTo(b.dueDate));
    final upcoming = all.where((x) => x.dueDate.isBefore(DateTime.now().add(const Duration(days: 60)))).take(12).toList();
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: const Text('پزشک خانواده', style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(tooltip: 'افزودن', onPressed: () => _addOrEdit(), icon: const Icon(Icons.person_add_alt_1))]),
      body: tab == 0 ? Dashboard(people: people, items: upcoming, onAdd: () => _addOrEdit(), onEdit: _addOrEdit, onDelete: _delete) : tab == 1 ? FamilyList(people: people, onEdit: _addOrEdit, onDelete: _delete, onAdd: () => _addOrEdit()) : const AboutPage(),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'), NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'خانواده'), NavigationDestination(icon: Icon(Icons.info_outline), label: 'درباره')]),
      floatingActionButton: tab == 1 ? FloatingActionButton.extended(onPressed: () => _addOrEdit(), icon: const Icon(Icons.add), label: const Text('عضو جدید')) : null,
    ));
  }
}

class Dashboard extends StatelessWidget {
  final List<Person> people;
  final List<CareItem> items;
  final VoidCallback onAdd;
  final Future<void> Function({Person? person}) onEdit;
  final Future<void> Function(Person) onDelete;
  const Dashboard({super.key, required this.people, required this.items, required this.onAdd, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Theme.of(context).colorScheme.primaryContainer), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('سلام 👋', style: TextStyle(fontSize: 18)), const SizedBox(height: 6), Text(people.isEmpty ? 'خانواده را اضافه کنید تا مراقبت‌های دوره‌ای نمایش داده شود.' : 'مراقبت‌های مهم خانواده را یکجا ببینید.', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 14), if (people.isEmpty) FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.person_add), label: const Text('افزودن اولین عضو'))])),
    const SizedBox(height: 18),
    Row(children: [Expanded(child: StatCard(icon: Icons.groups, value: '${people.length}', label: 'عضو خانواده')), const SizedBox(width: 10), Expanded(child: StatCard(icon: Icons.event_note, value: '${items.length}', label: 'مراقبت پیش‌رو'))]),
    const SizedBox(height: 24),
    const Text('مراقبت‌های پیش‌رو', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
    if (items.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('فعلاً موردی برای نمایش نیست. اطلاعات اعضای خانواده را کامل کنید.'))),
    ...items.map((x) => CareTile(item: x)),
    const SizedBox(height: 16),
    const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('این برنامه ابزار یادآوری و سامان‌دهی مراقبت است و جایگزین تشخیص یا ویزیت پزشک نیست. برنامه‌های واکسیناسیون و مراقبت ممکن است با توجه به شرایط فرد و دستورالعمل‌های به‌روز تغییر کنند.'))),
  ]);
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const StatCard({super.key, required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext c) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(icon, size: 28), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text(label)] )])));
}

class CareTile extends StatelessWidget {
  final CareItem item;
  const CareTile({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    final days = item.dueDate.difference(DateTime.now()).inDays;
    final text = days < 0 ? 'گذشته' : days == 0 ? 'امروز' : days == 1 ? 'فردا' : '$days روز دیگر';
    return Card(child: ListTile(leading: CircleAvatar(child: Icon(item.kind == CareKind.vaccine ? Icons.vaccines : item.kind == CareKind.pregnancy ? Icons.pregnant_woman : Icons.medical_services)), title: Text(item.title), subtitle: Text('${item.personName} • ${dateFormat.format(item.dueDate)}'), trailing: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: days < 0 ? Theme.of(context).colorScheme.error : null))));
  }
}

class FamilyList extends StatelessWidget {
  final List<Person> people;
  final Future<void> Function({Person? person}) onEdit;
  final Future<void> Function(Person) onDelete;
  final VoidCallback onAdd;
  const FamilyList({super.key, required this.people, required this.onEdit, required this.onDelete, required this.onAdd});

  @override
  Widget build(BuildContext c) => people.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.groups_outlined, size: 64), const SizedBox(height: 12), const Text('هنوز عضوی ثبت نشده'), const SizedBox(height: 12), FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('افزودن عضو'))]) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: people.length, itemBuilder: (_, i) {
    final p = people[i];
    final age = _age(p.birthDate);
    return Card(child: ListTile(leading: CircleAvatar(child: Text(p.firstName.isEmpty ? '?' : p.firstName[0])), title: Text(p.fullName.isEmpty ? 'بدون نام' : p.fullName), subtitle: Text('${p.gender} • سن: $age${p.conditions.isEmpty ? '' : ' • ${p.conditions.length} وضعیت ثبت‌شده'}${p.pregnant ? ' • بارداری' : ''}'), onTap: () => onEdit(person: p), trailing: PopupMenuButton<String>(onSelected: (v) { if (v == 'edit') onEdit(person: p); if (v == 'delete') onDelete(p); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('ویرایش')), PopupMenuItem(value: 'delete', child: Text('حذف'))])));
  });
}

class PersonForm extends StatefulWidget {
  final Person? person;
  const PersonForm({super.key, this.person});
  @override
  State<PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<PersonForm> {
  late final TextEditingController first, last;
  late DateTime birth;
  String gender = 'زن';
  bool pregnant = false;
  DateTime? pregStart;
  final selected = <String>{};

  @override
  void initState() {
    super.initState();
    final p = widget.person;
    first = TextEditingController(text: p?.firstName);
    last = TextEditingController(text: p?.lastName);
    birth = p?.birthDate ?? DateTime(2020,1,1);
    gender = p?.gender ?? 'زن';
    pregnant = p?.pregnant ?? false;
    pregStart = p?.pregnancyStartDate;
    selected.addAll(p?.conditions ?? []);
  }

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    super.dispose();
  }

  Future<void> pickBirth() async {
    final d = await showDatePicker(context: context, initialDate: birth, firstDate: DateTime(1900), lastDate: DateTime.now());
    if (d != null) setState(() => birth = d);
  }

  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(
    appBar: AppBar(title: Text(widget.person == null ? 'عضو جدید' : 'ویرایش عضو')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: first, decoration: const InputDecoration(labelText: 'نام', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: last, decoration: const InputDecoration(labelText: 'نام خانوادگی', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: gender, decoration: const InputDecoration(labelText: 'جنسیت', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'زن', child: Text('زن')), DropdownMenuItem(value: 'مرد', child: Text('مرد'))], onChanged: (v) => setState(() => gender = v ?? 'زن')),
      const SizedBox(height: 12),
      Card(child: ListTile(title: const Text('تاریخ تولد'), subtitle: Text(dateFormat.format(birth)), trailing: const Icon(Icons.calendar_month), onTap: pickBirth)),
      const SizedBox(height: 12),
      const Text('بیماری یا شرایط مهم', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 4, children: conditionOptions.map((x) => FilterChip(label: Text(x), selected: selected.contains(x), onSelected: (v) => setState(() => v ? selected.add(x) : selected.remove(x)))).toList()),
      const SizedBox(height: 8),
      SwitchListTile(title: const Text('بارداری'), value: pregnant, onChanged: gender == 'زن' ? (v) => setState(() => pregnant = v) : null),
      if (pregnant) Card(child: ListTile(title: const Text('تاریخ شروع/آخرین قاعدگی'), subtitle: Text(pregStart == null ? 'انتخاب نشده' : dateFormat.format(pregStart!)), trailing: const Icon(Icons.calendar_month), onTap: () async {
        final d = await showDatePicker(context: context, initialDate: pregStart ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 300)), lastDate: DateTime.now());
        if (d != null) setState(() => pregStart = d);
      })),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: () {
        if (first.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً نام را وارد کنید.')));
          return;
        }
        Navigator.pop(context, Person(id: widget.person?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), firstName: first.text.trim(), lastName: last.text.trim(), gender: gender, birthDate: birth, createdAt: widget.person?.createdAt, conditions: selected.toList(), pregnant: pregnant, pregnancyStartDate: pregStart));
      }, icon: const Icon(Icons.save), label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('ذخیره اطلاعات')))
    ]),
  ));
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: const [
    Icon(Icons.health_and_safety, size: 72),
    SizedBox(height: 12),
    Center(child: Text('پزشک خانواده', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
    SizedBox(height: 18),
    Card(child: Padding(padding: EdgeInsets.all(18), child: Text('یک دستیار ساده برای ثبت اعضای خانواده، یادآوری مراقبت‌ها و مشاهده موارد پیش‌رو.'))),
    SizedBox(height: 12),
    Card(child: Padding(padding: EdgeInsets.all(18), child: Text('اطلاعات سلامت روی دستگاه ذخیره می‌شود. برای تصمیم‌های تشخیصی یا درمانی، از پزشک و منابع رسمی و به‌روز استفاده کنید.')))
  ]);
}

int _age(DateTime birth) {
  final now = DateTime.now();
  var age = now.year - birth.year;
  if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) age--;
  return age < 0 ? 0 : age;
}
