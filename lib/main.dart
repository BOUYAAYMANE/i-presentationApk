import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/screens/login_screen.dart';
import 'package:i_presence/screens/main_screen.dart';
import 'package:i_presence/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importation des screens et modèles déjà définis
// (On suppose que le code précédent est organisé en fichiers séparés)

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Charger les informations d'authentification stockées
    Future.delayed(Duration.zero, () {
      Provider.of<AuthModel>(context, listen: false).loadStoredAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I-PRESENCE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            minimumSize: Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr'),
      ],
      home: Consumer<AuthModel>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return MainScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
