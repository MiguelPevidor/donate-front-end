import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/PontoDeColeta.dart';
import '../model/Item.dart';
import '../services/MapaService.dart';
import '../services/PontoColetaService.dart';
import '../util/GeradorBitmapDescriptor.dart';
import '../util/localizador.dart';
import 'SessionController.dart'; // <--- Importação crucial

class MapaController extends ChangeNotifier {
  final MapaService _mapaService = MapaService();
  final PontoColetaService _pontoService = PontoColetaService();
  
  // Acesso ao Singleton de Sessão
  final SessionController _session = SessionController();

  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List<PontoDeColeta> pontos = [];
  List<Item> tiposItens = [];

  final LatLng _posicaoInicial = const LatLng(-19.5393, -40.6305);
  LatLng obterPosicaoInicial() => _posicaoInicial;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    centralizarNoUsuario();
  }

  Future<void> centralizarNoUsuario() async {
    try {
      var posicao = await Localizador.determinarPosicaoAtual();
      mapController.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(posicao.latitude, posicao.longitude), 16));
    } catch (e) {
      print("Erro localização: $e");
    }
  }

  // --- Inicialização Limpa e Inteligente ---
  Future<void> inicializarDados() async {
    // 1. Carrega filtros
    try {
      tiposItens = await _mapaService.buscarItens();
    } catch (e) {
      print("Erro ao buscar itens: $e");
    }

    // 2. Lógica de decisão baseada na Sessão (sem decodificar token aqui!)
    if (_session.isInstituicao) {
      // Se for instituição, vê só os seus pontos
      // O userId já vem limpo do SessionController
      pontos = await _pontoService.listarPorInstituicao(_session.userId ?? "");
    } else {
      // Se for doador ou anônimo, vê todos
      pontos = await _mapaService.buscarTodosPontos();
    }

    await _gerarMarkers();
    notifyListeners();
  }
  
  /// NOVA LÓGICA: Verifica se precisa mostrar o alerta de cadastro
  /// Retorna true se for instituição E não tiver pontos.
  Future<bool> verificarSePrecisaCadastrarPonto() async {
    // Se não estiver logado ou não for instituição, retorna false logo de cara
    if (!_session.isLoggedIn || !_session.isInstituicao) {
      return false;
    }

    try {
      // Se a lista de pontos estiver vazia, verificamos na API para ter certeza
      if (pontos.isEmpty) {
         var meusPontos = await _pontoService.listarPorInstituicao(_session.userId ?? "");
         return meusPontos.isEmpty;
      }
      return false; // Se a lista não está vazia, é porque já tem pontos
    } catch (e) {
      print("Erro ao verificar pontos iniciais: $e");
      return false;
    }
  }

  Future<void> buscarPontosPorFiltro(List<String> ids) async {
     if (ids.isEmpty) {
       await inicializarDados();
       return;
     }
     pontos = await _mapaService.buscarPontosPorFiltro(ids);
     await _gerarMarkers();
     notifyListeners();
  }

  Future<void> _gerarMarkers() async {
    Set<Marker> novos = {};
    var icone = await GeradorBitmapDescriptor.gerarIcone(Icons.location_on, Colors.green);

    for (var p in pontos) {
      if (p.endereco.latitude != null && p.endereco.longitude != null) {
        novos.add(Marker(
          markerId: MarkerId(p.id ?? p.hashCode.toString()),
          position: LatLng(p.endereco.latitude!, p.endereco.longitude!),
          icon: icone,
          onTap: () {
             // O clique é gerido pela View, mas o marker precisa existir
          }
        ));
      }
    }
    markers = novos;
    notifyListeners();
  }
  
  void irParaPonto(double lat, double lng) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18));
  }
}