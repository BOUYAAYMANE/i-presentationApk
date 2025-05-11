

// class CourseSession {
//   final int id;
//   final int teacherId;
//   final int classRoomId;
//   final String subject;
//   final DateTime date;
//   final String startTime;
//   final String endTime;
//   final String? teacherName;
//   final String? className;

//   CourseSession({
//     required this.id,
//     required this.teacherId,
//     required this.classRoomId,
//     required this.subject,
//     required this.date,
//     required this.startTime,
//     required this.endTime,
//     this.teacherName,
//     this.className,
//   });

//   factory CourseSession.fromJson(Map<String, dynamic> json) {
//     return CourseSession(
//       id: json['id'],
//       teacherId: json['teacher_id'],
//       classRoomId: json['class_room_id'],
//       subject: json['subject'],
//       date: DateTime.parse(json['date']),
//       startTime: json['start_time'],
//       endTime: json['end_time'],
//       teacherName: json['teacher']?['user']?['name'],
//       className: json['class_room']?['name'],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CourseSession {
  final int id;
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? subject;
  final DateTime? date;
  final int? teacherId;
  final int? classRoomId;
  // final String? className;
  // final String? qrCode;
  // final bool isActive;
  // final int presentCount;
  // final int absentCount;
  
  CourseSession({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.subject,
    this.date,
    this.teacherId,
    this.classRoomId,
    // this.className,
    // this.qrCode,
    // this.isActive = false,
    // this.presentCount = 0,
    // this.absentCount = 0,
  });
  
  factory CourseSession.fromJson(Map<String, dynamic> json) {
    // Parse start_time et end_time qui sont au format HH:MM:SS
    final startTimeParts = json['start_time'].toString().split(':');
    final endTimeParts = json['end_time'].toString().split(':');
    
    return CourseSession(
      id: json['id'],
      name: json['name'],
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      subject: json['subject'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      teacherId: json['teacher_id'],
      classRoomId: json['class_room_id'],
      // className: json['class_name'],
      // qrCode: json['qr_code'],
      // isActive: json['is_active'] ?? false,
      // presentCount: json['present_count'] ?? 0,
      // absentCount: json['absent_count'] ?? 0,
    );
  }
  
  String getFormattedStartTime() {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }
  
  String getFormattedEndTime() {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
  
  String getFormattedDate() {
    if (date == null) return 'Date non définie';
    return DateFormat('dd/MM/yyyy').format(date!);
  }
  
  String getFormattedTimeRange() {
    return '${getFormattedStartTime()} - ${getFormattedEndTime()}';
  }
}