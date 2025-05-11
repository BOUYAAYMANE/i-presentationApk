import 'package:i_presence/models/classroom_model.dart';
import 'package:i_presence/utils/constante.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class APIService {
  final String token;
  
  APIService(this.token);
  
  Future<List<ClassRoom>> fetchClasses({String? level, String? academicYear}) async {
    String url = '$KbaseUrl/classes?';
    if (level != null) url += 'level=$level&';
    if (academicYear != null) url += 'academic_year=$academicYear';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((item) => ClassRoom.fromJson(item))
          .toList();
    } else {
      throw Exception('Échec du chargement des classes');
    }
  }
  
  Future<List<Course>> fetchTeacherCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/teacher/courses'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((item) => Course.fromJson(item))
          .toList();
    } else {
      throw Exception('Échec du chargement des cours');
    }
  }
  
  Future<List<Session>> fetchCourseSessions(int courseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId/sessions'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((item) => Session.fromJson(item))
          .toList();
    } else {
      throw Exception('Échec du chargement des sessions');
    }
  }
  
  Future<Session> createSession(int courseId, DateTime startTime, DateTime endTime) async {
    final response = await http.post(
      Uri.parse('$KbaseUrl/sessions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'course_id': courseId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      }),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Session.fromJson(data);
    } else {
      throw Exception('Échec de la création de la session');
    }
  }
  
  Future<List<Attendance>> fetchSessionAttendance(int sessionId) async {
    final response = await http.get(
      Uri.parse('$KbaseUrl/sessions/$sessionId/attendance'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((item) => Attendance.fromJson(item))
          .toList();
    } else {
      throw Exception('Échec du chargement des présences');
    }
  }
  
  Future<void> updateAttendance(int attendanceId, String status) async {
    final response = await http.put(
      Uri.parse('$KbaseUrl/attendance/$attendanceId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour de la présence');
    }
  }
  
  Future<void> closeSession(int sessionId) async {
    final response = await http.put(
      Uri.parse('$KbaseUrl/sessions/$sessionId/close'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Échec de la clôture de la session');
    }
  }
}
