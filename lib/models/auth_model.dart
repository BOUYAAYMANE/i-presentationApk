import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Ajouté pour le Timer
import 'package:i_presence/utils/constante.dart';
import 'package:jwt_decoder/jwt_decoder.dart' as jwt;

class AuthModel extends ChangeNotifier {
  String? _token;
  String? _role;
  int? _userId;
  final storage = const FlutterSecureStorage();
  Timer? _tokenExpiryTimer;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get role => _role;
  int? get userId => _userId;

  Future<void> loadStoredAuth() async {
    _token = await storage.read(key: 'token');
    
    // Vérifier si le token existe et s'il est expiré
    if (_token != null) {
      if (isTokenExpired(_token!)) {
        // Si le token est expiré, effacer les informations d'authentification
        print('Token expiré, déconnexion automatique');
        await logout();
        return;
      } else {
        // Si le token est valide, charger les autres informations
        _role = await storage.read(key: 'role');
        final userId = await storage.read(key: 'userId');
        _userId = userId != null ? int.parse(userId) : null;
        
        // Configurer le timer pour la déconnexion automatique
        _setAutoLogoutTimer(_token!);
        
        notifyListeners();
      }
    }
  }
  
  // Méthode pour vérifier si un token est expiré
  bool isTokenExpired(String token) {
    try {
      return jwt.JwtDecoder.isExpired(token);
    } catch (e) {
      print('Erreur lors de la vérification du token: $e');
      return true;
    }
  }

  // Méthode pour configurer le timer de déconnexion automatique
  void _setAutoLogoutTimer(String token) {
    // Annuler le timer existant si présent
    _tokenExpiryTimer?.cancel();
    
    try {
      // Obtenir la date d'expiration du token
      final expiryDate = jwt.JwtDecoder.getExpirationDate(token);
      final timeToExpiry = expiryDate.difference(DateTime.now());
      
      print('Token expire dans: ${timeToExpiry.inMinutes} minutes');
      
      // Configurer le timer pour se déconnecter automatiquement à l'expiration
      _tokenExpiryTimer = Timer(timeToExpiry, () async {
        print('Timer expiré, déconnexion automatique');
        await logout();
      });
    } catch (e) {
      print('Erreur lors de la configuration du timer d\'expiration: $e');
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      // If running on an emulator, may need to use special IP instead of localhost
      String baseUrl = 'http://localhost:8000';
      
      // For Android emulator, localhost of your dev machine is 10.0.2.2
      if (Platform.isAndroid) {
        try {
          baseUrl = 'http://10.0.2.2:8000';
          print('Using Android emulator URL: $baseUrl');
        } catch (e) {
          // If we can't detect platform, stick with original URL
          print('Could not determine platform: $e');
        }
      }
      
      final url = '$baseUrl/api/login';
      print('Connecting to: $url');
      print('Login data: email=$email, password=${password.isNotEmpty ? '(provided)' : '(empty)'}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email, 
          'password': password
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      // Print response body but handle potential errors
      try {
        print('Response body: ${response.body}');
      } catch (e) {
        print('Could not print response body: $e');
      }
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('JSON decoded successfully');
          
          // Extract token using correct key from API response
          _token = data['access_token'];
          if (_token == null) {
            print('Token was null in response');
            return false;
          }
          
          print('Token received: ${_token!.substring(0, 10)}...');
          
          // Make sure these match the actual structure in your API response
          if (data['user'] != null) {
            _role = data['user']['role'];
            _userId = data['user']['id'];
            print('User info extracted: role=$_role, id=$_userId');
          } else {
            print('User object was null in response');
          }
          
          // Store values in secure storage
          await storage.write(key: 'token', value: _token);
          await storage.write(key: 'role', value: _role);
          await storage.write(key: 'userId', value: _userId?.toString());
          print('Credentials saved to secure storage');
          
          // Configurer le timer pour la déconnexion automatique
          _setAutoLogoutTimer(_token!);
          
          notifyListeners();
          return true;
        } catch (e) {
          print('Error parsing response JSON: $e');
          return false;
        }
      } else {
        print('Authentication failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        final response = await http.post(
          Uri.parse('$KbaseUrl/api/logout'),  // Make sure to include /api/ if needed
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
        
        print('Logout response: ${response.statusCode}');
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Annuler le timer de déconnexion automatique
      _tokenExpiryTimer?.cancel();
      _tokenExpiryTimer = null;
      
      // Always clear local data regardless of server response
      _token = null;
      _role = null;
      _userId = null;
      
      await storage.delete(key: 'token');
      await storage.delete(key: 'role');
      await storage.delete(key: 'userId');
      
      notifyListeners();
    }
  }
}