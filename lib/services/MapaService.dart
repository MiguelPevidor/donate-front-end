import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/PontoDeColeta.dart';
import '../model/Item.dart';
import '../util/Constants.dart';

class MapaService {
  
  // 1. Busca todos os tipos de itens (Roupas, Alimentos...)
  Future<List<Item>> buscarItens() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/itens/listar-todos');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        List<dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        // Converte o JSON para objetos Item
        return dados.map((json) => Item.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Erro ao buscar itens: $e");
      return [];
    }
  }

  // 2. Busca TODOS os pontos de coleta (sem filtro)
  Future<List<PontoDeColeta>> buscarTodosPontos() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/pontos-de-coleta/listar-todos');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => PontoDeColeta.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Erro ao buscar pontos: $e");
      return [];
    }
  }

  // 3. Busca filtrando por itens
  Future<List<PontoDeColeta>> buscarPontosPorFiltro(List<String> itensIds) async {
    try {
      String query = itensIds.join(","); 
      final url = Uri.parse('${Constants.baseUrl}/pontos-de-coleta/por-item?itensIds=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((json) => PontoDeColeta.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Erro no filtro: $e");
      return [];
    }
  }
}