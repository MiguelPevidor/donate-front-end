import 'dart:async';
import 'package:donate/components/menuLateral.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Importe seu controller e componentes
import '../controllers/MapaController.dart';
// import 'package:donate/model/Instituicao.dart'; // Se necessário

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late MapaController _controle;
  late Future<List<Marker>> future;
  
  // CRUCIAL: A chave para controlar o Scaffold programaticamente
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
      // Atribuímos a chave aqui
      key: _scaffoldKey, 
      
      // Adicionamos o Drawer que criamos
      drawer: MenuLateral(),
      
      appBar: AppBar(
        title: const Text('Mapa de Usuários'),
        // Se quiser remover o ícone padrão do menu da AppBar para usar só o flutuante:
        // automaticallyImplyLeading: false, 
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return FutureBuilder<List<Marker>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Erro ao carregar mapa."));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
             // Tratamento caso não venha dados, inicia vazio ou mostra msg
             _controle.markers = {};
             _controle.inicializarPosicaoAtual();
             return _conteudo();
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

  Widget _conteudo() {
    return Stack(
      children: <Widget>[
        // 1. O Mapa (Camada de fundo)
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _controle.obterPosicaoInicial(),
            zoom: 17,
          ),
          markers: _controle.markers!,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true, // Habilita o ponto azul da localização atual
          zoomControlsEnabled: false, // Remove botões de zoom padrão para limpar a tela
        ),

        // 2. Botão Flutuante do Menu (Canto Superior Esquerdo)
        Positioned(
          top: 20, 
          left: 20,
          child: FloatingActionButton(
            heroTag: "btnMenu", // Importante se tiver mais de um FAB na tela
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: Icon(Icons.menu),
            onPressed: () {
              // AQUI ESTÁ O SEGREDO: Abre o drawer usando a chave
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),

        // 3. Botão "Próximo" (Canto Inferior Direito ou Centro-Baixo)
        Positioned(
          bottom: 20,
          right: 20, // Mudei para a direita (padrão Material Design)
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