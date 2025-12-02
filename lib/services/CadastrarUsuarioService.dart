import 'dart:convert';
import 'package:donate/model/Doador.dart';
import 'package:donate/model/Instituicao.dart';
import 'package:donate/util/ApiResponse.dart';
import 'package:http/http.dart' as http;
import '../util/Constants.dart';

class CadastrarUsuarioService {
  
  Future<void> cadastrarDoador(Doador doador) async {
    final url = Uri.parse('${Constants.baseUrl}/doadores/salvarDoador');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(doador.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        String mensagemErro = ApiResponse.tratarErro(response);
        throw Exception(mensagemErro);
      }
    } catch (e) {
      rethrow;
    }
  }

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
        String mensagemErro = ApiResponse.tratarErro(response);
        throw Exception(mensagemErro);
      }
    } catch (e) {
      rethrow;
    }
  }
}