import 'dart:convert';
import 'package:donate/util/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Import para o Position
import '../model/PontoDeColeta.dart';
import '../util/localizador.dart'; 
import '../util/GeradorBitmapDescriptor.dart';

class MapaController extends ChangeNotifier {

  late GoogleMapController mapController;
  Set<Marker>? markers = {};
  List<PontoDeColeta> pontos = [];
  
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
      // CORREÇÃO: Acessamos lat/long através do objeto 'endereco'
      // E verificamos se são nulos, pois no modelo Endereco eles são double?
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
    notifyListeners();
    return markers!.toList();
  }
  
  int _indexAtual = 0;
  void avancarProximoMarker() {
    if (pontos.isEmpty) return;
    if (_indexAtual >= pontos.length) _indexAtual = 0;
    
    final ponto = pontos[_indexAtual];
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
}