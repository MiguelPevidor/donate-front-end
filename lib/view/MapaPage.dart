import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Importante para permissões

import 'package:donate/components/menuLateral.dart';
import 'package:donate/model/Item.dart'; // Seu Model Item
import '../controllers/MapaController.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  // --- CONTROLADORES ---
  late MapaController _controle;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // --- ESTADO ---
  late Future<void> _futureInicializacao;
  bool _localizacaoAtiva = false; // Controla a bolinha azul
  bool _isLoadingFiltro = false;
  
  // Lista de IDs (Strings para garantir compatibilidade com UUID ou Int convertidos)
  List<String> _idsSelecionados = [];

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    
    // 1. Carrega dados da API (Chips + Pontos)
    _futureInicializacao = _controle.inicializarDados();
    
    // 2. Verifica permissão de GPS
    _verificarPermissoes();
  }

  // --- LÓGICA DE PERMISSÃO (Vinda do Remoto) ---
  Future<void> _verificarPermissoes() async {
    bool servicoAtivo;
    LocationPermission permissao;

    servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) return;

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) return;
    }

    if (permissao == LocationPermission.deniedForever) return;

    // Se chegou aqui, tem permissão
    setState(() {
      _localizacaoAtiva = true;
    });
    
    // Tenta focar no usuário
    _controle.centralizarNoUsuario();
  }

  // --- LÓGICA DE FILTRO ---
  void _filtrar(String idItem, bool selected) async {
    setState(() {
      if (selected) {
        _idsSelecionados.add(idItem);
      } else {
        _idsSelecionados.remove(idItem);
      }
      _isLoadingFiltro = true;
    });

    await _controle.buscarPontosPorFiltro(_idsSelecionados);

    setState(() {
      _isLoadingFiltro = false;
    });

    if (_controle.pontos.isNotEmpty && _sheetController.isAttached) {
       _sheetController.animateTo(0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuLateral(),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<void>(
        future: _futureInicializacao,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se houver erro, você pode tratar aqui
          return _conteudoMapa();
        },
      ),
    );
  }

  Widget _conteudoMapa() {
    return Stack(
      children: <Widget>[
        // 1. MAPA
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _controle.obterPosicaoInicial(),
            zoom: 15,
          ),
          markers: _controle.markers ?? {},
          onMapCreated: _controle.onMapCreated, // Passa para o controller
          zoomControlsEnabled: false,
          
          // Configuração de Localização
          myLocationEnabled: _localizacaoAtiva, 
          myLocationButtonEnabled: false, // Usaremos nosso botão customizado
          
          padding: const EdgeInsets.only(bottom: 120),
        ),

        // 2. BOTÃO MENU
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

        // 3. BOTÕES DE AÇÃO (Lateral Direita)
        Positioned(
          bottom: 140, 
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão Meu Local (Só aparece se tiver permissão)
              if (_localizacaoAtiva)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton(
                    heroTag: "btnMeuLocal",
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    child: const Icon(Icons.my_location),
                    onPressed: () => _controle.centralizarNoUsuario(),
                  ),
                ),

              // Botão Próximo Ponto
              FloatingActionButton(
                heroTag: "btnNext",
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                child: const Icon(Icons.navigate_next),
                onPressed: () => _controle.avancarProximoMarker(),
              ),
            ],
          ),
        ),

        // 4. PAINEL DE PESQUISA
        _buildFloatingSearchSheet(),
      ],
    );
  }

  Widget _buildFloatingSearchSheet() {
    return DraggableScrollableSheet(
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
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),

              // Barra de Pesquisa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Buscar...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onTap: () {
                      _sheetController.animateTo(0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("O que você deseja doar?", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[700])),
              ),
              
              const SizedBox(height: 10),

              // CHIPS (Horizontal Scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _controle.tiposItens.map((Item item) {
                    final String idStr = item.id.toString();
                    final isSelected = _idsSelecionados.contains(idStr);
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(item.nomeItem), // VISUAL: Nome
                        selected: isSelected,
                        selectedColor: Colors.teal[100],
                        checkmarkColor: Colors.teal,
                        onSelected: (bool selected) {
                          _filtrar(idStr, selected); // LÓGICA: ID
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text("Pontos de Coleta Próximos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),

              // LISTA DE RESULTADOS
              if (_isLoadingFiltro)
                 const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_controle.pontos.isEmpty)
                 const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Nenhum local encontrado.")))
              else
                 ..._controle.pontos.map((ponto) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    title: Text(ponto.nome),
                    subtitle: Text(ponto.horarioFuncionamento),
                    onTap: () {
                      _controle.irParaPonto(ponto.latitude, ponto.longitude);
                      _sheetController.animateTo(0.15, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                    },
                  );
                }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}