class QaReplyData {
  const QaReplyData({
    required this.id,
    required this.threadId,
    required this.authorRole,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String authorRole;
  final String authorId;
  final String content;
  final DateTime? createdAt;

  factory QaReplyData.fromJson(Map<String, dynamic> json) {
    return QaReplyData(
      id: (json['id'] ?? '').toString(),
      threadId: (json['threadId'] ?? '').toString(),
      authorRole: (json['authorRole'] ?? '').toString(),
      authorId: (json['authorId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: _toDateTime(json['createdAt']),
    );
  }
}

class QaThreadData {
  const QaThreadData({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.questionId,
    required this.sessionId,
    required this.title,
    required this.content,
    required this.status,
    required this.closeRemark,
    required this.lastRepliedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
  });

  final String id;
  final String userId;
  final String subjectId;
  final String questionId;
  final String sessionId;
  final String title;
  final String content;
  final String status;
  final String closeRemark;
  final DateTime? lastRepliedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<QaReplyData> replies;

  bool get isClosed => status.trim().toLowerCase() == 'closed';

  factory QaThreadData.fromJson(Map<String, dynamic> json) {
    return QaThreadData(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      questionId: (json['questionId'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      closeRemark: (json['closeRemark'] ?? '').toString(),
      lastRepliedAt: _toDateTime(json['lastRepliedAt']),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      replies: _toMapList(json['replies']).map(QaReplyData.fromJson).toList(),
    );
  }

  /// 回复成功后仅局部回写当前线程，避免详情页因为一次回复重新拉整页列表。
  QaThreadData copyWith({
    String? status,
    String? closeRemark,
    DateTime? lastRepliedAt,
    DateTime? updatedAt,
    List<QaReplyData>? replies,
  }) {
    return QaThreadData(
      id: id,
      userId: userId,
      subjectId: subjectId,
      questionId: questionId,
      sessionId: sessionId,
      title: title,
      content: content,
      status: status ?? this.status,
      closeRemark: closeRemark ?? this.closeRemark,
      lastRepliedAt: lastRepliedAt ?? this.lastRepliedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is int) {
    if (value <= 0) {
      return null;
    }
    return value > 1000000000000
        ? DateTime.fromMillisecondsSinceEpoch(value)
        : DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  if (value is num) {
    return _toDateTime(value.toInt());
  }
  final raw = value.toString().trim();
  if (raw.isEmpty) {
    return null;
  }
  final intValue = int.tryParse(raw);
  if (intValue != null) {
    return _toDateTime(intValue);
  }
  return DateTime.tryParse(raw);
}

Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}

List<Map<String, dynamic>> _toMapList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.map(_toMap).toList();
}
