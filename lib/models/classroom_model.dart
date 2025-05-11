class ClassRoom {
  final int id;
  final String name;
  final String level;
  final String academicYear;
  final int studentsCount;

  ClassRoom({
    required this.id,
    required this.name,
    required this.level,
    required this.academicYear,
    required this.studentsCount,
  });

  factory ClassRoom.fromJson(Map<String, dynamic> json) {
    return ClassRoom(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      academicYear: json['academic_year'],
      studentsCount: json['students_count'] ?? 0,
    );
  }
}