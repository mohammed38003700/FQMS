
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DeviationsScreen extends StatefulWidget {
  const DeviationsScreen({super.key});

  @override
  State<DeviationsScreen> createState() => _DeviationsScreenState();
}

class _DeviationsScreenState extends State<DeviationsScreen> {
  final formKey = GlobalKey<FormState>();

  final descriptionController = TextEditingController();
  final actionController = TextEditingController();

  String status = 'مفتوحة';
  bool saving = false;

  @override
  void dispose() {
    descriptionController.dispose();
    actionController.dispose();
    super.dispose();
  }

  Future<void> saveDeviation() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      await DatabaseHelper.instance.insertDeviation({
        'description': descriptionController.text.trim(),
        'corrective_action': actionController.text.trim(),
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      descriptionController.clear();
      actionController.clear();

      setState(() {
        status = 'مفتوحة';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل حالة عدم المطابقة بنجاح'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحفظ: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل عدم المطابقة'),
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
                const SizedBox(height: 20),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'وصف حالة عدم المطابقة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة وصف الحالة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: actionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'الإجراء التصحيحي',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'حالة المعالجة',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'مفتوحة',
                      child: Text('مفتوحة'),
                    ),
                    DropdownMenuItem(
                      value: 'قيد التنفيذ',
                      child: Text('قيد التنفيذ'),
                    ),
                    DropdownMenuItem(
                      value: 'بانتظار التحقق',
                      child: Text('بانتظار التحقق'),
                    ),
                    DropdownMenuItem(
                      value: 'مغلقة',
                      child: Text('مغلقة'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => status = value);
                    }
                  },
                ),

                const SizedBox(height: 22),

                ElevatedButton.icon(
                  onPressed: saving ? null : saveDeviation,
                  icon: const Icon(Icons.save),
                  label: Text(
                    saving ? 'جارٍ الحفظ...' : 'حفظ الحالة',
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
