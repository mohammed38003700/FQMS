
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final formKey = GlobalKey<FormState>();

  final productController = TextEditingController();
  final batchController = TextEditingController();
  final tankController = TextEditingController();
  final temperatureController = TextEditingController();
  final durationController = TextEditingController();
  final operatorController = TextEditingController();
  final notesController = TextEditingController();

  String department = 'الآيس كريم';
  String stage = 'الخلط';
  String resultStatus = 'مطابق';
  bool saving = false;

  final departments = [
    'الآيس كريم',
    'الألبان',
    'العصائر',
  ];

  final stages = [
    'الخلط',
    'البسترة',
    'التجنيس',
    'التبريد',
    'التجميد',
    'التعبئة',
    'التحميل',
  ];

  @override
  void dispose() {
    productController.dispose();
    batchController.dispose();
    tankController.dispose();
    temperatureController.dispose();
    durationController.dispose();
    operatorController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Widget textField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool requiredField = true,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (requiredField &&
              (value == null || value.trim().isEmpty)) {
            return 'يرجى إدخال $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> saveProductionRecord() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      await DatabaseHelper.instance.insertRecord({
        'department': 'الإنتاج - $department',
        'product': productController.text.trim(),
        'test_name': 'مرحلة الإنتاج: $stage',
        'result':
            'رقم التشغيلة: ${batchController.text}\n'
            'الخزان: ${tankController.text}\n'
            'درجة الحرارة: ${temperatureController.text}\n'
            'المدة: ${durationController.text}\n'
            'حالة الفحص: $resultStatus\n'
            'المشغل: ${operatorController.text}',
        'notes': notesController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ سجل الإنتاج بنجاح'),
        ),
      );

      formKey.currentState!.reset();

      productController.clear();
      batchController.clear();
      tankController.clear();
      temperatureController.clear();
      durationController.clear();
      operatorController.clear();
      notesController.clear();

      setState(() {
        department = 'الآيس كريم';
        stage = 'الخلط';
        resultStatus = 'مطابق';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحفظ: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget dropdownField(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: options.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('متابعة الإنتاج'),
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
                  'بيانات مرحلة الإنتاج',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                dropdownField(
                  'خط الإنتاج',
                  department,
                  departments,
                  (v) => setState(() => department = v!),
                ),

                textField('اسم المنتج', productController),
                textField('رقم التشغيلة', batchController),
                textField('رقم الخزان أو المعدة', tankController),

                dropdownField(
                  'مرحلة الإنتاج',
                  stage,
                  stages,
                  (v) => setState(() => stage = v!),
                ),

                textField(
                  'درجة الحرارة',
                  temperatureController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                ),

                textField(
                  'المدة بالدقائق',
                  durationController,
                  keyboardType: TextInputType.number,
                ),

                textField('اسم المشغل', operatorController),

                dropdownField(
                  'نتيجة الفحص الأولية',
                  resultStatus,
                  ['مطابق', 'غير مطابق', 'قيد التحقق'],
                  (v) => setState(() => resultStatus = v!),
                ),

                textField(
                  'ملاحظات مراقب الجودة',
                  notesController,
                  requiredField: false,
                  lines: 3,
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: saving ? null : saveProductionRecord,
                  icon: const Icon(Icons.save),
                  label: Text(
                    saving ? 'جارٍ الحفظ...' : 'حفظ سجل الإنتاج',
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
