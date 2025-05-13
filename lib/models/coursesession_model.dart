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
  final String courseName;
  final String startTime;
  final String endTime;
  final int classId;
  final String className;
  final String date;

  CourseSession({
    required this.id,
    required this.courseName,
    required this.startTime,
    required this.endTime,
    required this.classId,
    required this.className,
    required this.date,
  });

  factory CourseSession.fromJson(Map<String, dynamic> json) {
    return CourseSession(
      id: json['id'],
      courseName: json['course_name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      classId: json['class_id'],
      className: json['class_name'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'start_time': startTime,
      'end_time': endTime,
      'class_id': classId,
      'class_name': className,
      'date': date,
    };
  }

  String getFormattedStartTime() {
    return startTime;
  }
  
  String getFormattedEndTime() {
    return endTime;
  }
  
  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }
  
  String getFormattedTimeRange() {
    return '$startTime - $endTime';
  }
}