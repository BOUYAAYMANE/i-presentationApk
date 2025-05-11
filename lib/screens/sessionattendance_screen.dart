import 'package:flutter/material.dart';
import 'package:i_presence/models/attendance_model.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/models/coursesession_model.dart';
import 'package:i_presence/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SessionAttendanceScreen extends StatefulWidget {
  @override
  _SessionAttendanceScreenState createState() => _SessionAttendanceScreenState();
}

class _SessionAttendanceScreenState extends State<SessionAttendanceScreen> {
  List<CourseSession> _sessions = [];
  CourseSession? _selectedSession;
  List<Attendance> _attendanceList = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }
  
  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      
      // Charger les sessions du jour
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final sessions = await apiService.fetchSessions(date: today);
      
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _loadAttendance(int sessionId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      
      final attendances = await apiService.fetchSessionAttendance(sessionId);
      
      setState(() {
        _attendanceList = attendances;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _updateStatus(int attendanceId, String status) async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      
      final success = await apiService.updateAttendanceStatus(attendanceId, status);
      
      if (success) {
        if (_selectedSession != null) {
          _loadAttendance(_selectedSession!.id);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la mise à jour du statut'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des présences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Sélecteur de session
                Container(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<CourseSession>(
                    decoration: const InputDecoration(
                      labelText: 'Sélectionner une session',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSession,
                    items: _sessions.map((session) {
                      return DropdownMenuItem<CourseSession>(
                        value: session,
                        child: Text('${session.subject} - ${session.name} (${session.startTime}-${session.endTime})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSession = value;
                      });
                      if (value != null) {
                        _loadAttendance(value.id);
                      }
                    },
                  ),
                ),
                
                // Liste des présences
                Expanded(
                  child: _selectedSession == null
                      ? const Center(
                          child: Text('Veuillez sélectionner une session'),
                        )
                      : ListView.builder(
                          itemCount: _attendanceList.length,
                          itemBuilder: (context, index) {
                            final attendance = _attendanceList[index];
                            
                            Color statusColor;
                            IconData statusIcon;
                            
                            switch (attendance.status) {
                              case 'present':
                                statusColor = Colors.green;
                                statusIcon = Icons.check_circle;
                                break;
                              case 'absent':
                                statusColor = Colors.red;
                                statusIcon = Icons.cancel;
                                break;
                              case 'late':
                                statusColor = Colors.orange;
                                statusIcon = Icons.access_time;
                                break;
                              default:
                                statusColor = Colors.grey;
                                statusIcon = Icons.question_mark;
                            }
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: Icon(statusIcon, color: statusColor),
                                title: Text(attendance.studentName ?? 'Étudiant #${attendance.studentId}'),
                                subtitle: attendance.arrivalTime != null
                                    ? Text('Arrivé à ${DateFormat('HH:mm').format(attendance.arrivalTime!)}')
                                    : null,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    _updateStatus(attendance.id, value);
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'present',
                                      child: Text('Présent'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'absent',
                                      child: Text('Absent'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'late',
                                      child: Text('En retard'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}