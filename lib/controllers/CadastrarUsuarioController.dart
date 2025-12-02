import 'package:flutter/material.dart';
import '../model/Doador.dart'; // Ajuste o import conforme seu projeto
import '../model/Instituicao.dart'; // Ajuste o import conforme seu projeto
import '../services/CadastrarUsuarioService.dart'; // Ajuste o import

class CadastrarUsuarioController {
  final CadastrarUsuarioService _service = CadastrarUsuarioService();
  
  // Notifica a tela se está carregando
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> cadastrarDoador(BuildContext context, Doador doador) async {
    isLoading.value = true;
    try {
      // LIMPEZA DAS MÁSCARAS (Remove pontuações)
      String cpfLimpo = doador.cpf.replaceAll(RegExp(r'[^0-9]'), '');
      String telLimpo = doador.telefone.replaceAll(RegExp(r'[^0-9]'), '');

      // Cria um novo objeto com os dados limpos
      Doador doadorFinal = Doador(
        id: doador.id,
        nome: doador.nome,
        cpf: cpfLimpo,
        telefone: telLimpo,
        email: doador.email,
        login: doador.login,
        senha: doador.senha,
      );

      await _service.cadastrarDoador(doadorFinal);
      _mostrarSucesso(context, "Doador cadastrado com sucesso!");
      Navigator.pop(context); 
    } catch (e) {
      _mostrarErro(context, "Erro ao cadastrar: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cadastrarInstituicao(BuildContext context, Instituicao instituicao) async {
    isLoading.value = true;
    try {
      // LIMPEZA DAS MÁSCARAS
      String cnpjLimpo = instituicao.cnpj.replaceAll(RegExp(r'[^0-9]'), '');
      String telLimpo = instituicao.telefone.replaceAll(RegExp(r'[^0-9]'), '');

      // Cria um novo objeto com os dados limpos
      Instituicao instituicaoFinal = Instituicao(
        id: instituicao.id,
        nomeInstituicao: instituicao.nomeInstituicao,
        missao: instituicao.missao,
        cnpj: cnpjLimpo,
        telefone: telLimpo,
        email: instituicao.email,
        login: instituicao.login,
        senha: instituicao.senha
      );

      await _service.cadastrarInstituicao(instituicaoFinal);
      _mostrarSucesso(context, "Instituição cadastrada com sucesso!");
      Navigator.pop(context);
    } catch (e) {
      _mostrarErro(context, "Erro ao cadastrar: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _mostrarErro(BuildContext context, String msg) {
    // Remove "Exception:" da mensagem para ficar mais limpo pro usuário
    String msgLimpa = msg.replaceAll("Exception:", "").trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msgLimpa), backgroundColor: Colors.red)
    );
  }

  void _mostrarSucesso(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green)
    );
  }
}