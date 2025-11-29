import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:donate/view/EditarDadosPage.dart';
import 'package:donate/controllers/LoginController.dart';
import 'package:donate/services/AuthService.dart';

class MenuLateral extends StatefulWidget {
  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  final LoginController _loginController = LoginController();
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  // Variáveis para exibir no cabeçalho
  String _nomeUsuario = "Carregando...";
  String _emailUsuario = "...";

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      // 1. Recupera o Token e o ID salvos no login
      String? token = await _storage.read(key: 'token');
      String? userId = await _storage.read(key: 'userId'); // Certifique-se que salvou 'userId' no LoginController

      if (token != null && userId != null) {
        // 2. Chama a API para pegar os dados frescos
        final dados = await _authService.getUsuario(userId, token);

        // 3. Atualiza a tela (setState)
        if (mounted) {
          setState(() {
            // O backend retorna: { "login": "...", "email": "...", ... }
            _nomeUsuario = dados['login'] ?? "Usuário";
            _emailUsuario = dados['email'] ?? "Sem email";
          });
        }
      } else {
        setState(() {
          _nomeUsuario = "Usuário Deslogado";
          _emailUsuario = "";
        });
      }
    } catch (e) {
      print("Erro ao carregar usuário no menu: $e");
      if (mounted) {
        setState(() {
          _nomeUsuario = "Erro ao carregar";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Cabeçalho com dados dinâmicos
          UserAccountsDrawerHeader(
            accountName: Text(_nomeUsuario),
            accountEmail: Text(_emailUsuario),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _nomeUsuario.isNotEmpty ? _nomeUsuario[0].toUpperCase() : "U",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          
          // Item: Gerenciar Dados
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Gerenciar meus dados'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditarDadosPage()),
              );
            },
          ),
          
          // Item: Sair
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