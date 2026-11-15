
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int productionCount = 0;
  int laboratoryCount = 0;
  int cipCount = 0;
  int deviationCount = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    setState(() => loading = true);

    try {
      final records = await DatabaseHelper.instance.getRecords();
      final deviations =
          await DatabaseHelper.instance.getDeviations();

      if (!mounted) return;

      setState(() {
        productionCount = records
            .where((r) =>
                (r['department'] ?? '').toString().contains('الإنتاج'))
            .length;

        laboratoryCount = records
            .where((r) =>
                (r['department'] ?? '').toString().contains('Laboratory'))
            .length;

        cipCount = records
            .where((r) =>
                (r['department'] ?? '').toString().contains('CIP'))
            .length;

        deviationCount = deviations.length;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحميل التقارير: $e')),
      );
    }
  }

  Widget statisticCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: color),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير والإحصائيات'),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: loadStatistics,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadStatistics,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'ملخص سجلات الجودة',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        statisticCard(
                          'سجلات الإنتاج',
                          productionCount,
                          Icons.factory,
                          Colors.blue,
                        ),
                        statisticCard(
                          'فحوصات المختبر',
                          laboratoryCount,
                          Icons.science,
                          Colors.green,
                        ),
                        statisticCard(
                          'سجلات CIP',
                          cipCount,
                          Icons.water_drop,
                          Colors.teal,
                        ),
                        statisticCard(
                          'حالات عدم المطابقة',
                          deviationCount,
                          Icons.warning,
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        title: Text('معلومات التقرير'),
                        subtitle: Text(
                          'تعرض هذه الشاشة أعداد السجلات '
                          'المحفوظة محلياً في الجهاز. '
                          'لا تمثل الأعداد حكماً على مطابقة '
                          'المنتجات أو سلامة الغذاء.',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
