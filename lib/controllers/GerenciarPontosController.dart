import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Para LatLng

import '../services/PontoColetaService.dart';
import '../model/PontoDeColeta.dart';
import '../model/Item.dart';
import '../model/Endereco.dart';
import '../util/localizador.dart'; // Importe o localizador

class GerenciarPontosController extends ChangeNotifier {
  final PontoColetaService _service = PontoColetaService();
  final _storage = const FlutterSecureStorage();

  List<PontoDeColeta> meusPontos = [];
  List<Item> todosItens = [];
  bool isLoading = false;
  String? instituicaoId;

  Future<void> carregarDadosIniciais() async {
    isLoading = true;
    notifyListeners();
    try {
      String? token = await _storage.read(key: 'token');
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        instituicaoId = decodedToken['id'] ?? decodedToken['userId'] ?? decodedToken['sub'];
        if (instituicaoId != null) {
          meusPontos = await _service.listarPorInstituicao(instituicaoId!);
        }
      }
    } catch (e) {
      print("Erro ao carregar: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarItens() async {
    try {
      todosItens = await _service.listarTodosItensDisponiveis();
      notifyListeners();
    } catch (e) { print(e); }
  }

  // --- ATUALIZADO: Salvar com Geocoding Automático ---
  Future<bool> salvarPonto({
    String? id,
    required String horario,
    required String capacidade,
    required Endereco enderecoDados, // Dados vindos do formulário (sem lat/long ainda)
    required List<String> itensSelecionadosIds,
  }) async {
    if (instituicaoId == null) return false;

    isLoading = true;
    notifyListeners();

    try {
      // 1. Monta a string de busca (ex: "Av Paulista, 1000, Bela Vista, Sao Paulo - SP")
      String buscaEndereco = 
          "${enderecoDados.logradouro}, ${enderecoDados.numero}, "
          "${enderecoDados.bairro}, ${enderecoDados.cidade} - ${enderecoDados.estado}";

      print("Buscando coordenadas para: $buscaEndereco");

      // 2. Tenta pegar a Lat/Long real
      LatLng? coords = await Localizador.obterCoordenadasPorEndereco(buscaEndereco);
      
      // 3. Cria um novo objeto Endereco com as coordenadas descobertas (ou 0.0 se falhar)
      Endereco enderecoFinal = Endereco(
        logradouro: enderecoDados.logradouro,
        numero: enderecoDados.numero,
        bairro: enderecoDados.bairro,
        cidade: enderecoDados.cidade,
        estado: enderecoDados.estado,
        cep: enderecoDados.cep,
        latitude: coords?.latitude ?? 0.0,  // Preenche aqui!
        longitude: coords?.longitude ?? 0.0, // Preenche aqui!
      );

      // 4. Monta o JSON para enviar ao Java
      final requestBody = {
        'horarioFuncionamento': horario,
        'capacidadeMaxima': int.tryParse(capacidade) ?? 0,
        'instituicaoId': instituicaoId,
        'endereco': enderecoFinal.toJson(), // Vai com lat/long preenchidos
        'itensIds': itensSelecionadosIds
      };

      if (id == null) {
        await _service.criarPonto(requestBody);
      } else {
        await _service.atualizarPonto(id, requestBody);
      }
      
      await carregarDadosIniciais();
      return true;

    } catch (e) {
      print("Erro ao salvar: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletar(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.deletarPonto(id);
      meusPontos.removeWhere((p) => p.id == id);
    } catch (e) { print(e); } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}