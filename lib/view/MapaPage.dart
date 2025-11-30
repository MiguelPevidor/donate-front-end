import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../components/menuLateral.dart';
import '../controllers/MapaController.dart';
import '../services/PontoColetaService.dart';
import 'MeusPontosPage.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late MapaController _controle;
  late Future<List<Marker>> future; 
  
  bool _localizacaoAtiva = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    future = _carregarDados();
    _verificarPermissoes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarInstituicaoSemPontos();
    });
  }

  void _atualizarMapaAoVoltar() {
    setState(() {
      future = _carregarDados(); 
    });
  }

  Future<void> _verificarPermissoes() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.whileInUse || 
        permissao == LocationPermission.always) {
      setState(() { _localizacaoAtiva = true; });
      _controle.centralizarNoUsuario();
    }
  }

  Future<void> _verificarInstituicaoSemPontos() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String role = decodedToken['role']?.toString().toUpperCase() ?? '';
      String userId = decodedToken['id'] ?? decodedToken['userId'] ?? decodedToken['sub'];

      if (role.contains('INSTITUICAO')) {
        PontoColetaService service = PontoColetaService();
        try {
          var pontos = await service.listarPorInstituicao(userId);
          if (pontos.isEmpty) {
            _mostrarDialogCadastro();
          }
        } catch (e) {
          print("Erro ao verificar pontos iniciais: $e");
        }
      }
    }
  }

  void _mostrarDialogCadastro() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Bem-vindo!"),
        content: Text("Você é uma instituição nova e ainda não possui pontos de coleta cadastrados.\n\nDeseja cadastrar um agora?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Agora não")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => MeusPontosPage())
              );
              _atualizarMapaAoVoltar(); 
            },
            child: Text("Sim, cadastrar"),
          ),
        ],
      ),
    );
  }

  Future<List<Marker>> _carregarDados() async {
    await _controle.buscarPontosDeColeta();
    return _controle.obterMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuLateral(
        onAtualizarMapa: _atualizarMapaAoVoltar, 
      ),
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
          myLocationEnabled: _localizacaoAtiva, 
          myLocationButtonEnabled: false, 
        ),

        // Botão do Menu (Topo Esquerdo)
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
          child: FloatingActionButton(
            heroTag: "btnMeuLocal",
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.my_location, color: Colors.white),
            onPressed: () {
              _controle.centralizarNoUsuario();
            },
          ),
        ),
      ],
    );
  }
}