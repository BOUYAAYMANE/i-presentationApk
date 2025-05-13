import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attendance_model.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des présences'),
      ),
      body: Consumer<AttendanceModel>(
        builder: (context, attendanceModel, child) {
          if (attendanceModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (attendanceModel.attendances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune présence enregistrée',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: attendanceModel.attendances.length,
            itemBuilder: (context, index) {
              final attendance = attendanceModel.attendances[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(attendance.status),
                    child: Icon(
                      _getStatusIcon(attendance.status),
                      color: Colors.white,
                    ),
                  ),
                  title: Text('Élève ID: ${attendance.studentId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(attendance.date)}',
                      ),
                      Text('Statut: ${_getStatusText(attendance.status)}'),
                      if (attendance.justification != null)
                        Text('Justification: ${attendance.justification}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Supprimer la présence'),
                          content: Text(
                            'Êtes-vous sûr de vouloir supprimer cette présence ?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                attendanceModel.deleteAttendance(attendance.id!);
                                Navigator.pop(context);
                              },
                              child: Text('Supprimer'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check;
      case 'absent':
        return Icons.close;
      case 'late':
        return Icons.access_time;
      default:
        return Icons.help;
    }
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
        return 'Inconnu';
    }
  }
} 