import 'package:flutter/material.dart';
import 'package:i_presence/models/attendance_model.dart';
import 'package:i_presence/models/coursesession_model.dart';
import 'package:i_presence/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:i_presence/models/auth_model.dart';

class SessionAttendanceScreen extends StatefulWidget {
  final CourseSession session;

  const SessionAttendanceScreen({Key? key, required this.session}) : super(key: key);

  @override
  _SessionAttendanceScreenState createState() => _SessionAttendanceScreenState();
}

class _SessionAttendanceScreenState extends State<SessionAttendanceScreen> {
  List<Attendance> _attendances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    setState(() => _isLoading = true);
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      final attendances = await apiService.fetchSessionAttendance(widget.session.id);
      setState(() {
        _attendances = attendances;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des présences: $e')),
      );
    }
  }

  Future<void> _updateAttendanceStatus(Attendance attendance, String newStatus) async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      final success = await apiService.updateAttendanceStatus(attendance.id, newStatus);
      
      if (success) {
        await _loadAttendances();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour avec succès')),
        );
      } else {
        throw Exception('Échec de la mise à jour du statut');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Présences - ${widget.session.courseName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAttendances,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAttendances,
              child: Column(
                children: [
                  _buildSessionInfo(),
                  Expanded(
                    child: _buildAttendanceList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSessionInfo() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.courseName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text('Classe: ${widget.session.className}'),
            Text('Horaire: ${widget.session.startTime} - ${widget.session.endTime}'),
            Text('Date: ${widget.session.date}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_attendances.isEmpty) {
      return Center(
        child: Text('Aucune présence enregistrée'),
      );
    }

    return ListView.builder(
      itemCount: _attendances.length,
      itemBuilder: (context, index) {
        final attendance = _attendances[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(attendance.studentName[0]),
            ),
            title: Text(attendance.studentName),
            subtitle: Text('Statut: ${_getStatusText(attendance.status)}'),
            trailing: PopupMenuButton<String>(
              onSelected: (String status) => _updateAttendanceStatus(attendance, status),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'present',
                  child: Text('Présent'),
                ),
                PopupMenuItem(
                  value: 'absent',
                  child: Text('Absent'),
                ),
                PopupMenuItem(
                  value: 'late',
                  child: Text('En retard'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Présent';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'En retard';
      default:
        return status;
    }
  }
} 