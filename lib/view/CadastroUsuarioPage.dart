import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // Certifique-se de ter importado
import '../components/MyTextField.dart';
import '../model/Doador.dart'; // Ajuste o import conforme seu projeto
import '../model/Instituicao.dart'; // Ajuste o import conforme seu projeto
import '../controllers/CadastrarUsuarioController.dart';

// Enum para os tipos de usuário (Mantido da sua estrutura)
enum UserType { doador, instituicao }

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({Key? key}) : super(key: key);

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  UserType _selectedUserType = UserType.doador;

  final CadastrarUsuarioController _controller = CadastrarUsuarioController();

  // Controllers (Mantendo todos separados conforme solicitado)
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _missaoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _nomeInstituicaoController = TextEditingController();

  // --- MÁSCARAS (Novidade) ---
  final maskCpf = MaskTextInputFormatter(
      mask: "###.###.###-##", filter: {"#": RegExp(r'[0-9]')});
  final maskCnpj = MaskTextInputFormatter(
      mask: "##.###.###/####-##", filter: {"#": RegExp(r'[0-9]')});
  final maskTel = MaskTextInputFormatter(
      mask: "(##) #####-####", filter: {"#": RegExp(r'[0-9]')});

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
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserTypeSelector(),
              const SizedBox(height: 30),
              _buildDynamicFields(),
              const SizedBox(height: 30),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUÇÃO DE UI ---

  AppBar _buildAppBar() {
    return AppBar(title: const Text('Cadastrar Novo Usuário'));
  }

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

  Widget _buildDynamicFields() {
    switch (_selectedUserType) {
      case UserType.doador:
        return _buildDoadorFields();
      case UserType.instituicao:
        return _buildInstituicaoFields();
    }
  }

  // Campos comuns (Telefone, Email, Login, Senha)
  Widget _buildUsuarioFields() {
    return Column(
      children: [
        MyTextField(
          controller: _telefoneController,
          labelText: 'Telefone',
          inputFormatters: [maskTel], // Aplica máscara de Telefone
        ),
        MyTextField(
          controller: _emailController,
          labelText: 'Email',
        ),
        MyTextField(
          controller: _loginController,
          labelText: "Login", // Campo Login separado
        ),
        MyTextField(
          controller: _senhaController,
          obscureText: true,
          labelText: 'Senha',
        ),
      ],
    );
  }

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
          inputFormatters: [maskCpf], // Aplica máscara de CPF
        ),
        _buildUsuarioFields()
      ],
    );
  }

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
          inputFormatters: [maskCnpj], // Aplica máscara de CNPJ
        ),
        _buildUsuarioFields()
      ],
    );
  }

  Widget _buildRegisterButton() {
    // Escuta o isLoading para mostrar loading no botão
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, child) {
        return ElevatedButton(
          onPressed: isLoading ? null : () => _cadastrar(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Cadastrar', style: TextStyle(fontSize: 18)),
        );
      }
    );
  }

  void _cadastrar() {
    if (_selectedUserType == UserType.doador) {
      final doador = Doador(
        nome: _nomeController.text,
        cpf: _cpfController.text, // Vai com máscara (Controller limpa)
        telefone: _telefoneController.text,
        email: _emailController.text,
        login: _loginController.text,
        senha: _senhaController.text,
      );
      
      _controller.cadastrarDoador(context, doador);

    } else {
      final instituicao = Instituicao(
        nomeInstituicao: _nomeInstituicaoController.text,
        missao: _missaoController.text,
        cnpj: _cnpjController.text, // Vai com máscara (Controller limpa)
        telefone: _telefoneController.text,
        email: _emailController.text,
        login: _loginController.text,
        senha: _senhaController.text,
      );

      _controller.cadastrarInstituicao(context, instituicao);
    }
  }
}