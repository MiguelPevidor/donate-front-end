import 'package:flutter/material.dart';
import 'package:donate/services/AuthService.dart';
import 'package:donate/controllers/SessionController.dart'; // <--- Importe o novo controller

class LoginController {
  final AuthService _authService = AuthService();
  // Removemos o FlutterSecureStorage daqui, pois o SessionController já cuida disso

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> logar(BuildContext context, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _mostrarErro(context, "Preencha todos os campos");
      return;
    }

    isLoading.value = true;

    try {
      // 1. Chama a API
      final resultado = await _authService.login(email, password);
      final token = resultado['token'];

      // 2. Usa o SessionController para salvar e decodificar
      await SessionController().login(token);

      // Debug (opcional)
      print("Login Sucesso. Usuário: ${SessionController().userId} | Role: ${SessionController().userRole}");

      // 3. Navegação
      Navigator.pushReplacementNamed(context, "/homePage"); 

    } catch (e) {
      _mostrarErro(context, e.toString().replaceAll("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  void _mostrarErro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }
   
  Future<void> logout(BuildContext context) async {
    // Chama o logout centralizado
    await SessionController().logout();
    
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/', 
      (route) => false 
    );
  }
}