import 'package:flutter/material.dart';

class SessionDetailScreen extends StatelessWidget {
  final int sessionId;

  const SessionDetailScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la session'),
      ),
      body: Center(
        child: Text('Détails de la session $sessionId'),
      ),
    );
  }
} 