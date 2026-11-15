
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  final _formKey = GlobalKey<FormState>();

  final productController = TextEditingController();
  final tankController = TextEditingController();
  final fatController = TextEditingController();
  final solidsController = TextEditingController();
  final densityController = TextEditingController();
  final viscosityController = TextEditingController();
  final notesController = TextEditingController();

  bool saving = false;

  Future<void> saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      await DatabaseHelper.instance.insertRecord({
        'department': 'Laboratory',
        'product': productController.text.trim(),
        'test_name':
            'Tank ${tankController.text} | Fat ${fatController.text}%',
        'result':
            'Solids: ${solidsController.text}, Density: ${densityController.text}, Viscosity: ${viscosityController.text}',
        'notes': notesController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ نتيجة الفحص بنجاح'),
        ),
      );

      _formKey.currentState!.reset();

      for (final controller in [
        productController,
        tankController,
        fatController,
        solidsController,
        densityController,
        viscosityController,
        notesController,
      ]) {
        controller.clear();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget field(
    String label,
    TextEditingController controller, {
    bool numeric = false,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
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
  void dispose() {
    productController.dispose();
    tankController.dispose();
    fatController.dispose();
    solidsController.dispose();
    densityController.dispose();
    viscosityController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفحوصات المخبرية'),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تسجيل نتائج المختبر',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                field('اسم المنتج', productController),
                field('رقم الخزان', tankController),
                field('نسبة الدهون', fatController,
                    numeric: true, suffix: '%'),
                field('المواد الصلبة الكلية', solidsController,
                    numeric: true, suffix: '%'),
                field('الكثافة', densityController, numeric: true),
                field('اللزوجة', viscosityController, numeric: true),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات مراقب الجودة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: saving ? null : saveRecord,
                  icon: const Icon(Icons.save),
                  label: Text(saving ? 'جارٍ الحفظ...' : 'حفظ نتيجة الفحص'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
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
