import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../util/Constants.dart';
import '../model/PontoDeColeta.dart';
import '../model/Item.dart';

class PontoColetaService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  // Listar pontos da instituição logada
  Future<List<PontoDeColeta>> listarPorInstituicao(String instituicaoId) async {
    final url = Uri.parse('${Constants.baseUrl}/pontos-de-coleta/instituicoes/$instituicaoId');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => PontoDeColeta.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao listar pontos: ${response.body}');
    }
  }

  Future<void> criarPonto(Map<String, dynamic> pontoJson) async {
    final url = Uri.parse('${Constants.baseUrl}/pontos-de-coleta');
    final response = await http.post(
      url, 
      headers: await _getHeaders(), 
      body: jsonEncode(pontoJson)
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar ponto: ${response.body}');
    }
  }

  Future<void> atualizarPonto(String id, Map<String, dynamic> pontoJson) async {
    final url = Uri.parse('${Constants.baseUrl}/pontos-de-coleta/$id');
    final response = await http.put(
      url, 
      headers: await _getHeaders(), 
      body: jsonEncode(pontoJson)
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar ponto: ${response.body}');
    }
  }

  Future<void> deletarPonto(String id) async {
    final url = Uri.parse('${Constants.baseUrl}/pontos-de-coleta/$id');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao deletar: ${response.body}');
    }
  }

  // --- MOCK DE ITENS (Enquanto sua rota de itens não fica pronta) ---
  Future<List<Item>> listarTodosItensDisponiveis() async {
    // Quando a rota existir: 
    // final response = await http.get(Uri.parse('${Constants.baseUrl}/itens'));
    
    // Por enquanto, retorno estático para teste:
    await Future.delayed(Duration(milliseconds: 500));
    return [
      Item(id: "uuid-1", nomeItem: "Roupas"),
      Item(id: "uuid-2", nomeItem: "Alimentos Não Perecíveis"),
      Item(id: "uuid-3", nomeItem: "Brinquedos"),
      Item(id: "uuid-4", nomeItem: "Móveis"),
    ];
  }
}