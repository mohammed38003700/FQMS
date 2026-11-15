
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DeviationsScreen extends StatefulWidget {
  const DeviationsScreen({super.key});

  @override
  State<DeviationsScreen> createState() =>
      _DeviationsScreenState();
}

class _DeviationsScreenState extends State<DeviationsScreen> {
  List<Map<String, dynamic>> deviations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDeviations();
  }

  Future<void> loadDeviations() async {
    setState(() => loading = true);

    try {
      final data =
          await DatabaseHelper.instance.getDeviations();

      if (!mounted) return;

      setState(() {
        deviations = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
      );
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'مغلقة':
        return Colors.green;
      case 'قيد التنفيذ':
        return Colors.orange;
      case 'بانتظار التحقق':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل عدم المطابقة و CAPA'),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: loadDeviations,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : deviations.isEmpty
                ? const Center(
                    child: Text('لا توجد حالات عدم مطابقة مسجلة'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: deviations.length,
                    itemBuilder: (context, index) {
                      final item = deviations[index];
                      final status =
                          item['status']?.toString() ?? 'مفتوحة';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.warning_amber),
                          ),
                          title: Text(
                            'حالة عدم مطابقة رقم ${item['id']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['description']?.toString() ?? '',
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'الإجراء التصحيحي: '
                                  '${item['corrective_action'] ?? '-'}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'الحالة: $status',
                                  style: TextStyle(
                                    color: statusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isThreeLine: true,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'حالة عدم المطابقة رقم ${item['id']}',
                                ),
                                content: SingleChildScrollView(
                                  child: SelectableText(
                                    'الوصف:\n'
                                    '${item['description']}\n\n'
                                    'الإجراء التصحيحي:\n'
                                    '${item['corrective_action']}\n\n'
                                    'الحالة: $status\n\n'
                                    'التاريخ: ${item['created_at']}',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text('إغلاق'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
