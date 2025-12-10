import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;
  bool _autoBackupEnabled = true;
  DateTime? _lastBackupTime;
  List<BackupItem> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement backup loading from storage
      _lastBackupTime = DateTime.now().subtract(const Duration(hours: 2));
      _backups = [
        BackupItem(
          name: 'Backup - 2025-12-10 14:03',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          size: '2.5 MB',
          version: '1.0',
        ),
        BackupItem(
          name: 'Backup - 2025-12-09 10:30',
          date: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
          size: '2.3 MB',
          version: '1.0',
        ),
        BackupItem(
          name: 'Backup - 2025-12-08 08:15',
          date: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
          size: '2.1 MB',
          version: '1.0',
        ),
      ];
    } catch (e) {
      _showErrorSnackBar('Failed to load backups: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement backup creation logic
      await Future.delayed(const Duration(seconds: 2));
      
      final newBackup = BackupItem(
        name: 'Backup - ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
        date: DateTime.now(),
        size: '2.5 MB',
        version: '1.0',
      );

      setState(() {
        _backups.insert(0, newBackup);
        _lastBackupTime = DateTime.now();
      });

      _showSuccessSnackBar('Backup created successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to create backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBackup(BackupItem backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: Text(
          'Are you sure you want to restore from "${backup.name}"?\n\n'
          'This will overwrite your current data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      // TODO: Implement restore logic
      await Future.delayed(const Duration(seconds: 2));
      _showSuccessSnackBar('Backup restored successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to restore backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBackup(BackupItem backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup?'),
        content: Text('Are you sure you want to delete "${backup.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      // TODO: Implement delete logic
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _backups.remove(backup));
      _showSuccessSnackBar('Backup deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Management'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auto Backup Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Auto Backup Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Enable Auto Backup'),
                                  SizedBox(height: 4),
                                  Text(
                                    'Daily at 2:00 AM',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _autoBackupEnabled,
                                onChanged: (value) {
                                  setState(() => _autoBackupEnabled = value);
                                  // TODO: Implement auto backup toggle
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Last Backup Info
                  if (_lastBackupTime != null)
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.backup, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Last Backup',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM d, yyyy - HH:mm').format(
                                      _lastBackupTime!,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Create Backup Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createBackup,
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Backup'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Backups List
                  const Text(
                    'Backup History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBackupsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildBackupsList() {
    if (_backups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(
                Icons.backup_table,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                'No backups yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _backups.length,
      itemBuilder: (context, index) {
        final backup = _backups[index];
        return _buildBackupItem(backup);
      },
    );
  }

  Widget _buildBackupItem(BackupItem backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.backup_table, color: Colors.blue),
        title: Text(backup.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy - HH:mm').format(backup.date),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              backup.size,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => _restoreBackup(backup),
              child: const Row(
                children: [
                  Icon(Icons.restore, size: 20),
                  SizedBox(width: 12),
                  Text('Restore'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => _deleteBackup(backup),
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackupItem {
  final String name;
  final DateTime date;
  final String size;
  final String version;

  BackupItem({
    required this.name,
    required this.date,
    required this.size,
    required this.version,
  });
}
