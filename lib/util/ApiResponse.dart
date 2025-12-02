import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse {
  
  static String tratarErro(http.Response response) {
    try {
      // Tenta decodificar o corpo da resposta usando UTF-8 para aceitar acentos
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      // Verifica se o campo 'message' existe no JSON (conforme seu ErroResponseDTO)
      if (body.containsKey('message') && body['message'] != null) {
        return body['message'];
      }
      
      // Fallback: se tiver 'error' mas não 'message'
      if (body.containsKey('error') && body['error'] != null) {
        return body['error'];
      }

      return "Ocorreu um erro não identificado.";
      
    } catch (e) {
      // Se o backend não retornou um JSON (ex: erro 500 HTML ou Timeout)
      return "Erro de comunicação com o servidor (${response.statusCode}).";
    }
  }
}