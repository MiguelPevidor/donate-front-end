import 'package:donate/model/Item.dart'; // <--- IMPORTANTE: Importe seu Model Item
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
  late Future<void> _futureInicializacao;
  
  // Variável para controlar se a bolinha azul deve aparecer
  bool _localizacaoAtiva = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // AGORA USAMOS UMA LISTA DE IDs (INTEIROS) PARA O FILTRO
  List<String> _idsSelecionados = [];
  bool _isLoadingFiltro = false;

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    _futureInicializacao = _controle.inicializarDados();
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

  // O filtro agora recebe o ID do item
  void _filtrar(String idItem, bool selected) async {
    setState(() {
      if (selected) {
        _idsSelecionados.add(idItem);
      } else {
        _idsSelecionados.remove(idItem);
      }
      _isLoadingFiltro = true;
    });

    // Passa a lista de IDs para o controller buscar
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
        // 1. MAPA
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

        // 2. BOTÃO MENU
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

        // 3. BOTÃO PRÓXIMO
        Positioned(
          bottom: 120, 
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

        // 4. PAINEL DE PESQUISA FLUTUANTE
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

             
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  // Itera sobre a lista de Objetos ITEM (que tem id e descricao)
                  children: _controle.tiposItens.map((Item item) {
                    
                    // Verifica se o ID deste item está na lista de selecionados
                    final isSelected = _idsSelecionados.contains(item.id);
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        // VISUAL: MOSTRA APENAS O NOME (DESCRICAO)
                        label: Text(item.nomeItem), 
                        
                        selected: isSelected,
                        selectedColor: Colors.teal[100],
                        checkmarkColor: Colors.teal,
                        onSelected: (bool selected) {
                          // LÓGICA: USA O ID PARA O FILTRO
                          _filtrar(item.id, selected);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              // -----------------------------------------------------------

              const Divider(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text("Pontos de Coleta Próximos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),

              // RESULTADOS DA LISTA
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
                    subtitle: Text(ponto.horarioFuncionamento ?? ""),
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