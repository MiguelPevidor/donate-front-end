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
    
    // 1. Carrega dados (Chips + Pontos) - Lógica do Colega
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