// lib/screens/log_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_log.dart';
import '../providers/health_provider.dart';
import '../theme/app_colors.dart';

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
    _notesCtrl = TextEditingController(text: widget.initialLog?.notes ?? '');
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _addWater(int amount) {
    final current = int.tryParse(_waterCtrl.text.trim()) ?? 0;
    _waterCtrl.text = (current + amount).toString();
    setState(() {});
  }

  void _setWater(int amount) {
    _waterCtrl.text = amount.toString();
    setState(() {});
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
              ? '✅ Log updated successfully!'
              : '✅ Health log saved successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${provider.errorLogs ?? "An error occurred"}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<HealthProvider>().isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    isEdit ? 'Edit Log' : 'Add Daily Log',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Date Card
              _buildSectionCard(
                title: 'Log Date',
                icon: Icons.calendar_month_rounded,
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          _date.toIso8601String().split('T').first,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Water Intake Card
              _buildSectionCard(
                title: 'Water Intake (ml)',
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF0288D1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _waterCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'e.g. 2000',
                        suffixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          child: const Text(
                            'ml',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        prefixIcon: const Icon(Icons.local_drink_rounded, color: Color(0xFF0288D1)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'This field is required';
                        final n = int.tryParse(v.trim());
                        if (n == null) return 'Must be a valid integer';
                        if (n < 0) return 'Cannot be negative';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Quick Presets:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildWaterChip(label: '+250 ml (Glass)', onTap: () => _addWater(250)),
                        _buildWaterChip(label: '+500 ml (Bottle)', onTap: () => _addWater(500)),
                        _buildWaterChip(label: 'Goal (2000 ml)', onTap: () => _setWater(2000)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. Weight Card
              _buildSectionCard(
                title: 'Body Weight',
                icon: Icons.monitor_weight_rounded,
                iconColor: AppColors.coral,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'e.g. 55.5',
                        suffixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          child: const Text(
                            'kg',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        prefixIcon: const Icon(Icons.scale_rounded, color: AppColors.coral),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = double.tryParse(v.trim());
                        if (n == null) return 'Must be a valid decimal number';
                        if (n <= 0) return 'Must be greater than 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Leave empty if you did not weigh yourself today.',
                      style: TextStyle(fontSize: 11, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. Notes Card
              _buildSectionCard(
                title: 'Daily Notes (Optional)',
                icon: Icons.note_alt_rounded,
                child: TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Log your meals, workouts, or how you feel today...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.edit_note_rounded, color: AppColors.textLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : _submit,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 22, color: Colors.white),
                  label: Text(
                    isSaving
                        ? 'Saving...'
                        : (isEdit ? 'Save Changes' : 'Save Log'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Color iconColor = AppColors.primary,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildWaterChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE1F5FE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF81D4FA)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0288D1),
          ),
        ),
      ),
    );
  }
}
