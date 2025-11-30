import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Importante para o Position

// Imports dos seus Models e Utils
import 'package:donate/model/Item.dart';
import '../model/PontoDeColeta.dart';
import '../services/MapaService.dart';
import '../util/GeradorBitmapDescriptor.dart';
import '../util/localizador.dart'; // Certifique-se de ter este arquivo com a lógica do GPS

class MapaController extends ChangeNotifier {
  final MapaService _service = MapaService();

  late GoogleMapController mapController;
  Set<Marker> markers = {};
  
  // Listas de dados
  List<PontoDeColeta> pontos = [];
  List<Item> tiposItens = []; // Lista de Objetos Item (ID + Nome)

  final LatLng _posicaoInicial = const LatLng(-19.5393, -40.6305);
  LatLng obterPosicaoInicial() => _posicaoInicial;

  // --- MÉTODOS DE MAPA (Vindos do Remoto) ---
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Tenta focar no usuário assim que o mapa abre (se tiver permissão)
    centralizarNoUsuario(); 
  }

  Future<void> centralizarNoUsuario() async {
    try {
      // Usa sua classe utilitária Localizador
      Position posicao = await Localizador.determinarPosicaoAtual();
      
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(posicao.latitude, posicao.longitude),
            zoom: 16,
          ),
        ),
      );
    } catch (e) {
      print("Erro ao obter localização: $e");
    }
  }

  // --- INICIALIZAÇÃO ---
  Future<void> inicializarDados() async {
    // 1. Carrega os chips (categorias)
    tiposItens = await _service.buscarItens();
    
    // 2. Carrega os pontos iniciais (todos)
    await buscarTodosPontos();
    
    notifyListeners();
  }

  // --- MÉTODOS DE BUSCA ---

  Future<void> buscarTodosPontos() async {
    pontos = await _service.buscarTodosPontos();
    await _gerarMarkers();
    notifyListeners();
  }

  // ADAPTAÇÃO: Recebe List<String> (IDs) para filtrar
  Future<void> buscarPontosPorFiltro(List<String> idsSelecionados) async {
    if (idsSelecionados.isEmpty) {
      await buscarTodosPontos();
      return;
    }
    pontos = await _service.buscarPontosPorFiltro(idsSelecionados);
    await _gerarMarkers();
    notifyListeners();
  }

  // --- GERAÇÃO DE MARKERS ---
  Future<void> _gerarMarkers() async {
    Set<Marker> novosMarkers = {};
    BitmapDescriptor icone;

    try {
      icone = await GeradorBitmapDescriptor.gerarIcone(
          Icons.location_on, Colors.green, size: 45.0);
    } catch (e) {
      icone = BitmapDescriptor.defaultMarker;
    }

    for (var ponto in pontos) {
      if (ponto.latitude != 0.0 && ponto.longitude != 0.0) {
        novosMarkers.add(Marker(
          markerId: MarkerId(ponto.id.toString()),
          position: LatLng(ponto.latitude, ponto.longitude),
          icon: icone,
          infoWindow: InfoWindow(
            title: ponto.nome, // Nome do ponto
            snippet: ponto.horarioFuncionamento, // Horário
          ),
        ));
      }
    }
    markers = novosMarkers;
  }

  // --- NAVEGAÇÃO NO MAPA ---
  
  void irParaPonto(double lat, double lng) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 18),
      ),
    );
  }

  int _indexAtual = 0;
  void avancarProximoMarker() {
    if (pontos.isEmpty) return;
    if (_indexAtual >= pontos.length) _indexAtual = 0;

    final ponto = pontos[_indexAtual];
    irParaPonto(ponto.latitude, ponto.longitude);
    mapController.showMarkerInfoWindow(MarkerId(ponto.id.toString()));
    _indexAtual++;
  }
}