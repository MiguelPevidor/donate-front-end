import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../view/EditarDadosPage.dart';
import '../view/MeusPontosPage.dart';
import '../controllers/LoginController.dart';
import '../services/AuthService.dart';

class MenuLateral extends StatefulWidget {
  // 1. Adicionamos esta variável para receber a função de atualização
  final VoidCallback? onAtualizarMapa;

  // Construtor atualizado
  const MenuLateral({Key? key, this.onAtualizarMapa}) : super(key: key);

  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  final LoginController _loginController = LoginController();
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  String _nomeUsuario = "Carregando...";
  String _emailUsuario = "...";
  bool _isInstituicao = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      String? token = await _storage.read(key: 'token');
      String? userId = await _storage.read(key: 'userId'); 

      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String role = decodedToken['role']?.toString().toUpperCase() ?? '';
        
        if (mounted) {
          setState(() {
            _isInstituicao = role.contains('INSTITUICAO');
          });
        }

        if (userId != null) {
          final dados = await _authService.getUsuario(userId, token);
          if (mounted) {
            setState(() {
              _nomeUsuario = dados['login'] ?? "Usuário";
              _emailUsuario = dados['email'] ?? "Sem email";
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _nomeUsuario = "Usuário Deslogado";
            _emailUsuario = "";
            _isInstituicao = false;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar usuário no menu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_nomeUsuario),
            accountEmail: Text(_emailUsuario),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                _isInstituicao ? Icons.apartment : Icons.person,
                size: 40.0,
                color: Colors.blue,
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Gerenciar meus dados'),
            subtitle: Text('Nome, senha, contato...'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditarDadosPage()),
              );
            },
          ),

          if (_isInstituicao)
            ListTile(
              leading: Icon(Icons.store, color: Colors.green[700]),
              title: Text('Gerenciar Pontos de Coleta'),
              subtitle: Text('Adicionar ou editar locais'),
              onTap: () async {
                Navigator.pop(context); // Fecha o drawer
                
                // 2. O 'await' faz o código esperar você voltar da tela MeusPontosPage
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MeusPontosPage()),
                );

                // 3. Quando você voltar, se a função existir, ela roda e atualiza o mapa
                if (widget.onAtualizarMapa != null) {
                  widget.onAtualizarMapa!();
                }
              },
            ),

          Divider(),

          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              _loginController.logout(context);
            },
          ),
        ],
      ),
    );
  }
}