// utils/constante.dart

// Base URL for the API - This will be overridden for emulators
const String KbaseUrl = 'http://localhost:8000';

// API Endpoints
const String KloginEndpoint = '/api/login';
const String KlogoutEndpoint = '/api/logout';

// Storage keys
const String KtokenKey = 'token';
const String KroleKey = 'role';
const String KuserIdKey = 'userId';

// Other constants
const int KtimeoutDuration = 30;  // Seconds