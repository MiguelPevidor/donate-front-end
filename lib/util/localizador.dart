import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Localizador {
  
  // 1. Método para pegar a posição atual (GPS)
  static Future<Position> determinarPosicaoAtual() async {
    bool servicoHabilitado;
    LocationPermission permissao;

    // Verifica se o GPS está ligado
    servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      return Future.error('Por favor, habilite a localização no celular.');
    }

    // Verifica permissões
    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Permissão de localização negada permanentemente. Habilite nas configurações.');
    }

    // Retorna a posição real
    return await Geolocator.getCurrentPosition();
  }

  // 2. Método auxiliar para converter Endereço -> Latitude/Longitude (Geocoding)
  static Future<LatLng?> obterLatitudeLongitudePorEndereco(String endereco) async {
    try {
      List<Location> locations = await locationFromAddress(endereco);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar endereço: $e");
      return null;
    }
  }
}