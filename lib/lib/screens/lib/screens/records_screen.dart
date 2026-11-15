
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<Map<String, dynamic>> records = [];
  bool loading = true;

  String selectedDepartment = 'الكل';

  final filters = [
    'الكل',
    'الإنتاج',
    'المختبر',
    'CIP',
  ];

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    setState(() => loading = true);

    try {
      final data = await DatabaseHelper.instance.getRecords();

      if (!mounted) return;

      setState(() {
        records = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل السجلات: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredRecords {
    if (selectedDepartment == 'الكل') {
      return records;
    }

    return records.where((record) {
      final department =
          (record['department'] ?? '').toString();

      if (selectedDepartment == 'الإنتاج') {
        return department.contains('الإنتاج');
      }

      if (selectedDepartment == 'المختبر') {
        return department.contains('Laboratory');
      }

      if (selectedDepartment == 'CIP') {
        return department.contains('CIP');
      }

      return false;
    }).toList();
  }

  String formatDate(dynamic value) {
    if (value == null) return '';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return value.toString();

    return '${date.year}/${date.month}/${date.day} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record['product']?.toString() ?? 'سجل'),
        content: SingleChildScrollView(
          child: SelectableText(
            'القسم: ${record['department']}\n\n'
            'الاختبار أو المرحلة: ${record['test_name']}\n\n'
            'النتيجة:\n${record['result']}\n\n'
            'الملاحظات:\n${record['notes'] ?? '-'}\n\n'
            'التاريخ: ${formatDate(record['created_at'])}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleRecords = filteredRecords;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل العمليات'),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: loadRecords,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'تصفية السجلات',
                  border: OutlineInputBorder(),
                ),
                items: filters.map((filter) {
                  return DropdownMenuItem(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedDepartment = value);
                  }
                },
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : visibleRecords.isEmpty
                      ? const Center(
                          child: Text('لا توجد سجلات محفوظة'),
                        )
                      : ListView.builder(
                          itemCount: visibleRecords.length,
                          itemBuilder: (context, index) {
                            final record = visibleRecords[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.assignment),
                                ),
                                title: Text(
                                  record['product']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${record['department']}\n'
                                  '${record['test_name']}\n'
                                  '${formatDate(record['created_at'])}',
                                ),
                                isThreeLine: true,
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () => showRecordDetails(record),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
