import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Backup state model
class BackupState {
  final bool isBackingUp;
  final bool isRestoring;
  final DateTime? lastBackupTime;
  final String? lastBackupStatus;
  final int? backupItemCount;
  final String? errorMessage;

  BackupState({
    this.isBackingUp = false,
    this.isRestoring = false,
    this.lastBackupTime,
    this.lastBackupStatus,
    this.backupItemCount,
    this.errorMessage,
  });

  BackupState copyWith({
    bool? isBackingUp,
    bool? isRestoring,
    DateTime? lastBackupTime,
    String? lastBackupStatus,
    int? backupItemCount,
    String? errorMessage,
  }) {
    return BackupState(
      isBackingUp: isBackingUp ?? this.isBackingUp,
      isRestoring: isRestoring ?? this.isRestoring,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      lastBackupStatus: lastBackupStatus ?? this.lastBackupStatus,
      backupItemCount: backupItemCount ?? this.backupItemCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Backup state notifier
class BackupNotifier extends StateNotifier<BackupState> {
  final FirebaseFirestore _firestore;

  BackupNotifier(this._firestore) : super(BackupState());

  /// Start backup process
  Future<void> startBackup() async {
    state = state.copyWith(isBackingUp: true, errorMessage: null);
    try {
      // Perform backup operations here
      final timestamp = DateTime.now().toUtc();
      state = state.copyWith(
        isBackingUp: false,
        lastBackupTime: timestamp,
        lastBackupStatus: 'Success',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isBackingUp: false,
        lastBackupStatus: 'Failed',
        errorMessage: e.toString(),
      );
    }
  }

  /// Start restore process
  Future<void> startRestore() async {
    state = state.copyWith(isRestoring: true, errorMessage: null);
    try {
      // Perform restore operations here
      state = state.copyWith(
        isRestoring: false,
        lastBackupStatus: 'Restored',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isRestoring: false,
        lastBackupStatus: 'Restore Failed',
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset backup state
  void reset() {
    state = BackupState();
  }
}

/// Backup provider
final backupProvider = StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  final firestore = FirebaseFirestore.instance;
  return BackupNotifier(firestore);
});
