import 'package:geocoding/geocoding.dart'; 
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // <--- Importe o url_launcher aqui

class Localizador {
  
  static Future<Position> determinarPosicaoAtual() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) return Future.error('GPS desabilitado.');
    
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) return Future.error('Permissão negada.');
    }
    return await Geolocator.getCurrentPosition();
  }

  // --- Geocoding (Texto -> Latitude/Longitude) ---
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

  // --- NOVO MÉTODO: Abrir App de Mapas Externo ---
  static Future<void> abrirGoogleMaps(double lat, double long) async {
    final Uri url = Uri.parse('google.navigation:q=$lat,$long&mode=d');
    
    try {
      if (!await launchUrl(url)) {
        // Se falhar (ex: app não instalado), abre no navegador
        // Corrigi a URL para o padrão web oficial do Google Maps
        final Uri webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$long');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Erro ao abrir mapa: $e");
    }
  }
}