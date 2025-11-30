import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Importante para o Position

import '../util/Constants.dart';
import '../util/localizador.dart'; // Importe seu Localizador
import '../model/PontoDeColeta.dart';
import '../util/GeradorBitmapDescriptor.dart';

class MapaController extends ChangeNotifier {
  late GoogleMapController mapController;
  Set<Marker>? markers = {};
  List<PontoDeColeta> pontos = [];

  // Posição inicial provisória (ex: centro da cidade) até o GPS carregar
  final LatLng _posicaoInicial = const LatLng(-19.5393, -40.6305);

  LatLng obterPosicaoInicial() => _posicaoInicial;

  // --- NOVO: Método para ser chamado quando o mapa for criado ---
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    centralizarNoUsuario(); // Tenta focar no usuário assim que o mapa abre
  }

  // --- NOVO: Lógica para mover a câmera para o usuário ---
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
      // Opcional: Mostrar um aviso na tela se falhar
    }
  }

  Future<void> buscarPontosDeColeta() async {
    try {
      final uri = Uri.parse('${Constants.baseUrl}/pontos-de-coleta/listar-todos');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        pontos = data.map((json) => PontoDeColeta.fromJson(json)).toList();
        notifyListeners();
      } else {
        print('Erro API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro Conexão: $e');
    }
  }

  Future<List<Marker>> obterMarkers() async {
    Set<Marker> novosMarkers = {};
    BitmapDescriptor icone;
    
    try {
       icone = await GeradorBitmapDescriptor.gerarIcone(
         Icons.location_on, 
         Colors.green, 
         size: 85.0 
       );
    } catch (e) {
       icone = BitmapDescriptor.defaultMarker;
    }

    for (var ponto in pontos) {
      if (ponto.latitude != 0.0 && ponto.longitude != 0.0) {
        final marker = Marker(
          markerId: MarkerId(ponto.id),
          position: LatLng(ponto.latitude, ponto.longitude),
          icon: icone, 
          infoWindow: InfoWindow(
            snippet: ponto.horarioFuncionamento,
            title: "Ponto de Coleta", // Adicionei um título padrão se não tiver nome
          ),
        );
        novosMarkers.add(marker);
      }
    }

    markers = novosMarkers;
    notifyListeners();
    return markers!.toList();
  }
  
  int _indexAtual = 0;
  void avancarProximoMarker() {
    if (pontos.isEmpty) return;
    if (_indexAtual >= pontos.length) _indexAtual = 0;
    
    final ponto = pontos[_indexAtual];
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(ponto.latitude, ponto.longitude), 16),
    );
    mapController.showMarkerInfoWindow(MarkerId(ponto.id));
    _indexAtual++;
  }
}