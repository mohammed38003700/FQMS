
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class CapaScreen extends StatefulWidget {
  const CapaScreen({super.key});

  @override
  State<CapaScreen> createState() => _CapaScreenState();
}

class _CapaScreenState extends State<CapaScreen> {
  final formKey = GlobalKey<FormState>();

  final departmentController = TextEditingController();
  final descriptionController = TextEditingController();
  final rootCauseController = TextEditingController();
  final correctiveController = TextEditingController();
  final preventiveController = TextEditingController();
  final responsibleController = TextEditingController();

  String severity = 'متوسطة';
  String status = 'مفتوحة';
  bool saving = false;

  @override
  void dispose() {
    departmentController.dispose();
    descriptionController.dispose();
    rootCauseController.dispose();
    correctiveController.dispose();
    preventiveController.dispose();
    responsibleController.dispose();
    super.dispose();
  }

  Future<void> saveDeviation() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      await DatabaseHelper.instance.insertDeviation({
        'description':
            'القسم: ${departmentController.text}\n'
            'المخالفة: ${descriptionController.text}\n'
            'درجة الخطورة: $severity\n'
            'السبب الجذري: ${rootCauseController.text}\n'
            'الإجراء الوقائي: ${preventiveController.text}\n'
            'المسؤول: ${responsibleController.text}',
        'corrective_action': correctiveController.text,
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ تقرير عدم المطابقة بنجاح'),
        ),
      );

      formKey.currentState!.reset();

      departmentController.clear();
      descriptionController.clear();
      rootCauseController.clear();
      correctiveController.clear();
      preventiveController.clear();
      responsibleController.clear();

      setState(() {
        severity = 'متوسطة';
        status = 'مفتوحة';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('عدم المطابقة و CAPA'),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تسجيل حالة عدم مطابقة',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                buildField('القسم', departmentController),
                buildField(
                  'وصف المخالفة',
                  descriptionController,
                  lines: 3,
                ),
                buildField(
                  'السبب الجذري',
                  rootCauseController,
                  lines: 3,
                ),
                buildField(
                  'الإجراء التصحيحي',
                  correctiveController,
                  lines: 3,
                ),
                buildField(
                  'الإجراء الوقائي',
                  preventiveController,
                  lines: 3,
                ),
                buildField('المسؤول عن التنفيذ', responsibleController),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: severity,
                  decoration: const InputDecoration(
                    labelText: 'درجة الخطورة',
                    border: OutlineInputBorder(),
                  ),
                  items: ['منخفضة', 'متوسطة', 'عالية', 'حرجة']
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => severity = v);
                  },
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'حالة الإجراء',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'مفتوحة',
                    'قيد التنفيذ',
                    'بانتظار التحقق',
                    'مغلقة',
                  ].map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      )).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => status = v);
                  },
                ),

                const SizedBox(height: 22),

                ElevatedButton.icon(
                  onPressed: saving ? null : saveDeviation,
                  icon: const Icon(Icons.save),
                  label: Text(
                    saving ? 'جارٍ الحفظ...' : 'حفظ تقرير عدم المطابقة',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
