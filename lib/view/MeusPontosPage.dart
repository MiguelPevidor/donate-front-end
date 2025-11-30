import 'package:flutter/material.dart';
import '../controllers/GerenciarPontosController.dart';
import '../components/MyInfoCard.dart'; // Importando o novo componente
import 'FormularioPontoPage.dart';

class MeusPontosPage extends StatefulWidget {
  @override
  _MeusPontosPageState createState() => _MeusPontosPageState();
}

class _MeusPontosPageState extends State<MeusPontosPage> {
  final GerenciarPontosController _controller = GerenciarPontosController();

  @override
  void initState() {
    super.initState();
    _controller.carregarDadosIniciais();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meus Pontos de Coleta")),
      
      // Botão Flutuante para Adicionar Novo Ponto
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Vai para tela de criar e espera voltar
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => FormularioPontoPage(controller: _controller))
          );
          // O controller recarrega automaticamente se você chamar carregarDados no retorno, 
          // mas o método salvar já faz isso no controller.
        },
      ),
      
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 1. Loading
          if (_controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          // 2. Lista Vazia
          if (_controller.meusPontos.isEmpty) {
             return Center(child: Text("Nenhum ponto de coleta cadastrado."));
          }

          // 3. Lista de Pontos
          return ListView.builder(
            padding: EdgeInsets.only(top: 8, bottom: 80), // Espaço para não cobrir o botão +
            itemCount: _controller.meusPontos.length,
            itemBuilder: (context, index) {
              final ponto = _controller.meusPontos[index];
              
              // --- USO DO COMPONENTE GENÉRICO (CORREÇÃO) ---
              return MyInfoCard(
                title: ponto.endereco.logradouro.isNotEmpty 
                    ? ponto.endereco.logradouro 
                    : "Endereço sem rua",
                
                subtitle: "${ponto.horarioFuncionamento}\nCapacidade: ${ponto.capacidadeMaxima} itens",
                
                icon: Icons.location_on,
                iconColor: Colors.blueAccent,
                
                // Ação de Editar
                onEdit: () {
                   Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => FormularioPontoPage(
                      controller: _controller, 
                      pontoEdicao: ponto
                    ))
                  );
                },
                
                // Ação de Excluir
                onDelete: () => _confirmarExclusao(ponto.id!),
              );
              // ---------------------------------------------
            },
          );
        },
      ),
    );
  }

  void _confirmarExclusao(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Excluir"),
        content: Text("Tem certeza que deseja apagar este ponto de coleta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("Cancelar")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _controller.deletar(id);
            }, 
            child: Text("Excluir", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}