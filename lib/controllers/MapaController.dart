import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Imports dos Models e Utils
import 'package:donate/model/Item.dart'; // Do colega
import '../model/PontoDeColeta.dart';
import '../services/MapaService.dart'; // Do colega
import '../util/GeradorBitmapDescriptor.dart';
import '../util/localizador.dart';

class MapaController extends ChangeNotifier {
  // --- FUNCIONALIDADE DO COLEGA (Service) ---
  final MapaService _service = MapaService();

  late GoogleMapController mapController;
  Set<Marker> markers = {};
  
  // Listas de dados
  List<PontoDeColeta> pontos = [];
  List<Item> tiposItens = []; // Do colega (Lista de categorias para filtrar)

  final LatLng _posicaoInicial = const LatLng(-19.5393, -40.6305);
  LatLng obterPosicaoInicial() => _posicaoInicial;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    centralizarNoUsuario(); 
  }

  Future<void> centralizarNoUsuario() async {
    try {
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

  // --- MÉTODOS NOVOS DO COLEGA (Inicialização e Filtros) ---

  Future<void> inicializarDados() async {
    // 1. Carrega os chips (categorias)
    tiposItens = await _service.buscarItens();
    
    // 2. Carrega os pontos iniciais (todos)
    await buscarTodosPontos();
    
    notifyListeners();
  }

  Future<void> buscarTodosPontos() async {
    pontos = await _service.buscarTodosPontos();
    await _gerarMarkers(); // Chama a SUA função de markers corrigida
    notifyListeners();
  }

  Future<void> buscarPontosPorFiltro(List<String> idsSelecionados) async {
    if (idsSelecionados.isEmpty) {
      await buscarTodosPontos();
      return;
    }
    pontos = await _service.buscarPontosPorFiltro(idsSelecionados);
    await _gerarMarkers(); // Chama a SUA função de markers corrigida
    notifyListeners();
  }

  // --- SUA LÓGICA PRESERVADA (Geração de Markers com Endereço) ---
  
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
      // AQUI MANTIVE SUA LÓGICA: Acessa lat/long via 'endereco'
      final double? lat = ponto.endereco.latitude;
      final double? long = ponto.endereco.longitude;

      if (lat != null && long != null && lat != 0.0 && long != 0.0 && ponto.id != null) {
        final marker = Marker(
          markerId: MarkerId(ponto.id!), // Usamos ! pois já checamos null acima
          position: LatLng(lat, long),
          icon: icone, 
          infoWindow: InfoWindow(
            snippet: ponto.horarioFuncionamento,
            title: "Ponto de Coleta",
          ),
        );
        novosMarkers.add(marker);
      }
    }
    markers = novosMarkers;
  }

  // --- NAVEGAÇÃO (Mantendo sua lógica de verificação de nulos) ---

  int _indexAtual = 0;
  void avancarProximoMarker() {
    if (pontos.isEmpty) return;
    if (_indexAtual >= pontos.length) _indexAtual = 0;

    final ponto = pontos[_indexAtual];
    
    // MANTIDA SUA LÓGICA DE ACESSO SEGURO
    final double? lat = ponto.endereco.latitude;
    final double? long = ponto.endereco.longitude;

    if (lat != null && long != null && ponto.id != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, long), 16),
      );
      mapController.showMarkerInfoWindow(MarkerId(ponto.id!));
    }
    
    _indexAtual++;
  }

  // Método auxiliar do colega (Deixei aqui caso precise, mas seu 'avancarProximoMarker' não usa ele)
  void irParaPonto(double lat, double lng) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 18),
      ),
    );
  }
}