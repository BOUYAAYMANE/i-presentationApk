import 'package:flutter/material.dart';
import 'package:i_presence/models/coursesession_model.dart';
import 'package:i_presence/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:i_presence/models/auth_model.dart';

class TeacherHomeScreen extends StatefulWidget {
  @override
  _TeacherHomeScreenState createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  List<CourseSession> _todaySessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodaySessions();
  }

  Future<void> _loadTodaySessions() async {
    setState(() => _isLoading = true);
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      final sessions = await apiService.fetchTeacherCourses();
      setState(() {
        _todaySessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des sessions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Enseignant'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTodaySessions,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodaySessions,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActions(),
                    SizedBox(height: 24),
                    Text(
                      'Sessions du jour',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    _buildSessionsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scanner QR',
                  onTap: () {
                    Navigator.pushNamed(context, '/scanner');
                  },
                ),
                _buildActionButton(
                  icon: Icons.list_alt,
                  label: 'Présences',
                  onTap: () {
                    Navigator.pushNamed(context, '/attendance');
                  },
                ),
                _buildActionButton(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  onTap: () {
                    // TODO: Implement notifications screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_todaySessions.isEmpty) {
      return Center(
        child: Text('Aucune session prévue aujourd\'hui'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _todaySessions.length,
      itemBuilder: (context, index) {
        final session = _todaySessions[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(session.courseName),
            subtitle: Text('${session.startTime} - ${session.endTime}'),
            trailing: IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/scanner',
                  arguments: session,
                );
              },
            ),
          ),
        );
      },
    );
  }
}