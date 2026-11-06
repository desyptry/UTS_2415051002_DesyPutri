import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../widgets/error_view.dart';
import 'log_form_screen.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();

    if (health.isLoadingLogs) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading history...')]));
    }
    if (health.errorLogs != null) {
      return ErrorView(message: health.errorLogs!, onRetry: () => context.read<HealthProvider>().loadLogs());
    }
    if (health.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No logs yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Add your first log!', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const LogFormScreen())); },
              icon: const Icon(Icons.add),
              label: const Text('Add Log'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: health.logs.length,
        itemBuilder: (context, index) {
          final log = health.logs[index];
          return _buildLogCard(context, log, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const LogFormScreen())); },
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, dynamic log, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(log.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => LogFormScreen(initialLog: log))); }),
                IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _confirmDelete(context, log, index)),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text('${log.waterMl} ml'),
                const SizedBox(width: 16),
                const Icon(Icons.monitor_weight, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(log.weightKg != null ? '${log.weightKg} kg' : '-'),
              ],
            ),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${log.notes}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, dynamic log, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Log?'),
        content: Text('Log for "${log.date}" will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final success = await context.read<HealthProvider>().deleteLog(log.id!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Log deleted!' : 'Failed to delete'), backgroundColor: success ? Colors.green : Colors.red));
    }
  }
}