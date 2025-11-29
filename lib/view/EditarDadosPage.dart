import 'package:flutter/material.dart';
import '../components/MyTextField.dart';
import '../controllers/EditarDadosController.dart';

class EditarDadosPage extends StatefulWidget {
  @override
  _EditarDadosPageState createState() => _EditarDadosPageState();
}

class _EditarDadosPageState extends State<EditarDadosPage> {
  final EditarDadosController _controller = EditarDadosController();

  @override
  void initState() {
    super.initState();
    // Carrega os dados assim que a tela abre
    _controller.carregarDados(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciar Dados"),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Define rótulos baseados no tipo de usuário
          bool isInstituicao = _controller.userRole?.toUpperCase().contains('INSTITUICAO') ?? false;
          String labelExtra = isInstituicao ? 'Missão' : 'CPF';
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      isInstituicao ? Icons.apartment : Icons.person, 
                      size: 50, 
                      color: Colors.grey[600]
                    ),
                  ),
                ),
                SizedBox(height: 20),

                MyTextField(
                  controller: _controller.nomeController,
                  labelText: isInstituicao ? 'Nome da Instituição' : 'Nome Completo',
                  obscureText: false,
                ),

                MyTextField(
                  controller: _controller.emailController,
                  labelText: 'E-mail',
                  obscureText: false,
                ),

                MyTextField(
                  controller: _controller.telefoneController,
                  labelText: 'Telefone',
                  obscureText: false,
                ),

                // Campo Dinâmico (CPF ou Missão)
                MyTextField(
                  controller: _controller.extraController,
                  labelText: labelExtra,
                  obscureText: false,
                ),

                // Campo extra apenas para Instituição (CNPJ)
                if (isInstituicao)
                  MyTextField(
                    controller: _controller.documentoController,
                    labelText: 'CNPJ',
                    obscureText: false,
                    // Geralmente CNPJ não se edita, talvez queira por readOnly: true no MyTextField se suportar
                  ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _controller.salvarDados(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Salvar Alterações"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}