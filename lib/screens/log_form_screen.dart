import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_log.dart';
import '../providers/health_provider.dart';

class LogFormScreen extends StatefulWidget {
  final DailyLog? initialLog;
  const LogFormScreen({super.key, this.initialLog});

  @override
  State<LogFormScreen> createState() => _LogFormScreenState();
}

class _LogFormScreenState extends State<LogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _waterCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _date;

  bool get isEdit => widget.initialLog != null;

  @override
  void initState() {
    super.initState();
    _date = widget.initialLog != null
        ? DateTime.parse(widget.initialLog!.date)
        : DateTime.now();
    _waterCtrl = TextEditingController(
        text: widget.initialLog?.waterMl.toString() ?? '');
    _weightCtrl = TextEditingController(
        text: widget.initialLog?.weightKg?.toString() ?? '');
    _notesCtrl =
        TextEditingController(text: widget.initialLog?.notes ?? '');
  }

  @override
  void dispose() {
    _waterCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final log = DailyLog(
      date: _date.toIso8601String().split('T').first,
      waterMl: int.parse(_waterCtrl.text.trim()),
      weightKg: _weightCtrl.text.trim().isEmpty
          ? null
          : double.parse(_weightCtrl.text.trim()),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final provider = context.read<HealthProvider>();
    final success = isEdit
        ? await provider.updateLog(widget.initialLog!.id!, log)
        : await provider.createLog(log);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Log successfully updated!'
              : 'Log successfully added!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${provider.errorLogs ?? "Unknown"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<HealthProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Log' : 'Add Log'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Date',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_date.toIso8601String().split('T').first),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Water Intake (ml)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _waterCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Example: 2000',
                  suffixText: 'ml',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(v.trim());
                  if (n == null) return 'Harus angka';
                  if (n < 0) return 'Tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Weight (kg)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Example: 55.5 (optional)',
                  suffixText: 'kg',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = double.tryParse(v.trim());
                  if (n == null) return 'Harus angka';
                  if (n <= 0) return 'Harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Notes (optional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Example notes...',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : _submit,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(isSaving ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
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