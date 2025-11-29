import 'dart:convert';
import 'package:donate/model/Doador.dart';
import 'package:donate/model/Instituicao.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../util/Constants.dart'; // Sua classe de constantes com a baseUrl

class CadastrarUsuarioService {
  
  Future<void> cadastrarDoador(Doador doador) async {
    final url = Uri.parse('${Constants.baseUrl}/doadores/salvarDoador');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(doador.toJson()), // Converte o objeto para JSON
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sucesso
        return;
      } else {
        // Trate erros do backend (ex: email já existe)
        throw Exception("Falha ao cadastrar doador: ${response.body}");
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Endpoint para salvar instituição
  Future<void> cadastrarInstituicao(Instituicao instituicao) async {
    final url = Uri.parse('${Constants.baseUrl}/instituicoes/salvarInstituicao');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(instituicao.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception("Falha ao cadastrar instituição: ${response.body}");
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}