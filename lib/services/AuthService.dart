import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:donate/util/Constants.dart';

class AuthService {
  // Substitua pelo seu IP local se estiver no emulador (ex: 10.0.2.2 para Android)
  // Se for Spring Boot rodando local: http://10.0.2.2:8080/api/auth/login

  Future<Map<String, dynamic>> login(String login, String senha) async {
    final url = Uri.parse('${Constants.baseUrl}/login');
    
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
      print(e.toString());
      rethrow; // Passa o erro para o Controller tratar
    }
  }


  Future<Map<String, dynamic>> getUsuario(String id, String token) async {
    final url = Uri.parse('${Constants.baseUrl}/usuarios/$id');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Envia o token para autenticação
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retorna { "id":..., "login":..., "email":... }
    } else {
      throw Exception("Falha ao carregar dados do usuário");
    }
  }
}