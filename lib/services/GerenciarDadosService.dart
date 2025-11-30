import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../util/Constants.dart';
import '../model/Doador.dart';
import '../model/Instituicao.dart';

class GerenciarDadosService {
  final _storage = const FlutterSecureStorage();

  // Helper para pegar headers com token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  // --- DOADOR ---
  Future<Doador> buscarDoador(String id) async {
    final url = Uri.parse('${Constants.baseUrl}/doadores/$id');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return Doador.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar doador: ${response.body}');
    }
  }

  Future<void> atualizarDoador(String id, Doador doador) async {
    final url = Uri.parse('${Constants.baseUrl}/doadores/$id');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(doador.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar doador: ${response.body}');
    }
  }

  // --- INSTITUIÇÃO ---
  Future<Instituicao> buscarInstituicao(String id) async {
    final url = Uri.parse('${Constants.baseUrl}/instituicoes/$id');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return Instituicao.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar instituição: ${response.body}');
    }
  }

  Future<void> atualizarInstituicao(String id, Instituicao instituicao) async {
    final url = Uri.parse('${Constants.baseUrl}/instituicoes/$id');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(instituicao.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar instituição: ${response.body}');
    }
  }
}