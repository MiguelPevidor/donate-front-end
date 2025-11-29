import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/GerenciarDadosService.dart';
import '../model/Doador.dart';
import '../model/Instituicao.dart';

class EditarDadosController {
  final GerenciarDadosService _service = GerenciarDadosService();
  final _storage = const FlutterSecureStorage();

  // Controladores de texto
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final extraController = TextEditingController(); // CPF (Doador) ou Missão (Instituição)
  final documentoController = TextEditingController(); // CNPJ (Instituição)

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  String? userId;
  String? userRole;
  
  // Guardar objetos originais para manter dados não editáveis (como login)
  Doador? _doadorAtual;
  Instituicao? _instituicaoAtual;

  Future<void> carregarDados(BuildContext context) async {
    isLoading.value = true;
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) throw Exception("Token não encontrado");

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      // Ajuste aqui conforme a chave que você usa no Backend para o ID
      userId = decodedToken['id'] ?? decodedToken['userId'] ?? decodedToken['sub']; 
      userRole = decodedToken['role']; // 'DOADOR' ou 'INSTITUICAO' (verifique se é maiúsculo ou minúsculo no token)

      if (userId == null) throw Exception("ID do usuário não encontrado no token");

      // Normalizando a role para comparação (maiúsculo)
      String roleUpper = userRole?.toUpperCase() ?? '';

      if (roleUpper == 'DOADOR' || roleUpper == 'ROLE_DOADOR') {
        _doadorAtual = await _service.buscarDoador(userId!);
        nomeController.text = _doadorAtual!.nome;
        emailController.text = _doadorAtual!.email;
        telefoneController.text = _doadorAtual!.telefone;
        extraController.text = _doadorAtual!.cpf; // Usando extra para CPF
      } 
      else if (roleUpper == 'INSTITUICAO' || roleUpper == 'ROLE_INSTITUICAO') {
        _instituicaoAtual = await _service.buscarInstituicao(userId!);
        nomeController.text = _instituicaoAtual!.nomeInstituicao;
        emailController.text = _instituicaoAtual!.email;
        telefoneController.text = _instituicaoAtual!.telefone;
        extraController.text = _instituicaoAtual!.missao; // Usando extra para Missão
        documentoController.text = _instituicaoAtual!.cnpj;
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

      if (roleUpper.contains('DOADOR')) {
        // Monta objeto atualizado mantendo o que não mudou (login, senha null)
        Doador doadorEditado = Doador(
          id: userId,
          nome: nomeController.text,
          email: emailController.text,
          telefone: telefoneController.text,
          cpf: extraController.text, // CPF
          login: _doadorAtual?.login ?? '', // Login geralmente não muda na edição simples
          senha: null, // Não enviamos senha se não for alterar
        );
        await _service.atualizarDoador(userId!, doadorEditado);
      } 
      else if (roleUpper.contains('INSTITUICAO')) {
        Instituicao instituicaoEditada = Instituicao(
          id: userId,
          nomeInstituicao: nomeController.text,
          email: emailController.text,
          telefone: telefoneController.text,
          missao: extraController.text, // Missão
          cnpj: documentoController.text, // CNPJ
          login: _instituicaoAtual?.login ?? '',
          senha: null,
        );
        await _service.atualizarInstituicao(userId!, instituicaoEditada);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dados atualizados com sucesso!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Volta para a tela anterior

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }
}