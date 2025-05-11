import 'package:i_presence/models/user_model.dart';

class Student {
  final int id;
  final User user;
  final int classId;
  final String? parentName;
  final String? parentPhone;
  final String? qrCodePath;
  final int absenceCount;

  Student({
    required this.id,
    required this.user,
    required this.classId,
    this.parentName,
    this.parentPhone,
    this.qrCodePath,
    required this.absenceCount,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      user: User.fromJson(json['user']),
      classId: json['class_id'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      qrCodePath: json['qr_code_path'],
      absenceCount: json['absence_count'] ?? 0,
    );
  }
}