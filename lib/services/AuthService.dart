import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Substitua pelo seu IP local se estiver no emulador (ex: 10.0.2.2 para Android)
  // Se for Spring Boot rodando local: http://10.0.2.2:8080/api/auth/login
  final String _baseUrl = "http://localhost:5020/api"; 

  Future<Map<String, dynamic>> login(String login, String senha) async {
    final url = Uri.parse('$_baseUrl/login');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "login": login,
          "senha": senha,
        }),
      );

      if (response.statusCode == 200) {
        // Sucesso: Retorna o JSON (Token, Role, etc)
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Email ou senha incorretos.");
      } else {
        throw Exception("Erro no servidor. Tente novamente.");
      }
    } catch (e) {
      rethrow; // Passa o erro para o Controller tratar
    }
  }
}