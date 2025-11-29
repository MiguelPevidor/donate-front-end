import 'dart:async';
import 'package:donate/components/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/MapaController.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late MapaController _controle;
  late Future<List<Marker>> future;
  
  // Chave Global para abrir o Drawer via código
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    future = _carregarDados();
  }

  Future<List<Marker>> _carregarDados() async {
    await _controle.buscarPontosDeColeta(); // Busca na API
    return _controle.obterMarkers(); // Cria os pinos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Vincula a chave ao Scaffold
      drawer: MenuLateral(), // Seu menu lateral
      extendBodyBehindAppBar: true, // Permite que o mapa fique atrás da barra de status
      
      body: FutureBuilder<List<Marker>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          // Atualiza markers no controller se vieram dados
          if (snapshot.hasData) {
             _controle.markers = snapshot.data!.toSet();
          }
          
          return _conteudoMapa();
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controle.mapController = controller;
  }

  Widget _conteudoMapa() {
    return Stack(
      children: <Widget>[
        // CAMADA 1: O Mapa
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _controle.obterPosicaoInicial(),
            zoom: 15,
          ),
          markers: _controle.markers ?? {},
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false, // Mapa limpo
          myLocationEnabled: true,    // Mostra onde estou
          myLocationButtonEnabled: false,
        ),

        // CAMADA 2: Botão Menu (Topo Esquerdo)
        Positioned(
          top: 50, // Margem superior para não ficar sob o relógio
          left: 20,
          child: FloatingActionButton(
            heroTag: "btnMenu",
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: Icon(Icons.menu),
            onPressed: () {
              // Abre o menu lateral
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),

        // CAMADA 3: Botão Próximo (Inferior Direito)
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: "btnNext",
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