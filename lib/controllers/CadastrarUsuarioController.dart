import 'package:donate/model/Doador.dart';
import 'package:donate/model/Instituicao.dart';
import 'package:flutter/material.dart';
import 'package:donate/services/CadastrarUsuarioService.dart';

class CadastrarUsuarioController {
  final CadastrarUsuarioService _service = CadastrarUsuarioService();
  
  // Notifica a tela se está carregando
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> cadastrarDoador(BuildContext context, Doador doador) async {
    isLoading.value = true;
    try {
      await _service.cadastrarDoador(doador);
      _mostrarSucesso(context, "Doador cadastrado com sucesso!");
      Navigator.pop(context); // Volta para o login após cadastro
    } catch (e) {
      _mostrarErro(context, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cadastrarInstituicao(BuildContext context, Instituicao instituicao) async {
    isLoading.value = true;
    try {
      await _service.cadastrarInstituicao(instituicao);
      _mostrarSucesso(context, "Instituição cadastrada com sucesso!");
      Navigator.pop(context);
    } catch (e) {
      _mostrarErro(context, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _mostrarErro(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _mostrarSucesso(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }
}