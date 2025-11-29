import 'package:flutter/material.dart';
import '../view/EditarDadosPage.dart'; // Certifique-se de criar essa tela depois

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Usuário Teste"),
            accountEmail: Text("teste@donate.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("U", style: TextStyle(fontSize: 40.0)),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Gerenciar meus dados'),
            onTap: () {
              Navigator.pop(context); // Fecha o menu
              // Navega para a tela de edição (crie este arquivo depois)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditarDadosPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // Implementar logout aqui
            },
          ),
        ],
      ),
    );
  }
}