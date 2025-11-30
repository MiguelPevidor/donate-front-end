import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/PontoColetaService.dart';
import '../model/PontoDeColeta.dart';
import '../model/Item.dart';
import '../model/Endereco.dart';
import '../util/localizador.dart';

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
      print("Erro ao carregar pontos: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarItens() async {
    try {
      todosItens = await _service.listarTodosItensDisponiveis();
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar itens: $e");
    }
  }

  Future<bool> salvarPonto({
    String? id,
    required String horario,
    required String capacidade,
    required Endereco enderecoDados,
    required List<String> itensSelecionadosIds,
  }) async {
    if (instituicaoId == null) return false;

    isLoading = true;
    notifyListeners();

    try {
      // --- CORREÇÃO AQUI ---
      // Monta lista removendo campos vazios para evitar ", , ,"
      List<String> partes = [
        enderecoDados.logradouro,
        enderecoDados.numero.isNotEmpty ? enderecoDados.numero : "S/N",
        enderecoDados.bairro,
        enderecoDados.cidade,
        enderecoDados.estado
      ];
      
      // Junta tudo com vírgula e adiciona Brasil
      String buscaEndereco = partes
          .where((p) => p.trim().isNotEmpty)
          .join(", ") + ", Brasil";

      print("Buscando coordenadas para: $buscaEndereco");

      LatLng? coords = await Localizador.obterCoordenadasPorEndereco(buscaEndereco);
      
      if (coords == null) {
        print("ALERTA: Geocoding falhou ou não encontrou o local.");
      } else {
        print("SUCESSO: Lat: ${coords.latitude}, Long: ${coords.longitude}");
      }

      Endereco enderecoFinal = Endereco(
        logradouro: enderecoDados.logradouro,
        numero: enderecoDados.numero,
        bairro: enderecoDados.bairro,
        cidade: enderecoDados.cidade,
        estado: enderecoDados.estado,
        cep: enderecoDados.cep,
        latitude: coords?.latitude ?? 0.0,
        longitude: coords?.longitude ?? 0.0,
      );

      final requestBody = {
        'horarioFuncionamento': horario,
        'capacidadeMaxima': int.tryParse(capacidade) ?? 0,
        'instituicaoId': instituicaoId,
        'endereco': enderecoFinal.toJson(),
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
      print("Erro ao salvar ponto: $e");
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
    } catch (e) {
      print("Erro ao deletar: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}