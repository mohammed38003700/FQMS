
import 'package:flutter/material.dart';

void main() {
  runApp(const FQMSApp());
}

class FQMSApp extends StatelessWidget {
  const FQMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FQMS',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  final List<Map<String, dynamic>> modules = const [
    {'name': 'متابعة الإنتاج', 'icon': Icons.factory},
    {'name': 'المختبر', 'icon': Icons.science},
    {'name': 'نظام CIP', 'icon': Icons.water_drop},
    {'name': 'عدم المطابقة', 'icon': Icons.warning},
    {'name': 'التدقيق', 'icon': Icons.fact_check},
    {'name': 'التحميل والتخزين', 'icon': Icons.local_shipping},
    {'name': 'التقارير', 'icon': Icons.bar_chart},
    {'name': 'الإعدادات', 'icon': Icons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FQMS | إدارة الجودة'),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue.shade800,
                child: const ListTile(
                  leading: Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 36,
                  ),
                  title: Text(
                    'نظام إدارة الجودة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'مراقبة جودة الإنتاج وسلامة الغذاء',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'الأقسام الرئيسية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: modules.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final item = modules[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'قسم ${item['name']} قيد التطوير',
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 38,
                              color: Colors.blue.shade800,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
