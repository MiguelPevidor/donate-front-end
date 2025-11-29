import 'package:flutter/material.dart';
import '../view/EditarDadosPage.dart'; // Importação da tela de edição

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Cabeçalho do Menu (Dados do Usuário Mockados por enquanto)
          UserAccountsDrawerHeader(
            accountName: Text("Usuário Teste"),
            accountEmail: Text("teste@donate.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("U", style: TextStyle(fontSize: 40.0)),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          
          // Item de Menu: Editar Dados
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Gerenciar meus dados'),
            onTap: () {
              Navigator.pop(context); // Fecha o menu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditarDadosPage()),
              );
            },
          ),
          
          // Item de Menu: Sair
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // Adicione sua lógica de logout aqui futuramente
            },
          ),
        ],
      ),
    );
  }
}