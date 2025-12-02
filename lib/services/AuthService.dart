import 'dart:convert';
import 'package:donate/util/ApiResponse.dart';
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
        return jsonDecode(response.body);
      } else {
        // Tenta pegar a mensagem do backend (ex: "Credenciais inválidas")
        // Se falhar (ex: 401 padrão do Spring sem JSON), usamos uma mensagem padrão.
        String msgBackend = ApiResponse.tratarErro(response);
        
        // Se o helper retornou erro genérico de parsing mas é 401, forçamos a msg
        if (response.statusCode == 401 && msgBackend.contains("Erro de comunicação")) {
           throw Exception("Login ou senha incorretos.");
        }

        throw Exception(msgBackend);
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<Map<String, dynamic>> getUsuario(String id, String token) async {
    final url = Uri.parse('${Constants.baseUrl}/usuarios/$id');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", 
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retorna { "id":..., "login":..., "email":... }
    } else {
      throw Exception("Falha ao carregar dados do usuário");
    }
  }
}