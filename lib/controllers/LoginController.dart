import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // <--- Importe aqui
import 'package:donate/services/AuthService.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> logar(BuildContext context, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _mostrarErro(context, "Preencha todos os campos");
      return;
    }

    isLoading.value = true;

    try {
      // Chama a API e recebe o JSON (Ex: { "token": "eyJh..." })
      final resultado = await _authService.login(email, password);
      
      final token = resultado['token']; // O token JWT criptografado

      //  Salva o Token seguro
      await _storage.write(key: 'token', value: token);

      // DECODIFICA O TOKEN para ler os dados escondidos nele
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      String role = '';
      
      if (decodedToken.containsKey('role')) {
        role = decodedToken['role']; 
      }

      // Para debugar 
      print("Token Decodificado: $decodedToken"); 
      print("Role encontrada: $role");


      // direciona para a homePage
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
}