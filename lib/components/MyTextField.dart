
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class MyTextField extends StatelessWidget {
  // O controlador para ler o valor do campo de texto
  final TextEditingController controller;

  // O texto de dica (ex: "Email", "Password")
  final String labelText;

  // Define se o texto deve ser escondido (para senhas)
  final bool obscureText;

  // O espaçamento inferior
  final double bottomSpacing;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const MyTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false, 
    this.bottomSpacing = 20.0, 
    this.focusNode,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          focusNode: focusNode,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: labelText,
            // Estilos de borda (é uma boa prática definir enabledBorder e focusedBorder)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            // Fallback para outras bordas
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}