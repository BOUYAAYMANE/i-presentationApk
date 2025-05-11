import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/screens/TeacherHome_screen.dart';
import 'package:i_presence/screens/dashboard_screen.dart';
// import 'package:i_presence/screens/classes_screen.dart';
// import 'package:i_presence/screens/students_screen.dart';
// import 'package:i_presence/screens/reports_screen.dart';
// import 'package:i_presence/screens/profile_screen.dart';
import 'package:i_presence/screens/scanner_screen.dart';
// import 'package:i_presence/screens/session_attendance_screen.dart';
// import 'package:i_presence/screens/teacher_profile_screen.dart';
// import 'package:i_presence/screens/student_home_screen.dart';
// import 'package:i_presence/screens/student_attendance_screen.dart';
// import 'package:i_presence/screens/justifications_screen.dart';
// import 'package:i_presence/screens/student_profile_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    
    // Définir les écrans en fonction du rôle de l'utilisateur
    List<Widget> _screens = [];
    
    if (authModel.role == 'admin') {
      _screens = [
        DashboardScreen(),
        // ClassesScreen(),
        // StudentsScreen(),
        // ReportsScreen(),
        // ProfileScreen(),
      ];
    } else if (authModel.role == 'teacher') {
      _screens = [
        TeacherHomeScreen(),
        ScannerScreen(),
        // SessionAttendanceScreen(),
        // TeacherProfileScreen(),
      ];
    } else { // student
      _screens = [
        // StudentHomeScreen(),
        // StudentAttendanceScreen(),
        // JustificationsScreen(),
        // StudentProfileScreen(),
      ];
    }
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _buildNavBarItems(authModel.role),
      ),
    );
  }
  
  List<BottomNavigationBarItem> _buildNavBarItems(String? role) {
    if (role == 'admin') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Tableau de bord',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.class_),
          label: 'Classes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Étudiants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Rapports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ];
    } else if (role == 'teacher') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scanner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Présences',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ];
    } else { // student
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Présences',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note_alt),
          label: 'Justifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ];
    }
  }
}