import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/GerenciarDadosService.dart';
import '../model/Doador.dart';
import '../model/Instituicao.dart';

class EditarDadosController {
  final GerenciarDadosService _service = GerenciarDadosService();
  final _storage = const FlutterSecureStorage();

  // Controladores de texto existentes
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final extraController = TextEditingController(); // CPF ou Missão
  final documentoController = TextEditingController(); // CNPJ
  
  // NOVOS CONTROLADORES
  final loginController = TextEditingController();
  final senhaController = TextEditingController();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  String? userId;
  String? userRole;
  
  Doador? _doadorAtual;
  Instituicao? _instituicaoAtual;

  Future<void> carregarDados(BuildContext context) async {
    isLoading.value = true;
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) throw Exception("Token não encontrado");

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      userId = decodedToken['id'] ?? decodedToken['userId'] ?? decodedToken['sub']; 
      userRole = decodedToken['role'];

      if (userId == null) throw Exception("ID do usuário não encontrado no token");

      String roleUpper = userRole?.toUpperCase() ?? '';

      if (roleUpper.contains('DOADOR')) {
        _doadorAtual = await _service.buscarDoador(userId!);
        
        // Preenche os campos
        nomeController.text = _doadorAtual!.nome;
        emailController.text = _doadorAtual!.email;
        telefoneController.text = _doadorAtual!.telefone;
        extraController.text = _doadorAtual!.cpf;
        loginController.text = _doadorAtual!.login; // Carrega o Login
        // Senha não carregamos por segurança (fica vazia)
      } 
      else if (roleUpper.contains('INSTITUICAO')) {
        _instituicaoAtual = await _service.buscarInstituicao(userId!);
        
        // Preenche os campos
        nomeController.text = _instituicaoAtual!.nomeInstituicao;
        emailController.text = _instituicaoAtual!.email;
        telefoneController.text = _instituicaoAtual!.telefone;
        extraController.text = _instituicaoAtual!.missao;
        documentoController.text = _instituicaoAtual!.cnpj;
        loginController.text = _instituicaoAtual!.login; // Carrega o Login
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar dados: $e"), backgroundColor: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> salvarDados(BuildContext context) async {
    if (userId == null) return;
    isLoading.value = true;

    try {
      String roleUpper = userRole?.toUpperCase() ?? '';
      
      // Lógica da senha: Se estiver vazia, envia null (para não alterar)
      // Se tiver texto, envia a nova senha
      String? novaSenha = senhaController.text.isEmpty ? null : senhaController.text;

      if (roleUpper.contains('DOADOR')) {
        Doador doadorEditado = Doador(
          id: userId,
          nome: nomeController.text,
          email: emailController.text,
          telefone: telefoneController.text,
          cpf: extraController.text,
          login: loginController.text, // Login editável
          senha: novaSenha, // Nova senha ou null
        );
        await _service.atualizarDoador(userId!, doadorEditado);
      } 
      else if (roleUpper.contains('INSTITUICAO')) {
        Instituicao instituicaoEditada = Instituicao(
          id: userId,
          nomeInstituicao: nomeController.text,
          email: emailController.text,
          telefone: telefoneController.text,
          missao: extraController.text,
          cnpj: documentoController.text,
          login: loginController.text, // Login editável
          senha: novaSenha, // Nova senha ou null
        );
        await _service.atualizarInstituicao(userId!, instituicaoEditada);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dados atualizados com sucesso!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }
}