import 'dart:async';
import 'package:donate/model/Instituicao.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/MapaController.dart';

class MapaPage extends StatefulWidget {




  @override
  _MapaPageState createState() => _MapaPageState();

  const MapaPage();
}

class _MapaPageState extends State<MapaPage> {
  late MapaController _controle;
  late Future<List<Marker>> future;

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    future = _carregarDadosEProcessarMarkers();
  }

  Future<List<Marker>> _carregarDadosEProcessarMarkers() async {
    try {
      //    ESPERA (await) o controller buscar os dados da API primeiro.
      //    (Assumindo que seu controller foi atualizado para
      //     armazenar a lista 'instituicoes' internamente).
      await _controle.buscarInstituicoes();

      //    SÓ DEPOIS que a API retornou, ele chama o 'obterMarkers'
      //    (que faz o geocoding) e retorna a lista final de markers.
      return _controle.obterMarkers();

    } catch (e) {
      // Lidar com erros de API ou Geocoding
      print("Erro ao carregar dados: $e");
      // Lança o erro para o FutureBuilder poder exibi-lo
      throw Exception('Falha ao carregar marcadores: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Usuários'),
      ),
      body: _body(),
    );
  }

  _body() {
    return FutureBuilder<List<Marker>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        _controle.markers = snapshot.data!.toSet();
        _controle.inicializarPosicaoAtual();
        return _conteudo();
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controle.mapController = controller;
  }

  _conteudo() {
    return Stack(
      children: <Widget>[
        Container(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _controle.obterPosicaoInicial(),
              zoom: 17,
            ),
            markers: _controle.markers!,
            onMapCreated: _onMapCreated,
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            child: Icon(Icons.navigate_next),
            onPressed: () {
              _controle.avancarProximoMarker();
            },
          ),
        ),
      ],
    );
  }
}
