import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Adicione este import
import '../components/menuLateral.dart';
import '../controllers/MapaController.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late MapaController _controle;
  late Future<List<Marker>> future;
  
  // Variável para controlar se a bolinha azul deve aparecer
  bool _localizacaoAtiva = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    future = _carregarDados();
    _verificarPermissoes(); // Verifica permissão ao iniciar
  }

  // Novo método para checar permissão e ativar a bolinha
  Future<void> _verificarPermissoes() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.whileInUse || 
        permissao == LocationPermission.always) {
      setState(() {
        _localizacaoAtiva = true; // Ativa a bolinha azul
      });
      // Opcional: Centraliza no usuário assim que tiver permissão
      _controle.centralizarNoUsuario();
    }
  }

  Future<List<Marker>> _carregarDados() async {
    await _controle.buscarPontosDeColeta();
    return _controle.obterMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuLateral(),
      extendBodyBehindAppBar: true,
      
      body: FutureBuilder<List<Marker>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasData) {
             _controle.markers = snapshot.data!.toSet();
          }
          
          return _conteudoMapa();
        },
      ),
    );
  }

  Widget _conteudoMapa() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _controle.obterPosicaoInicial(),
            zoom: 15,
          ),
          markers: _controle.markers ?? {},
          onMapCreated: _controle.onMapCreated,
          zoomControlsEnabled: false,
          
          // --- AQUI ESTÁ O SEGREDO ---
          // Se for false, o Google Maps nem tenta desenhar a camada
          // Se for true, ele desenha a bolinha azul
          myLocationEnabled: _localizacaoAtiva, 
          // ---------------------------
          
          myLocationButtonEnabled: false, 
        ),

        Positioned(
          top: 50,
          left: 20,
          child: FloatingActionButton(
            heroTag: "btnMenu",
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "btnMeuLocal",
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.my_location, color: Colors.white),
                onPressed: () {
                  _controle.centralizarNoUsuario();
                },
              ),
              
              SizedBox(height: 15),

              FloatingActionButton(
                heroTag: "btnNext",
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                child: Icon(Icons.navigate_next),
                onPressed: () {
                  _controle.avancarProximoMarker();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}