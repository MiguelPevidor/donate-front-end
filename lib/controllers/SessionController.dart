import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionController {
  // Padrão Singleton: garante que só existe uma instância desta classe no app inteiro
  static final SessionController _instance = SessionController._internal();
  
  factory SessionController() {
    return _instance;
  }

  SessionController._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Variáveis em memória para acesso rápido (cache)
  Map<String, dynamic>? _decodedToken;
  String? _token;

  // --- Getters Inteligentes ---
  // Verifica se o token existe e não expirou
  bool get isLoggedIn => _token != null && !JwtDecoder.isExpired(_token!);
  
  // Retorna o ID do usuário de forma segura
  String? get userId => _decodedToken?['id'] ?? _decodedToken?['userId'] ?? _decodedToken?['sub'];
  
  // Retorna a Role (papel) do usuário
  String? get userRole => _decodedToken?['role'];
  
  // Verifica se é uma instituição (lógica centralizada!)
  bool get isInstituicao {
    final role = userRole?.toString().toUpperCase() ?? '';
    return role.contains('INSTITUICAO');
  }

  /// Restaura a sessão ao abrir o app (Ideal chamar na Splash Screen ou main.dart)
  Future<void> restoreSession() async {
    String? token = await _storage.read(key: 'token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      _token = token;
      _decodedToken = JwtDecoder.decode(token);
    } else {
      await logout(); // Se expirou, limpa tudo
    }
  }

  /// Salva a sessão no momento do Login
  Future<void> login(String token) async {
    await _storage.write(key: 'token', value: token);
    _token = token;
    _decodedToken = JwtDecoder.decode(token);
    
    // Opcional: Salvar userId separadamente se algum serviço legado precisar
    if (userId != null) {
      await _storage.write(key: 'userId', value: userId);
    }
  }

  /// Limpa a sessão (Logout)
  Future<void> logout() async {
    await _storage.deleteAll();
    _token = null;
    _decodedToken = null;
  }
}