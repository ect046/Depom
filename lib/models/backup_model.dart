class BackupModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final int sizeInBytes;
  final BackupStatus status;
  final BackupType type;
  final String? location;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final bool isEncrypted;
  final String? encryptionAlgorithm;
  final int? retentionDays;
  final bool isAutomatic;
  final String? sourceInfo;

  BackupModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.modifiedAt,
    required this.sizeInBytes,
    required this.status,
    required this.type,
    this.location,
    this.tags = const [],
    this.metadata,
    this.isEncrypted = false,
    this.encryptionAlgorithm,
    this.retentionDays,
    this.isAutomatic = false,
    this.sourceInfo,
  });

  /// Convert BackupModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt?.toIso8601String(),
        'sizeInBytes': sizeInBytes,
        'status': status.toJson(),
        'type': type.toString().split('.').last,
        'location': location,
        'tags': tags,
        'metadata': metadata,
        'isEncrypted': isEncrypted,
        'encryptionAlgorithm': encryptionAlgorithm,
        'retentionDays': retentionDays,
        'isAutomatic': isAutomatic,
        'sourceInfo': sourceInfo,
      };

  /// Create BackupModel from JSON
  factory BackupModel.fromJson(Map<String, dynamic> json) => BackupModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: json['modifiedAt'] != null
            ? DateTime.parse(json['modifiedAt'] as String)
            : null,
        sizeInBytes: json['sizeInBytes'] as int,
        status: BackupStatus.fromJson(json['status'] as Map<String, dynamic>),
        type: BackupType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => BackupType.full,
        ),
        location: json['location'] as String?,
        tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
        metadata: json['metadata'] as Map<String, dynamic>?,
        isEncrypted: json['isEncrypted'] as bool? ?? false,
        encryptionAlgorithm: json['encryptionAlgorithm'] as String?,
        retentionDays: json['retentionDays'] as int?,
        isAutomatic: json['isAutomatic'] as bool? ?? false,
        sourceInfo: json['sourceInfo'] as String?,
      );

  /// Create a copy with optional parameter updates
  BackupModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? sizeInBytes,
    BackupStatus? status,
    BackupType? type,
    String? location,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isEncrypted,
    String? encryptionAlgorithm,
    int? retentionDays,
    bool? isAutomatic,
    String? sourceInfo,
  }) =>
      BackupModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        sizeInBytes: sizeInBytes ?? this.sizeInBytes,
        status: status ?? this.status,
        type: type ?? this.type,
        location: location ?? this.location,
        tags: tags ?? this.tags,
        metadata: metadata ?? this.metadata,
        isEncrypted: isEncrypted ?? this.isEncrypted,
        encryptionAlgorithm: encryptionAlgorithm ?? this.encryptionAlgorithm,
        retentionDays: retentionDays ?? this.retentionDays,
        isAutomatic: isAutomatic ?? this.isAutomatic,
        sourceInfo: sourceInfo ?? this.sourceInfo,
      );

  /// Get human-readable size
  String getReadableSize() {
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    double bytes = sizeInBytes.toDouble();
    int sizeIndex = 0;
    while (bytes >= 1024 && sizeIndex < sizes.length - 1) {
      bytes /= 1024;
      sizeIndex++;
    }
    return '${bytes.toStringAsFixed(2)} ${sizes[sizeIndex]}';
  }

  /// Check if backup is expired based on retention policy
  bool isExpired() {
    if (retentionDays == null) return false;
    return DateTime.now().difference(createdAt).inDays > retentionDays!;
  }

  /// Check if backup is healthy
  bool isHealthy() => status == BackupStatus.completed;

  @override
  String toString() => 'BackupModel(id: $id, name: $name, status: $status)';
}

/// Enum for backup status
enum BackupStatus {
  pending,
  inProgress,
  completed,
  failed,
  paused,
  cancelled,
  verifying,
  verified;

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'status': toString().split('.').last,
        'timestamp': DateTime.now().toIso8601String(),
      };

  /// Create from JSON
  factory BackupStatus.fromJson(Map<String, dynamic> json) {
    final statusString = json['status'] as String;
    return BackupStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
      orElse: () => BackupStatus.pending,
    );
  }
}

/// Enum for backup type
enum BackupType {
  full,
  incremental,
  differential,
  snapshot,
  cloud,
  local,
  hybrid;
}
