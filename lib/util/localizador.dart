import 'package:geocoding/geocoding.dart'; // PACOTE NECESSÁRIO
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Localizador {
  
  static Future<Position> determinarPosicaoAtual() async {
    // ... (seu código existente de GPS) ...
    // Vou resumir aqui para focar na novidade:
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) return Future.error('GPS desabilitado.');
    
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) return Future.error('Permissão negada.');
    }
    return await Geolocator.getCurrentPosition();
  }

  // --- NOVO MÉTODO: Geocoding (Texto -> Latitude/Longitude) ---
  static Future<LatLng?> obterCoordenadasPorEndereco(String enderecoCompleto) async {
    try {
      List<Location> locais = await locationFromAddress(enderecoCompleto);
      if (locais.isNotEmpty) {
        return LatLng(locais.first.latitude, locais.first.longitude);
      }
    } catch (e) {
      print("Erro no Geocoding: $e");
    }
    return null;
  }
}