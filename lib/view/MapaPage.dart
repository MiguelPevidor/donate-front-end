import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/MapaController.dart';
import '../components/menuLateral.dart';
class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late MapaController _controle;
  late Future<List<Marker>> future;
  
  // Chave para controlar o Scaffold (abrir o drawer via botão flutuante)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    future = _carregarDadosEProcessarMarkers();
  }

  Future<List<Marker>> _carregarDadosEProcessarMarkers() async {
    try {
      await _controle.buscarInstituicoes();
      return _controle.obterMarkers();
    } catch (e) {
      print("Erro ao carregar dados: $e");
      throw Exception('Falha ao carregar marcadores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Necessário para o botão flutuante funcionar
      drawer: MenuLateral(), // O seu menu lateral novo
      
      appBar: AppBar(
        title: const Text('Mapa de Usuários'),
        // automaticallyImplyLeading: false, // Descomente se quiser sumir com o ícone padrão da AppBar
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
        // Camada 1: O Mapa
        Container(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _controle.obterPosicaoInicial(),
              zoom: 17,
            ),
            markers: _controle.markers!,
            onMapCreated: _onMapCreated,
            zoomControlsEnabled: false, // Oculta zoom padrão para limpar a tela
          ),
        ),

        // Camada 2: Botão do Menu Lateral (Topo Esquerdo)
        Positioned(
          top: 20,
          left: 20,
          child: FloatingActionButton(
            heroTag: "btnMenu", // Tag única
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: Icon(Icons.menu),
            onPressed: () {
              // Abre o menu lateral
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),

        // Camada 3: Botão Próximo (Inferior)
        Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            heroTag: "btnNext", // Tag única
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