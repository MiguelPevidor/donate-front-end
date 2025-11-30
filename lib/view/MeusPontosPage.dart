import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/GerenciarPontosController.dart';
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Vai para tela de criar
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => FormularioPontoPage(controller: _controller))
          );
        },
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) return Center(child: CircularProgressIndicator());
          
          if (_controller.meusPontos.isEmpty) {
             return Center(child: Text("Nenhum ponto de coleta cadastrado."));
          }

          return ListView.builder(
            itemCount: _controller.meusPontos.length,
            itemBuilder: (context, index) {
              final ponto = _controller.meusPontos[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.blue),
                  title: Text(ponto.endereco.logradouro),
                  subtitle: Text("${ponto.horarioFuncionamento}\nCapacidade: ${ponto.capacidadeMaxima}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                           Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => FormularioPontoPage(
                              controller: _controller, 
                              pontoEdicao: ponto
                            ))
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarExclusao(ponto.id!),
                      ),
                    ],
                  ),
                ),
              );
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
        content: Text("Tem certeza que deseja apagar este ponto?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancelar")),
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