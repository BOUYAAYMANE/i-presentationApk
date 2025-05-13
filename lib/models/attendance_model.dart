class Attendance {
  final int id;
  final int studentId;
  final String studentName;
  final int sessionId;
  final String status; // 'present', 'absent', 'late'
  final String? justification;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Attendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.sessionId,
    required this.status,
    this.justification,
    required this.createdAt,
    this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      sessionId: json['session_id'],
      status: json['status'],
      justification: json['justification'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'session_id': sessionId,
      'status': status,
      'justification': justification,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}