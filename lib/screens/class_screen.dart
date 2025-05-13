import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/models/classroom_model.dart';
import 'package:i_presence/models/coursesession_model.dart';
import 'package:i_presence/models/student_model.dart';
import 'package:i_presence/services/api_service.dart';
import 'package:i_presence/utils/constante.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:i_presence/screens/create_class_screen.dart';

class ClassesScreen extends StatefulWidget {
  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<ClassRoom> _classes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedLevel = 'Tous';
  List<String> _levels = ['Tous', 'Primaire', 'Collège', 'Lycée', 'Supérieur'];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      
      String? levelFilter = _selectedLevel != 'Tous' ? _selectedLevel : null;
      final classes = await apiService.fetchClasses(level: levelFilter);

      setState(() {
        _classes = classes;
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

  List<ClassRoom> get _filteredClasses {
    if (_searchQuery.isEmpty) {
      return _classes;
    }
    
    return _classes.where((classRoom) =>
      classRoom.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      classRoom.level.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadClasses,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtre
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une classe...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Niveau: '),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedLevel,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLevel = newValue;
                          });
                          _loadClasses();
                        }
                      },
                      items: _levels.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Liste des classes
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _filteredClasses.isEmpty
                ? Center(child: Text('Aucune classe trouvée'))
                : RefreshIndicator(
                    onRefresh: _loadClasses,
                    child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: _filteredClasses.length,
                      itemBuilder: (context, index) {
                        final classRoom = _filteredClasses[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getColorForLevel(classRoom.level),
                              child: Text(
                                classRoom.name.substring(0, 1),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(classRoom.name),
                            subtitle: Text('Niveau: ${classRoom.level}'),
                            trailing: Text(
                              '${classRoom.studentsCount} élèves',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassDetailScreen(classRoom: classRoom),
                                ),
                              ).then((_) => _loadClasses());
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateClassScreen(),
            ),
          ).then((_) => _loadClasses());
        },
        child: Icon(Icons.add),
        tooltip: 'Ajouter une classe',
      ),
    );
  }
  
  Color _getColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'primaire':
        return Colors.green;
      case 'collège':
        return Colors.blue;
      case 'lycée':
        return Colors.purple;
      case 'supérieur':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class ClassDetailScreen extends StatefulWidget {
  final ClassRoom classRoom;
  
  ClassDetailScreen({required this.classRoom});
  
  @override
  _ClassDetailScreenState createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Student> _students = [];
  List<CourseSession> _sessions = [];
  bool _isLoadingStudents = true;
  bool _isLoadingSessions = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStudents();
    _loadSessions();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadStudents() async {
    setState(() {
      _isLoadingStudents = true;
    });
    
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final response = await http.get(
        Uri.parse('$KbaseUrl/classrooms/${widget.classRoom.id}/students'),
        headers: {
          'Authorization': 'Bearer ${authModel.token}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _students = (data['data'] as List)
              .map((item) => Student.fromJson(item))
              .toList();
          _isLoadingStudents = false;
        });
      } else {
        throw Exception('Échec du chargement des étudiants');
      }
    } catch (e) {
      setState(() {
        _isLoadingStudents = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _loadSessions() async {
    setState(() {
      _isLoadingSessions = true;
    });
    
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      final sessions = await apiService.fetchClassSessions(widget.classRoom.id);
      
      setState(() {
        _sessions = sessions;
        _isLoadingSessions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSessions = false;
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
        title: Text(widget.classRoom.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Étudiants'),
            Tab(text: 'Sessions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Étudiants
          _isLoadingStudents
            ? Center(child: CircularProgressIndicator())
            : _students.isEmpty
              ? Center(child: Text('Aucun étudiant dans cette classe'))
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: student.user.profilePhotoPath != null
                            ? NetworkImage('$KbaseUrl/${student.user.profilePhotoPath}')
                            : null,
                          child: student.user.profilePhotoPath == null
                            ? Text(student.user.name.substring(0, 1))
                            : null,
                        ),
                        title: Text(student.user.name),
                        // subtitle: Text('N° d\'inscription: ${student.registrationNumber}'),
                        trailing: Text(
                          '${student.absenceCount} absences',
                          style: TextStyle(
                            color: student.absenceCount > 5 ? Colors.red : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => StudentDetailScreeN(student: student),
                      //       ),
                      //     );
                      //   },
                      ),
                    );
                  },
                ),
          
          // Onglet Sessions
          _isLoadingSessions
            ? Center(child: CircularProgressIndicator())
            : _sessions.isEmpty
              ? Center(child: Text('Aucune session pour cette classe'))
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            // color: session.isActive ? Colors.green : Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // child: Icon(
                          //   // session.isActive ? Icons.play_arrow : Icons.calendar_today,
                          //   // color: Colors.white,
                          // ),
                        ),
                        title: Text(session.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${session.getFormattedDate()} ${session.getFormattedTimeRange()}'),
                            if (session.subject != null) Text('Matière: ${session.subject}'),
                          ],
                        ),
                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Text(
                        //           // '${session.presentCount}',
                        //           style: TextStyle(
                        //             color: Colors.green,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //         Text('Présents'),
                        //       ],
                        //     ),
                        //     SizedBox(width: 16),
                        //     Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Text(
                        //           // '${session.absentCount}',
                        //           style: TextStyle(
                        //             color: Colors.red,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //         Text('Absents'),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => SessionDetailScreen(sessionId: session.id),
                      //       ),
                      //     );
                      //   },
                      ),
                    );
                  },
                ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => CreateSessionScreen(preselectedClassId: widget.classRoom.id),
      //       ),
      //     ).then((_) => _loadSessions());
      //   },
      //   icon: Icon(Icons.add),
      //   label: Text('Nouvelle session'),
      // ),
    );
  }
}
