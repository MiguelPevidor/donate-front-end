import 'package:flutter/material.dart';
import '../components/MyTextField.dart'; // Verifique se o caminho está correto

class EditarDadosPage extends StatefulWidget {
  @override
  _EditarDadosPageState createState() => _EditarDadosPageState();
}

class _EditarDadosPageState extends State<EditarDadosPage> {
  // Controladores para os campos
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  
  // Exemplo de campo específico (CPF ou CNPJ)
  final _documentoController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    // AQUI: No futuro, você preenche os controllers com os dados do usuário logado
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
            // Foto do usuário (opcional para editar)
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 18,
                      child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Campos de Texto (Usando seu componente)
            // Adapte os parâmetros conforme seu MyTextField espera (label, hint, controller, etc)
            MyTextField(
              controller: _nomeController,
              hintText: 'Nome Completo',
              obscureText: false,
            ),
            SizedBox(height: 10),
            
            MyTextField(
              controller: _emailController,
              hintText: 'E-mail',
              obscureText: false,
            ),
             SizedBox(height: 10),

            MyTextField(
              controller: _telefoneController,
              hintText: 'Telefone',
              obscureText: false,
            ),
             SizedBox(height: 10),
            
            // Botão de Salvar
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para enviar o PUT para o Spring Boot
                _salvarDados();
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

  void _salvarDados() {
    // Aqui você chamará seu Controller/Service futuramente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados atualizados com sucesso! (Simulação)')),
    );
    Navigator.pop(context); // Volta para o mapa
  }
}