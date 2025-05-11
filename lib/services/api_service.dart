import 'package:i_presence/models/attendance_model.dart';
import 'package:i_presence/models/classroom_model.dart';
import 'package:i_presence/models/coursesession_model.dart';
import 'package:i_presence/utils/constante.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class APIService {
  final String token;
  
  APIService(this.token);
  
  Future<List<ClassRoom>> fetchClasses({String? level, String? academicYear}) async {
    String url = '$KbaseUrl/classes';
    
    if (level != null || academicYear != null) {
      url += '?';
      if (level != null) url += 'level=$level&';
      if (academicYear != null) url += 'academic_year=$academicYear&';
      url = url.substring(0, url.length - 1); // Enlever le dernier '&'
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<ClassRoom> classes = [];
      
      for (var item in data['data']) {
        classes.add(ClassRoom.fromJson(item));
      }
      
      return classes;
    } else {
      throw Exception('Échec du chargement des classes');
    }
  }
  
  Future<List<CourseSession>> fetchSessions({String? date, int? classId}) async {
    String url = '$KbaseUrl/sessions';
    
    if (date != null || classId != null) {
      url += '?';
      if (date != null) url += 'date=$date&';
      if (classId != null) url += 'class_id=$classId&';
      url = url.substring(0, url.length - 1);
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<CourseSession> sessions = [];
      
      for (var item in data['data']) {
        sessions.add(CourseSession.fromJson(item));
      }
      
      return sessions;
    } else {
      throw Exception('Échec du chargement des sessions');
    }
  }
  
  Future<List<Attendance>> fetchSessionAttendance(int sessionId) async {
    final response = await http.get(
      Uri.parse('$KbaseUrl/attendance/session/$sessionId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Attendance> attendances = [];
      
      for (var item in data) {
        attendances.add(Attendance.fromJson(item));
      }
      
      return attendances;
    } else {
      throw Exception('Échec du chargement des présences');
    }
  }
  
  Future<bool> updateAttendanceStatus(int attendanceId, String status) async {
    final response = await http.put(
      Uri.parse('$KbaseUrl/attendance/$attendanceId/update-status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'status': status,
      }),
    );
    
    return response.statusCode == 200;
  }
  
  Future<List<CourseSession>> fetchTeacherCourses() async {
    final response = await http.get(
      Uri.parse('$KbaseUrl/teacher/courses'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<CourseSession> courses = [];
      
      for (var item in data['data']) {
        courses.add(CourseSession.fromJson(item));
      }
      
      return courses;
    } else {
      throw Exception('Échec du chargement des cours');
    }
  }
}