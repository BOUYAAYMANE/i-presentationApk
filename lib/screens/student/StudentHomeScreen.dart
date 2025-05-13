import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une classe'),
      ),
      body: Center(
        child: Text('Formulaire de création de classe'),
      ),
    );
  }
} 