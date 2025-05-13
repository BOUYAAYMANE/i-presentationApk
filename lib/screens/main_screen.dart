import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/screens/TeacherHome_screen.dart';
import 'package:i_presence/screens/dashboard_screen.dart';
import 'package:i_presence/screens/scanner_screen.dart';
import 'package:i_presence/screens/session_attendance_screen.dart';
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
    
    // Vérifier si l'utilisateur est authentifié
    if (authModel.token == null || authModel.role == null) {
      // Rediriger vers l'écran de connexion si non authentifié
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Session expirée ou non authentifiée'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Rediriger vers la page de connexion
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Définir les écrans en fonction du rôle de l'utilisateur
    List<Widget> _screens = [];
    
    if (authModel.role == 'admin') {
      _screens = [
        DashboardScreen(),
        // Placeholder pour les autres écrans admin
        Center(child: Text('Classes')),
        Center(child: Text('Étudiants')),
        Center(child: Text('Rapports')),
        Center(child: Text('Profil Admin')),
      ];
    } else if (authModel.role == 'teacher') {
      _screens = [
        TeacherHomeScreen(),
        // Scanner sera navigué séparément
        Center(child: Text('Profil Enseignant')),
      ];
    } else if (authModel.role == 'student') {
      _screens = [
        Center(child: Text('Accueil Étudiant')),
        Center(child: Text('Présences')),
        Center(child: Text('Justifications')),
        Center(child: Text('Profil Étudiant')),
      ];
    } else {
      // Rôle inconnu
      _screens = [
        Center(child: Text('Rôle non reconnu: ${authModel.role}')),
      ];
    }

    // S'assurer que l'index est valide
    if (_currentIndex >= _screens.length) {
      _currentIndex = 0;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('I-PRESENCE'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await authModel.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _screens.isNotEmpty ? _screens[_currentIndex] : Center(child: Text('Chargement...')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (authModel.role == 'teacher' && index == 1) {
            // Ouvrir le scanner via navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScannerScreen(),
              ),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
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