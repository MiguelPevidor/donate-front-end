import 'dart:async';
import 'dart:io';
import 'package:donate/util/GeradorBitmapDescriptor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/Instituicao.dart';
import '../util/GerenciadoraArquivo.dart';
import '../util/localizador.dart';

class MapaController{
  late List<Instituicao> instituicoes;
  Set<Marker>? markers;
  GoogleMapController? mapController;

  Marker? marker_atual;
  int posicao_marker_atual = -1;

  MapaController();

  Future<List<Instituicao>> buscarInstituicoes() async{
    //consultar api

    // retorna uma lista vazia por enquanto
    instituicoes = <Instituicao> [];
    return instituicoes;

  }


  inicializarPosicaoAtual(){
    if(posicao_marker_atual == -1 && markers!.length > 0){
      posicao_marker_atual = 0;
    }
  }

  LatLng obterPosicaoInicial() {
    return posicao_marker_atual == -1
    // Centro de Colatina
        ? LatLng(-19.5167339, -40.722392)
        : markers!.elementAt(0).position;
  }

  void avancarProximoMarker() {
    if(posicao_marker_atual == (markers!.length-1)){
      posicao_marker_atual = 0;
    } else {
      posicao_marker_atual++;
    }
    final LatLng latlng = markers!.elementAt(posicao_marker_atual).position;
    mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latlng,
          zoom: 17.0,
        ),
      ),
    );
  }

  Future<BitmapDescriptor> obterBitmapDescriptor(String? foto) async {
    if (foto == null || foto == "") {
      return await GeradorBitmapDescriptor.gerarBitMapDescriptorFromAsset(
          'assets/icon/imagem_mapa.png', 100);
    } else {
      File file = await GerenciadoraArquivo.obterImagem(foto);
      return await GeradorBitmapDescriptor.gerarBitMapDescriptorFromFile(
          file, 100);
    }
  }

  Future<List<Marker>> obterMarkers() async {
    List<Marker> markers = <Marker>[];
    for (Instituicao instituicao in instituicoes) {
      LatLng? latLng =
      await Localizador.obterLatitudeLongitudePorEndereco(instituicao.endereco!);
      if (latLng != null) {
        BitmapDescriptor userIcon =
        await obterBitmapDescriptor(instituicao.urlFoto);
        Marker marker = Marker(
          markerId: MarkerId(instituicao.id.toString()),
          position: latLng,
          icon: userIcon,
          infoWindow: InfoWindow(
            title: instituicao.nome,
            snippet: instituicao.endereco,
          ),
        );
        markers.add(marker);
      }
    }
    return markers;
  }
}
