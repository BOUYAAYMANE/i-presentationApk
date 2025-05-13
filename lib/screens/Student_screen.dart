// StudentsScreen.dart
import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/models/classroom_model.dart';
import 'package:i_presence/models/student_model.dart';
import 'package:i_presence/services/api_service.dart';
import 'package:i_presence/utils/constante.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentsScreen extends StatefulWidget {
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedClassId;
  List<ClassRoom> _classes = [];
  
  TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    await _loadClasses();
    await _loadStudents();
  }
  
  Future<void> _loadClasses() async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      final classes = await apiService.fetchClasses();
      
      setState(() {
        _classes = classes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement des classes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      String url = '$KbaseUrl/students?';
      
      if (_selectedClassId != null) {
        url += 'class_id=$_selectedClassId&';
      }
      
      if (_searchQuery.isNotEmpty) {
        url += 'search=$_searchQuery';
      }
      
      final response = await http.get(
        Uri.parse(url),
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
          _isLoading = false;
        });
      } else {
        throw Exception('Échec du chargement des étudiants');
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
  
  void _applySearch() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _loadStudents();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Étudiants'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres et recherche
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un étudiant...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        ),
                        onSubmitted: (_) => _applySearch(),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _applySearch,
                      child: Icon(Icons.search),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text('Toutes les classes'),
                        selected: _selectedClassId == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedClassId = null;
                            });
                            _loadStudents();
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      ..._classes.map((classRoom) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(classRoom.name),
                          selected: _selectedClassId == classRoom.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedClassId = selected ? classRoom.id : null;
                            });
                            _loadStudents();
                          },
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des étudiants
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _students.isEmpty
                ? Center(child: Text('Aucun étudiant trouvé'))
                : RefreshIndicator(
                    onRefresh: _loadStudents,
                    child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text('N° d\'inscription: ${student.registrationNumber}'),
                                Text('Classe: ${student.classId ?? 'Non assigné'}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${student.absenceCount}%',
                                  style: TextStyle(
                                    // color: _getAttendanceColor(student.attendanceRate),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Présence'),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailScreen(student: student),
                                ),
                              ).then((_) => _loadStudents());
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => CreateStudentScreen(),
      //       ),
      //     ).then((_) => _loadStudents());
      //   },
      //   child: Icon(Icons.add),
      //   tooltip: 'Ajouter un étudiant',
      // ),
    );
  }
  
  Color _getAttendanceColor(double rate) {
    if (rate >= 90) {
      return Colors.green;
    } else if (rate >= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class StudentDetailScreen extends StatefulWidget {
  final Student student;
  
  StudentDetailScreen({required this.student});
  
  @override
  _StudentDetailScreenState createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAttendanceHistory();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAttendanceHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final response = await http.get(
        Uri.parse('$KbaseUrl/students/${widget.student.id}/attendance'),
        headers: {
          'Authorization': 'Bearer ${authModel.token}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _attendanceRecords = (data['data'] as List)
              .map((item) => AttendanceRecord.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Échec du chargement de l\'historique de présence');
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
        title: Text(widget.student.user.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Informations'),
            Tab(text: 'Présences'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Informations
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: widget.student.user.profilePhotoPath != null
                          ? NetworkImage('$baseUrl/${widget.student.user.profilePhotoPath}')
                          : null,
                        child: widget.student.user.profilePhotoPath == null
                          ? Text(
                              widget.student.user.name.substring(0, 1),
                              style: TextStyle(fontSize: 40),
                            )
                          : null,
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.student.user.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        widget.student.user.email,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations scolaires',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Divider(),
                        _buildInfoRow('Numéro d\'inscription', widget.student.registrationNumber),
                        _buildInfoRow('Classe', widget.student.className ?? 'Non assigné'),
                        _buildInfoRow('Niveau', widget.student.level ?? 'Non défini'),
                        _buildInfoRow('Date d\'inscription', widget.student.getFormattedEnrollmentDate()),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistiques de présence',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Divider(),
                        _buildInfoRow('Taux de présence', '${widget.student.attendanceRate}%'),
                        _buildInfoRow('Absences', '${widget.student.absenceCount} fois'),
                        _buildInfoRow('Sessions manquées', '${widget.student.missedSessionsCount} sessions'),
                        _buildInfoRow('Dernière présence', widget.student.lastAttendance ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations additionnelles',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Divider(),
                        _buildInfoRow('Téléphone', widget.student.user.phone ?? 'Non renseigné'),
                        _buildInfoRow('Adresse', widget.student.user.address ?? 'Non renseignée'),
                        if (widget.student.parentName != null)
                          _buildInfoRow('Parent/Tuteur', widget.student.parentName!),
                        if (widget.student.parentContact != null)
                          _buildInfoRow('Contact parent', widget.student.parentContact!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Onglet Présences
          _isLoading
            ? Center(child: CircularProgressIndicator())
            : _attendanceRecords.isEmpty
              ? Center(child: Text('Aucun historique de présence disponible'))
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final record = _attendanceRecords[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: record.status == 'present' ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: Icon(
                            record.status == 'present' ? Icons.check : Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(record.sessionName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record.getFormattedDate()),
                            Text(record.getFormattedTime()),
                          ],
                        ),
                        trailing: record.status == 'present'
                          ? Text(
                              'Présent',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Absent',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (record.isJustified)
                                  Chip(
                                    label: Text('Justifié'),
                                    backgroundColor: Colors.blue.withOpacity(0.2),
                                    labelStyle: TextStyle(color: Colors.blue),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionDetailScreen(sessionId: record.sessionId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditStudentScreen(student: widget.student),
            ),
          ).then((_) {
            // Rafraîchir les données de l'étudiant après modification
            // Idéalement, il faudrait récupérer les nouvelles données depuis l'API
          });
        },
        child: Icon(Icons.edit),
        tooltip: 'Modifier l\'étudiant',
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}