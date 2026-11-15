
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class CipScreen extends StatefulWidget {
  const CipScreen({super.key});

  @override
  State<CipScreen> createState() => _CipScreenState();
}

class _CipScreenState extends State<CipScreen> {
  final formKey = GlobalKey<FormState>();

  final equipment = TextEditingController();
  final solution = TextEditingController();
  final concentration = TextEditingController();
  final temperature = TextEditingController();
  final duration = TextEditingController();
  final operator = TextEditingController();
  final notes = TextEditingController();

  String verification = 'مطابق';

  bool saving = false;

  Future<void> saveCip() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      await DatabaseHelper.instance.insertRecord({
        'department': 'CIP',
        'product': equipment.text.trim(),
        'test_name': solution.text.trim(),
        'result':
            'Concentration: ${concentration.text} | Temperature: ${temperature.text} | Duration: ${duration.text} minutes | Verification: $verification | Operator: ${operator.text}',
        'notes': notes.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل عملية CIP بنجاح')),
      );

      formKey.currentState!.reset();

      for (final c in [
        equipment,
        solution,
        concentration,
        temperature,
        duration,
        operator,
        notes,
      ]) {
        c.clear();
      }

      setState(() => verification = 'مطابق');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحفظ: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget input(
    String label,
    TextEditingController controller, {
    bool numeric = false,
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
          border: const OutlineInputBorder(),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }

  @override
  void dispose() {
    equipment.dispose();
    solution.dispose();
    concentration.dispose();
    temperature.dispose();
    duration.dispose();
    operator.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('متابعة عمليات CIP'),
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
                  'تسجيل دورة التنظيف',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                input('اسم الخزان أو خط الإنتاج', equipment),
                input('نوع محلول التنظيف', solution),
                input('تركيز المحلول (%)', concentration, numeric: true),
                input('درجة حرارة المحلول (°C)', temperature, numeric: true),
                input('مدة التنظيف (دقيقة)', duration, numeric: true),
                input('اسم المسؤول', operator),
                DropdownButtonFormField<String>(
                  value: verification,
                  decoration: const InputDecoration(
                    labelText: 'نتيجة التحقق',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'مطابق',
                      child: Text('مطابق'),
                    ),
                    DropdownMenuItem(
                      value: 'غير مطابق',
                      child: Text('غير مطابق'),
                    ),
                    DropdownMenuItem(
                      value: 'قيد التحقق',
                      child: Text('قيد التحقق'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => verification = v);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات الجودة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: saving ? null : saveCip,
                  icon: const Icon(Icons.save),
                  label: Text(saving ? 'جارٍ الحفظ...' : 'حفظ سجل CIP'),
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
