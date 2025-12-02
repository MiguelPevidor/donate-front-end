import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../components/MyTextField.dart';
import '../controllers/CadastrarUsuarioController.dart';

// Enum para tipar a seleção (Boa prática)
enum UserType { doador, instituicao }

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({Key? key}) : super(key: key);

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  // Estado inicial
  UserType _selectedUserType = UserType.doador;
  final CadastrarUsuarioController _controller = CadastrarUsuarioController();

  // Controllers de Texto
  final _nomeCtrl = TextEditingController(); // Nome ou Razão Social
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController(); // CPF ou CNPJ
  final _telefoneCtrl = TextEditingController();
  final _missaoCtrl = TextEditingController(); // Apenas Instituição

  // --- MÁSCARAS ---
  final maskCpf = MaskTextInputFormatter(
      mask: "###.###.###-##", filter: {"#": RegExp(r'[0-9]')});
  final maskCnpj = MaskTextInputFormatter(
      mask: "##.###.###/####-##", filter: {"#": RegExp(r'[0-9]')});
  final maskTel = MaskTextInputFormatter(
      mask: "(##) #####-####", filter: {"#": RegExp(r'[0-9]')});

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _documentoCtrl.dispose();
    _telefoneCtrl.dispose();
    _missaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserTypeSelector(),
            const SizedBox(height: 30),
            _buildFormFields(),
            const SizedBox(height: 30),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

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
          _documentoCtrl.clear(); // Limpa documento ao trocar tipo
        });
      },
    );
  }

  Widget _buildFormFields() {
    final isInst = _selectedUserType == UserType.instituicao;

    return Column(
      children: [
        MyTextField(
          controller: _nomeCtrl,
          labelText: isInst ? "Razão Social" : "Nome Completo",
          obscureText: false,
        ),
        
        // Campo Documento Dinâmico (CPF/CNPJ)
        MyTextField(
          controller: _documentoCtrl,
          labelText: isInst ? "CNPJ" : "CPF",
          obscureText: false,
          inputFormatters: [isInst ? maskCnpj : maskCpf],
        ),

        // Campo Missão (Apenas se for Instituição)
        if (isInst)
          MyTextField(
            controller: _missaoCtrl,
            labelText: "Missão da Instituição",
            obscureText: false,
          ),

        MyTextField(
          controller: _telefoneCtrl,
          labelText: "Telefone / Celular",
          obscureText: false,
          inputFormatters: [maskTel],
        ),

        MyTextField(
          controller: _emailCtrl,
          labelText: "E-mail (Login)",
          obscureText: false,
        ),

        MyTextField(
          controller: _senhaCtrl,
          labelText: "Senha",
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    // Usa AnimatedBuilder para reagir ao isLoading do controller
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _controller.isLoading ? null : _cadastrar,
          child: _controller.isLoading
              ? const SizedBox(
                  width: 24, 
                  height: 24, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
              : const Text('Cadastrar', style: TextStyle(fontSize: 18)),
        );
      }
    );
  }

  void _cadastrar() async {
    // Validação simples
    if (_nomeCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _senhaCtrl.text.isEmpty || _documentoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha todos os campos obrigatórios!")));
      return;
    }

    final sucesso = await _controller.cadastrar(
      context: context,
      nome: _nomeCtrl.text,
      email: _emailCtrl.text,
      senha: _senhaCtrl.text,
      documento: _documentoCtrl.text,
      telefone: _telefoneCtrl.text,
      missao: _missaoCtrl.text, // Pode ser vazio se for doador
      tipo: _selectedUserType,
    );

    if (sucesso && mounted) {
       Navigator.pop(context); // Volta para Login
    }
  }
}