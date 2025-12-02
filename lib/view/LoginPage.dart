import 'package:donate/components/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:donate/controllers/LoginController.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // Instancia o Controller de Login
  final LoginController _loginController = LoginController();

    // TextControllers
    final _loginTextController = TextEditingController();
    final _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela para definir a altura do cartão
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final cardHeight = screenHeight * 0.75; // Cartão ocupará 75% da altura


    return Scaffold(
      backgroundColor: Colors.blue[600], // Cor de fundo principal
      body: Stack(
        children: [
          // CAMADA 1: Fundo (implícito pelo Scaffold.backgroundColor)

          // CAMADA 2: O Cartão Branco de Login
          // Chamamos o método que constrói o cartão
          _buildLoginCard(cardHeight),
        ],
      ),
    );
  }


  /// Constrói o cartão branco principal que contém o formulário.
  Widget _buildLoginCard(double cardHeight) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: cardHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        // SingleChildScrollView para evitar overflow quando o teclado aparecer
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            // A coluna principal do formulário
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),

                //campo de entrada do email
                MyTextField(
                    controller: _loginTextController,
                    labelText: "Login"
                ),

                //campo de entrada da senha
                MyTextField(
                    controller: _passwordTextController,
                  labelText: "Senha",
                    obscureText: true,
                ),

                // _buildOptionsRow(),
                _buildLoginButton(),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o cabeçalho "Welcome back"
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Bem Vindo!",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }


  // /// Constrói a linha com "Manter conectado" e "Esqueceu sua senha?"
  // Widget _buildOptionsRow() {
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Row(
  //             children: [
  //               Checkbox(value: true, onChanged: (val) {}),
  //               const Text("Manter conectado"),
  //             ],
  //           ),
  //           TextButton(
  //             onPressed: () {},
  //             child: const Text("Esqueceu sua senha?"),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 30),
  //     ],
  //   );
  // }

  /// Constrói o botão principal de login
  Widget _buildLoginButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ValueListenableBuilder escuta se está carregando ou não
        ValueListenableBuilder<bool>(
          valueListenable: _loginController.isLoading,
          builder: (context, isLoading, child) {
            return ElevatedButton(
              onPressed: isLoading 
                  ? null // Desabilita o botão se estiver carregando
                  : () {
                      // CHAMA O MÉTODO DO CONTROLLER
                      _loginController.logar(
                        context,
                        _loginTextController.text,
                        _passwordTextController.text,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) // Mostra spinner
                  : const Text(
                      "Login",
                      style: TextStyle(fontSize: 18),
                    ),
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  /// Constrói o link final para cadastro "Não tem uma conta?"
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Não tem uma conta?"),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, "/cadastroUsuario");
          },
          child: const Text("Cadastre-se"),
        ),
      ],
    );
  }
}