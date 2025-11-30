import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Componentes e Controllers
import 'package:donate/components/menuLateral.dart';
import 'package:donate/model/PontoDeColeta.dart';
import 'package:donate/controllers/MapaController.dart';
import 'package:donate/view/MeusPontosPage.dart';

// Seus Componentes Novos
import 'package:donate/view/MapaPesquisaSheet.dart';
import 'package:donate/view/PontoColetaCard.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late MapaController _controle;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  late Future<void> _futureInicializacao;
  bool _localizacaoAtiva = false;
  bool _isLoadingFiltro = false;
  List<String> _idsSelecionados = [];
  PontoDeColeta? _pontoSelecionado;

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    
    _futureInicializacao = _controle.inicializarDados();
    _verificarPermissoes();

    // --- MUDANÇA PRINCIPAL AQUI ---
    // A View apenas chama o controller e aguarda a resposta boolean
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       bool precisaCadastrar = await _controle.verificarSePrecisaCadastrarPonto();
       if (precisaCadastrar && mounted) {
         _mostrarDialogCadastro();
       }
    });
  }

  void _atualizarMapaAoVoltar() {
    setState(() {
      _futureInicializacao = _controle.inicializarDados();
    });
  }

  Future<void> _verificarPermissoes() async {
    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) return;

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) return;
    }
    if (permissao == LocationPermission.deniedForever) return;

    if (permissao == LocationPermission.whileInUse || 
        permissao == LocationPermission.always) {
      setState(() { _localizacaoAtiva = true; });
      _controle.centralizarNoUsuario();
    }
  }

  void _mostrarDialogCadastro() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Bem-vindo!"),
        content: const Text("Você é uma instituição nova e ainda não possui pontos de coleta cadastrados.\n\nDeseja cadastrar um agora?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Agora não")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => MeusPontosPage())
              );
              _atualizarMapaAoVoltar(); 
            },
            child: const Text("Sim, cadastrar"),
          ),
        ],
      ),
    );
  }

  void _filtrar(String idItem, bool selected) async {
    setState(() {
      if (selected) {
        _idsSelecionados.add(idItem);
      } else {
        _idsSelecionados.remove(idItem);
      }
      _isLoadingFiltro = true;
      _pontoSelecionado = null; 
    });

    await _controle.buscarPontosPorFiltro(_idsSelecionados);

    setState(() {
      _isLoadingFiltro = false;
    });

    if (_controle.pontos.isNotEmpty && _sheetController.isAttached) {
       _sheetController.animateTo(0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _onPontoSelectedNaLista(PontoDeColeta ponto) {
    if (ponto.endereco.latitude != null && ponto.endereco.longitude != null) {
      _controle.irParaPonto(ponto.endereco.latitude!, ponto.endereco.longitude!);
      setState(() {
        _pontoSelecionado = ponto;
      });
      _sheetController.animateTo(0.45, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuLateral(onAtualizarMapa: _atualizarMapaAoVoltar),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      
      body: FutureBuilder<void>(
        future: _futureInicializacao,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _conteudoMapa();
        },
      ),
    );
  }

  Widget _conteudoMapa() {
    return Stack(
      children: <Widget>[
        // MAPA
        AnimatedBuilder(
          animation: _controle,
          builder: (context, _) {
            Set<Marker> markersComClique = _controle.markers.map((m) {
              return m.copyWith(
                onTapParam: () {
                  try {
                    final pontoClicado = _controle.pontos.firstWhere(
                      (p) => (p.id ?? p.hashCode.toString()) == m.markerId.value
                    );
                    setState(() => _pontoSelecionado = pontoClicado);
                    _sheetController.animateTo(0.45, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  } catch (e) {
                    print("Ponto não encontrado: ${m.markerId}");
                  }
                }
              );
            }).toSet();

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _controle.obterPosicaoInicial(),
                zoom: 15,
              ),
              markers: markersComClique,
              onMapCreated: _controle.onMapCreated,
              zoomControlsEnabled: false,
              myLocationEnabled: _localizacaoAtiva, 
              myLocationButtonEnabled: false, 
              padding: const EdgeInsets.only(bottom: 140),
              onTap: (_) {
                setState(() => _pontoSelecionado = null);
                _sheetController.animateTo(0.15, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
              },
            );
          }
        ),

        // BOTÃO MENU
        Positioned(
          top: 50, left: 20,
          child: FloatingActionButton(
            heroTag: "btnMenu",
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),

        // BOTÃO MEU LOCAL
        Positioned(
          bottom: 140, right: 20,
          child: FloatingActionButton(
            heroTag: "btnMeuLocal",
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            child: const Icon(Icons.my_location),
            onPressed: () => _controle.centralizarNoUsuario(),
          ),
        ),

        // SHEET DESLIZANTE
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.15,
          minChildSize: 0.15,
          maxChildSize: 0.6,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    if (_pontoSelecionado != null)
                      PontoColetaCard(
                        ponto: _pontoSelecionado!,
                        onFechar: () => setState(() => _pontoSelecionado = null),
                      )
                    else
                      MapaPesquisaSheet(
                        searchController: _searchController,
                        tiposItens: _controle.tiposItens,
                        idsSelecionados: _idsSelecionados,
                        pontosEncontrados: _controle.pontos,
                        isLoading: _isLoadingFiltro,
                        onFiltroChanged: _filtrar,
                        onPontoSelected: _onPontoSelectedNaLista,
                        onSearchTap: () => _sheetController.animateTo(0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}