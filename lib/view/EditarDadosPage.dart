import 'package:flutter/material.dart';
import '../components/MyTextField.dart'; 

class EditarDadosPage extends StatefulWidget {
  @override
  _EditarDadosPageState createState() => _EditarDadosPageState();
}

class _EditarDadosPageState extends State<EditarDadosPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dados simulados
    _nomeController.text = "Fulano de Tal";
    _emailController.text = "fulano@teste.com";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciar Dados"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 20),

            // CORRIGIDO: Usando labelText para compatibilidade com seu MyTextField
            MyTextField(
              controller: _nomeController,
              labelText: 'Nome Completo', 
              obscureText: false,
            ),
            
            MyTextField(
              controller: _emailController,
              labelText: 'E-mail',
              obscureText: false,
            ),

            MyTextField(
              controller: _telefoneController,
              labelText: 'Telefone',
              obscureText: false,
            ),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dados salvos com sucesso!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Salvar Alterações"),
            ),
          ],
        ),
      ),
    );
  }
}