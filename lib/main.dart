
import 'package:flutter/material.dart';

import 'screens/lab_screen.dart';
import 'screens/cip_screen.dart';
import 'screens/capa_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'name': 'متابعة الإنتاج',
        'icon': Icons.precision_manufacturing,
        'screen': null,
      },
      {
        'name': 'المختبر',
        'icon': Icons.science,
        'screen': const LabScreen(),
      },
      {
        'name': 'نظام CIP',
        'icon': Icons.water_drop,
        'screen': const CipScreen(),
      },
      {
        'name': 'عدم المطابقة و CAPA',
        'icon': Icons.warning,
        'screen': const CapaScreen(),
      },
      {
        'name': 'التدقيق',
        'icon': Icons.fact_check,
        'screen': null,
      },
      {
        'name': 'التحميل والتخزين',
        'icon': Icons.local_shipping,
        'screen': null,
      },
      {
        'name': 'التقارير',
        'icon': Icons.bar_chart,
        'screen': null,
      },
      {
        'name': 'الإعدادات',
        'icon': Icons.settings,
        'screen': null,
      },
    ];

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
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final item = modules[index];

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          final screen = item['screen'];

                          if (screen is Widget) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => screen,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'قسم ${item['name']} قيد التطوير',
                                ),
                              ),
                            );
                          }
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                item['name'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
