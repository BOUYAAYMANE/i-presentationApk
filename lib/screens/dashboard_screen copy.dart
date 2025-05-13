// DashboardScreen.dart
import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/screens/Reports_Screen.dart';
import 'package:i_presence/screens/attendance_stats_screen.dart';
import 'package:i_presence/utils/constante.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:i_presence/screens/session_detail_screen.dart';
import 'package:i_presence/screens/create_session_screen.dart';

// Constantes
// const String baseUrl = 'https://api.i-presence.com';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {
    'totalStudents': 0,
    'totalClasses': 0,
    'totalSessions': 0,
    'averageAttendance': 0.0,
    'attendanceByMonth': [],
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
        Uri.parse('$KbaseUrl/api/dashboard'),
        headers: {
          'Authorization': 'Bearer ${authModel.token}',
            'Content-Type': 'application/json',
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
                          Icons.people,
                          'Étudiants',
                          _stats['totalStudents'].toString(),
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          Icons.school,
                          'Classes',
                          _stats['totalClasses'].toString(),
                          Colors.green,
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
                          Icons.check_circle,
                          'Présence moyenne',
                          '${(_stats['averageAttendance'] * 100).toStringAsFixed(1)}%',
                          Colors.purple,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Tendance des présences',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      child: _buildAttendanceChart(),
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
                                  title: Text(session['name']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Classe: ${session['class_name'] ?? 'Non définie'}'),
                                      Text(
                                        'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(session['date']))} '
                                        '${session['start_time']} - ${session['end_time']}',
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${session['present_count'] ?? 0}',
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
                                            '${session['absent_count'] ?? 0}',
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SessionDetailScreen(sessionId: session['id']),
                                      ),
                                    );
                                  },
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
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.add_circle, color: Colors.blue),
                            title: Text('Créer une nouvelle session'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateSessionScreen(),
                                ),
                              ).then((_) => _loadDashboardData());
                            },
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.bar_chart, color: Colors.green),
                            title: Text('Statistiques de présence'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceStatsScreen(),
                                ),
                              );
                            },
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                            title: Text('Générer un rapport'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildAttendanceChart() {
    if (_stats['attendanceByMonth'] == null || _stats['attendanceByMonth'].isEmpty) {
      return Center(child: Text('Aucune donnée disponible'));
    }

    // Préparation des données pour le graphique
    List<FlSpot> attendanceSpots = [];
    List<String> months = [];
    
    for (int i = 0; i < _stats['attendanceByMonth'].length; i++) {
      var item = _stats['attendanceByMonth'][i];
      attendanceSpots.add(FlSpot(i.toDouble(), item['rate'] * 100));
      months.add(item['month']);
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return Text(months[index]);
                }
                return Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (attendanceSpots.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: attendanceSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
