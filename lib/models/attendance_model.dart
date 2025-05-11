class Attendance {
  final int id;
  final int sessionId;
  final int studentId;
  final String status; // 'present', 'absent', 'late'
  final String? studentName;
  final DateTime? arrivalTime;

  Attendance({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.studentName,
    this.arrivalTime,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      sessionId: json['session_id'],
      studentId: json['student_id'],
      status: json['status'],
      studentName: json['student']?['user']?['name'],
      arrivalTime: json['arrival_time'] != null 
        ? DateTime.parse(json['arrival_time']) 
        : null,
    );
  }
}
