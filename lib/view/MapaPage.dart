import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Imports do Projeto
import 'package:donate/components/menuLateral.dart';
import 'package:donate/model/Item.dart';
import '../controllers/MapaController.dart';
import '../services/PontoColetaService.dart';
import 'MeusPontosPage.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  // --- CONTROLADORES ---
  late MapaController _controle;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Controladores da UI do Colega (Pesquisa e Sheet)
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // --- ESTADO ---
  late Future<void> _futureInicializacao; // Controla o carregamento inicial
  bool _localizacaoAtiva = false;
  bool _isLoadingFiltro = false;
  
  // Lista de IDs para filtro
  List<String> _idsSelecionados = [];

  @override
  void initState() {
    super.initState();
    _controle = MapaController();
    
    _futureInicializacao = _controle.inicializarDados();
    
    // 2. Permissões de GPS
    _verificarPermissoes();

    // 3. Verifica Instituição Nova - Sua Lógica
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarInstituicaoSemPontos();
    });
  }

  // --- MÉTODOS DE ATUALIZAÇÃO (Sua Lógica) ---
  void _atualizarMapaAoVoltar() {
    setState(() {
      // Recarrega tudo ao voltar da tela de edição
      _futureInicializacao = _controle.inicializarDados();
    });
  }

  // --- PERMISSÕES (Unificado) ---
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

  // --- VERIFICAÇÃO INSTITUIÇÃO (Sua Lógica) ---
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

  // --- FILTRO (Lógica do Colega) ---
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

    // Abre a sheet para mostrar resultados
    if (_controle.pontos.isNotEmpty && _sheetController.isAttached) {
       _sheetController.animateTo(0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuLateral(
        onAtualizarMapa: _atualizarMapaAoVoltar, 
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Evita que o teclado empurre o mapa
      
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
        // 1. MAPA
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
          
          // Padding para os controles do Google não ficarem embaixo da Sheet
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

        // 3. BOTÃO MEU LOCAL (Sem o btnNext)
        Positioned(
          bottom: 140, // Acima da Sheet minimizada
          right: 20,
          child: FloatingActionButton(
            heroTag: "btnMeuLocal",
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            child: const Icon(Icons.my_location),
            onPressed: () => _controle.centralizarNoUsuario(),
          ),
        ),

        // 4. PAINEL DESLIZANTE (Pesquisa e Lista) - UI do Colega
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
              // Puxador
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

              // CHIPS DE FILTRO (Horizontal)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _controle.tiposItens.map((Item item) {
                    // ID Seguro (Sua model tem id nullable, a do colega não. Usamos toString para garantir)
                    final String idStr = item.id.toString(); 
                    final isSelected = _idsSelecionados.contains(idStr);
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(item.nomeItem),
                        selected: isSelected,
                        selectedColor: Colors.teal[100],
                        checkmarkColor: Colors.teal,
                        onSelected: (bool selected) {
                          _filtrar(idStr, selected);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 30),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Pontos de Coleta Próximos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),

              // LISTA DE RESULTADOS
              if (_isLoadingFiltro)
                 const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_controle.pontos.isEmpty)
                 const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Nenhum local encontrado.")))
              else
                 ..._controle.pontos.map((ponto) {
                   
                  // ADAPTAÇÃO: Usamos os campos do SEU modelo (Endereco)
                  // para preencher a lista visual criada pelo colega.
                  
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    // Título: Logradouro (pois não temos 'nome' no modelo)
                    title: Text(ponto.endereco.logradouro.isNotEmpty 
                        ? ponto.endereco.logradouro 
                        : "Ponto de Coleta"),
                    
                    subtitle: Text(ponto.horarioFuncionamento),
                    
                    onTap: () {
                      // Usamos Lat/Long do endereço
                      if (ponto.endereco.latitude != null && ponto.endereco.longitude != null) {
                        _controle.irParaPonto(ponto.endereco.latitude!, ponto.endereco.longitude!);
                        // Minimiza a sheet para ver o mapa
                        _sheetController.animateTo(0.15, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      }
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