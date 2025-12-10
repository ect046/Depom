import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Service for handling backup operations
class BackupService {
  static const String _backupDirectory = 'backups';
  static const String _backupFileExtension = '.backup.json';
  
  /// Create a backup of the given data
  /// 
  /// [data] - The data to be backed up
  /// [backupName] - Optional custom backup name
  /// 
  /// Returns the path of the created backup file
  Future<String> createBackup(Map<String, dynamic> data, {String? backupName}) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDocDir.path}/$_backupDirectory');
      
      // Create backup directory if it doesn't exist
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // Generate backup filename with timestamp
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final fileName = backupName ?? 'backup_$timestamp';
      final backupFile = File('${backupDir.path}/$fileName$_backupFileExtension');
      
      // Encode data to JSON and write to file
      final jsonData = jsonEncode(data);
      await backupFile.writeAsString(jsonData);
      
      return backupFile.path;
    } catch (e) {
      throw BackupException('Failed to create backup: $e');
    }
  }
  
  /// Restore data from a backup file
  /// 
  /// [backupPath] - Path to the backup file
  /// 
  /// Returns the restored data as a Map
  Future<Map<String, dynamic>> restoreBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      if (!await backupFile.exists()) {
        throw BackupException('Backup file not found: $backupPath');
      }
      
      final jsonString = await backupFile.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return data;
    } catch (e) {
      throw BackupException('Failed to restore backup: $e');
    }
  }
  
  /// List all available backups
  /// 
  /// Returns a list of backup file paths
  Future<List<String>> listBackups() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDocDir.path}/$_backupDirectory');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final backups = backupDir
          .listSync()
          .where((entity) => entity is File && entity.path.endsWith(_backupFileExtension))
          .map((entity) => entity.path)
          .toList();
      
      return backups;
    } catch (e) {
      throw BackupException('Failed to list backups: $e');
    }
  }
  
  /// Delete a specific backup
  /// 
  /// [backupPath] - Path to the backup file to delete
  Future<void> deleteBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      if (!await backupFile.exists()) {
        throw BackupException('Backup file not found: $backupPath');
      }
      
      await backupFile.delete();
    } catch (e) {
      throw BackupException('Failed to delete backup: $e');
    }
  }
  
  /// Delete all backups
  Future<void> deleteAllBackups() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDocDir.path}/$_backupDirectory');
      
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
    } catch (e) {
      throw BackupException('Failed to delete all backups: $e');
    }
  }
  
  /// Get backup file information
  /// 
  /// [backupPath] - Path to the backup file
  /// 
  /// Returns a BackupInfo object with metadata
  Future<BackupInfo> getBackupInfo(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      if (!await backupFile.exists()) {
        throw BackupException('Backup file not found: $backupPath');
      }
      
      final stat = await backupFile.stat();
      final fileName = backupFile.path.split('/').last;
      
      return BackupInfo(
        name: fileName,
        path: backupPath,
        size: stat.size,
        modified: stat.modified,
      );
    } catch (e) {
      throw BackupException('Failed to get backup info: $e');
    }
  }
  
  /// Verify backup integrity
  /// 
  /// [backupPath] - Path to the backup file to verify
  /// 
  /// Returns true if backup is valid, false otherwise
  Future<bool> verifyBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      if (!await backupFile.exists()) {
        return false;
      }
      
      final jsonString = await backupFile.readAsString();
      jsonDecode(jsonString);
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for backup operations
class BackupException implements Exception {
  final String message;
  
  BackupException(this.message);
  
  @override
  String toString() => 'BackupException: $message';
}

/// Information about a backup file
class BackupInfo {
  final String name;
  final String path;
  final int size;
  final DateTime modified;
  
  BackupInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
  });
  
  /// Get formatted size string
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
  
  /// Get formatted modified time
  String get formattedModified {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(modified);
  }
  
  @override
  String toString() => 'BackupInfo(name: $name, size: $formattedSize, modified: $formattedModified)';
}
