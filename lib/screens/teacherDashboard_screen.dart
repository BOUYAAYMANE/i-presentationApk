import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/utils/constante.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
class TeacherDashboardScreen extends StatefulWidget {
  @override
  _TeacherDashboardScreenState createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  Map<String, dynamic> _stats = {
    'totalCourses': 0,
    'totalSessions': 0,
    'activeSession': false,
    'todayAttendance': 0,
    'recentSessions': [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final response = await http.get(
        Uri.parse('$KbaseUrl/teacher/dashboard'),
        headers: {
          'Authorization': 'Bearer ${authModel.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Échec du chargement des données');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vue d\'ensemble',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          context,
                          Icons.book,
                          'Cours',
                          _stats['totalCourses'].toString(),
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          Icons.calendar_today,
                          'Sessions',
                          _stats['totalSessions'].toString(),
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          Icons.timer,
                          'Session active',
                          _stats['activeSession'] ? 'Oui' : 'Non',
                          _stats['activeSession'] ? Colors.green : Colors.grey,
                        ),
                        _buildStatCard(
                          context,
                          Icons.people,
                          'Présences du jour',
                          '${_stats['todayAttendance']}',
                          Colors.purple,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Sessions récentes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    _stats['recentSessions'].isEmpty
                        ? Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('Aucune session récente'),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _stats['recentSessions'].length,
                            itemBuilder: (context, index) {
                              final session = _stats['recentSessions'][index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(session['course_name']),
                                  subtitle: Text(
                                    '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(session['start_time']))} - '
                                    '${DateFormat('HH:mm').format(DateTime.parse(session['end_time']))}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${session['present_count']}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('Présents'),
                                        ],
                                      ),
                                      SizedBox(width: 16),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${session['absent_count']}',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('Absents'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // onTap: () {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) => SessionDetailScreen(sessionId: session['id']),
                                  //     ),
                                  //   );
                                  // },
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 24),
                    Text(
                      'Actions rapides',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    // Card(
                    //   child: Column(
                    //     children: [
                    //       ListTile(
                    //         leading: Icon(Icons.add_circle, color: Colors.blue),
                    //         title: Text('Créer une nouvelle session'),
                    //         trailing: Icon(Icons.arrow_forward_ios),
                    //         onTap: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => CreateSessionScreen(),
                    //             ),
                    //           ).then((_) => _loadDashboardData());
                    //         },
                    //       ),
                    //       Divider(),
                    //       ListTile(
                    //         leading: Icon(Icons.qr_code, color: Colors.purple),
                    //         title: Text('Voir ma session active'),
                    //         trailing: Icon(Icons.arrow_forward_ios),
                    //         onTap: _stats['activeSession']
                    //             ? () {
                    //                 Navigator.push(
                    //                   context,
                    //                   MaterialPageRoute(
                    //                     builder: (context) => ActiveSessionScreen(),
                    //                   ),
                    //                 ).then((_) => _loadDashboardData());
                    //               }
                    //             : null,
                    //         enabled: _stats['activeSession'],
                    //       ),
                    //       Divider(),
                    //       ListTile(
                    //         leading: Icon(Icons.bar_chart, color: Colors.green),
                    //         title: Text('Statistiques de présence'),
                    //         trailing: Icon(Icons.arrow_forward_ios),
                    //         onTap: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => AttendanceStatsScreen(),
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}