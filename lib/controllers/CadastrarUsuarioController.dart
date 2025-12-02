import 'package:flutter/material.dart';
import '../services/CadastrarUsuarioService.dart';
import '../view/CadastroUsuarioPage.dart'; // Importa o Enum UserType
import '../model/Doador.dart';
import '../model/Instituicao.dart';

class CadastrarUsuarioController extends ChangeNotifier {
  final CadastrarUsuarioService _service = CadastrarUsuarioService();
  
  bool isLoading = false;

  Future<bool> cadastrar({
    required BuildContext context,
    required String nome,
    required String email,
    required String senha,
    required String documento,
    required String telefone,
    required String missao,
    required UserType tipo,
  }) async {
    isLoading = true;
    notifyListeners();

    // 1. Limpeza das Máscaras (Remove pontos, traços, parênteses)
    String docLimpo = documento.replaceAll(RegExp(r'[^0-9]'), '');
    String telLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      if (tipo == UserType.doador) {
        // --- CADASTRO DE DOADOR ---
        if (docLimpo.length != 11) {
          throw Exception("CPF inválido (tamanho incorreto).");
        }

        Doador novoDoador = Doador(
          nome: nome,
          cpf: docLimpo, // Envia limpo
          telefone: telLimpo,
          email: email,
          login: email, // Usando email como login
          senha: senha,
        );

        // O Service original usa um Map genérico ou métodos específicos?
        // Assumindo que você ajustou o Service para métodos tipados 
        // ou usamos o método genérico 'registrarUsuario' convertendo para JSON.
        
        // Opção A: Se o Service espera um Map (conforme arquivos anteriores):
        /*
        await _service.registrarUsuario({
           "nome": nome,
           "email": email,
           "senha": senha,
           "cpf": docLimpo,
           "telefone": telLimpo,
           "tipo": "DOADOR"
        });
        */

        // Opção B: Se você criou métodos específicos no Service (Recomendado):
        await _service.cadastrarDoador(novoDoador);

      } else {
        // --- CADASTRO DE INSTITUIÇÃO ---
        if (docLimpo.length != 14) {
          throw Exception("CNPJ inválido (tamanho incorreto).");
        }

        Instituicao novaInst = Instituicao(
          nomeInstituicao: nome,
          cnpj: docLimpo, // Envia limpo
          missao: missao,
          telefone: telLimpo,
          email: email,
          login: email,
          senha: senha,
        );

        await _service.cadastrarInstituicao(novaInst);
      }

      _mostrarSnack(context, "Cadastro realizado com sucesso!", Colors.green);
      return true;

    } catch (e) {
      print("Erro no cadastro: $e");
      _mostrarSnack(context, "Erro: ${e.toString().replaceAll('Exception:', '')}", Colors.red);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _mostrarSnack(BuildContext context, String msg, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: cor)
    );
  }
}