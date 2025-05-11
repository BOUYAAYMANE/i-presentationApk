import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/models/coursesession_model.dart';
import 'package:i_presence/services/api_service.dart';
import 'package:provider/provider.dart';

class TeacherCoursesScreen extends StatefulWidget {
  @override
  _TeacherCoursesScreenState createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  List<CourseSession> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      final courses = await apiService.fetchTeacherCourses();

      setState(() {
        _courses = courses;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Cours'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCourses,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCourses,
              child: _courses.isEmpty
                  ? Center(
                      child: Text('Aucun cours trouvé'),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final course = _courses[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                course.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(course.name),
                            // subtitle: Text('Classe: ${course.className}'),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    // Text(course.description),
                                    SizedBox(height: 8),
                                    // Text(
                                    //   'Total des sessions: ${course.totalSessions}',
                                    //   style: TextStyle(fontWeight: FontWeight.bold),
                                    // ),
                                    SizedBox(height: 16),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    //   children: [
                                    //     ElevatedButton.icon(
                                    //       icon: Icon(Icons.visibility),
                                    //       label: Text('Voir sessions'),
                                    //       onPressed: () {
                                    //         Navigator.push(
                                    //           context,
                                    //           MaterialPageRoute(
                                    //             builder: (context) => CourseSessionsScreen(courseId: course.id),
                                    //           ),
                                    //         );
                                    //       },
                                    //     ),
                                    //     // ElevatedButton.icon(
                                    //     //   icon: Icon(Icons.add),
                                    //     //   label: Text('Nouvelle session'),
                                    //     //   onPressed: () {
                                    //     //     Navigator.push(
                                    //     //       context,
                                    //     //       MaterialPageRoute(
                                    //     //         builder: (context) => CreateSessionScreen(courseId: course.id),
                                    //     //       ),
                                    //     //     ).then((_) => _loadCourses());
                                    //     //   },
                                    //     // ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}