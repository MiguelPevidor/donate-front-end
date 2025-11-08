import 'package:donate/components/MyTextField.dart';
import 'package:flutter/material.dart';

// 1. (Opcional, mas recomendado) Crie um enum para os tipos de usuário.
// É mais seguro e limpo do que usar Strings.
enum UserType { doador, instituicao }

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  // Variável de estado para "lembrar" a seleção atual.
  UserType _selectedUserType = UserType.doador;

  // Controladores para os campos de texto
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _missaoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _nomeInstituicaoController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _loginController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _missaoController.dispose();
    _cnpjController.dispose();
    _nomeInstituicaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Método para construir a AppBar
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserTypeSelector(), // Método para o SegmentedButton
              const SizedBox(height: 30),
              _buildDynamicFields(), // Método para os campos dinâmicos
              const SizedBox(height: 30),
              _buildRegisterButton(), // Método para o botão de cadastro
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUÇÃO DE UI ---

  /// Constrói a AppBar da página de cadastro.
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Cadastrar Novo Usuário')
    );
  }

  /// Constrói o SegmentedButton para selecionar o tipo de usuário Doador/Instituição.
  Widget _buildUserTypeSelector() {
    return SegmentedButton<UserType>(
      segments: const [
        ButtonSegment(
          value: UserType.doador,
          label: Text('Doador'),
          icon: Icon(Icons.person),
        ),
        ButtonSegment(
          value: UserType.instituicao,
          label: Text('Instituição'),
          icon: Icon(Icons.business),
        ),
      ],
      selected: <UserType>{_selectedUserType},
      onSelectionChanged: (Set<UserType> newSelection) {
        setState(() {
          _selectedUserType = newSelection.first;
        });
      },
    );
  }

  /// Constrói os campos de formulário que mudam dinamicamente
  /// com base no tipo de usuário selecionado.
  Widget _buildDynamicFields() {
    switch (_selectedUserType) {
      case UserType.doador:
        return _buildDoadorFields();
      case UserType.instituicao:
        return _buildInstituicaoFields();
    }
  }

  Widget _buildUsuarioFields() {
    return Column(
      children: [
        MyTextField(
          controller: _telefoneController,
          labelText: 'Telefone',
        ),
        MyTextField(
          controller: _emailController,
          labelText: 'Email',
        ),
        MyTextField(
            controller: _loginController,
            labelText: "login"
        ),
        MyTextField(
          controller: _senhaController,
          obscureText: true,
          labelText: 'Senha',
        ),
      ]
    );
  }


  /// Constrói os campos de texto específicos para um Doador.
  Widget _buildDoadorFields() {
    return Column(
      children: [
        MyTextField(
          controller: _nomeController,
          labelText: "Nome Completo",
        ),
        MyTextField(
          controller: _cpfController,
          labelText: 'CPF',
        ),
        _buildUsuarioFields()
      ],
    );
  }

  /// Constrói os campos de texto específicos para uma Instituição.
  Widget _buildInstituicaoFields() {
    return Column(
      children: [
        MyTextField(
          controller: _nomeInstituicaoController,
          labelText: 'Nome da Instituição',
        ),
        MyTextField(
          controller: _missaoController,
          labelText: 'Missão',
        ),
        MyTextField(
          controller: _cnpjController,
          labelText: 'CNPJ',
        ),
        _buildUsuarioFields()
      ],
    );
  }

  /// Constrói o botão "Cadastrar".
  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () {
        // Lógica para salvar
        if (_selectedUserType == UserType.doador) {
          print("Salvando Doador: ${_nomeController.text}");
          // Aqui você chamaria sua API de backend para Doador
        } else {
          print("Salvando Instituição: ${_nomeInstituicaoController.text}");
          // Aqui você chamaria sua API de backend para Instituição
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Cadastrar',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}