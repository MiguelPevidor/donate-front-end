import 'package:flutter/material.dart';
import '../controllers/GerenciarPontosController.dart';
import '../model/PontoDeColeta.dart';
import '../model/Endereco.dart';
import '../components/MyTextField.dart';

class FormularioPontoPage extends StatefulWidget {
  final GerenciarPontosController controller;
  final PontoDeColeta? pontoEdicao;

  const FormularioPontoPage({Key? key, required this.controller, this.pontoEdicao}) : super(key: key);

  @override
  _FormularioPontoPageState createState() => _FormularioPontoPageState();
}

class _FormularioPontoPageState extends State<FormularioPontoPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nomeCtrl = TextEditingController(); // Novo Controller
  final _horarioCtrl = TextEditingController();
  // Removido: _capacidadeCtrl
  
  final _ruaCtrl = TextEditingController();
  final _numCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();

  List<String> _itensSelecionados = [];

  @override
  void initState() {
    super.initState();
    // Busca itens do banco (não mais mockados)
    widget.controller.carregarItens();

    if (widget.pontoEdicao != null) {
      final p = widget.pontoEdicao!;
      _nomeCtrl.text = p.nome;
      _horarioCtrl.text = p.horarioFuncionamento;
      
      _ruaCtrl.text = p.endereco.logradouro;
      _numCtrl.text = p.endereco.numero;
      _bairroCtrl.text = p.endereco.bairro;
      _cidadeCtrl.text = p.endereco.cidade;
      _estadoCtrl.text = p.endereco.estado;
      _cepCtrl.text = p.endereco.cep;

      _itensSelecionados = p.itensAceitos.map((e) => e.id!).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pontoEdicao == null ? "Novo Ponto" : "Editar Ponto")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               Text("Dados do Ponto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               SizedBox(height: 10),
               
               // Novo Campo: Nome
               MyTextField(controller: _nomeCtrl, labelText: "Nome do Local (Ex: Sede)", obscureText: false),
               MyTextField(controller: _horarioCtrl, labelText: "Horário (ex: 08:00 - 18:00)", obscureText: false),
               // Capacidade removida

               SizedBox(height: 20),
               Text("Endereço", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               
               MyTextField(controller: _cepCtrl, labelText: "CEP", obscureText: false),
               Row(children: [
                  Expanded(child: MyTextField(controller: _ruaCtrl, labelText: "Rua", obscureText: false)),
                  SizedBox(width: 10),
                  Expanded(flex: 0, child: Container(width: 80, child: MyTextField(controller: _numCtrl, labelText: "Nº", obscureText: false))),
               ]),
               MyTextField(controller: _bairroCtrl, labelText: "Bairro", obscureText: false),
               Row(children: [
                  Expanded(child: MyTextField(controller: _cidadeCtrl, labelText: "Cidade", obscureText: false)),
                  SizedBox(width: 10),
                  Expanded(child: MyTextField(controller: _estadoCtrl, labelText: "Estado", obscureText: false)),
               ]),

               SizedBox(height: 20),
               Text("Itens Aceitos", style: TextStyle(fontSize: 16)),
               
               // Lista dinâmica vinda do banco
               AnimatedBuilder(
                 animation: widget.controller,
                 builder: (context, _) {
                   if (widget.controller.todosItens.isEmpty) {
                     return Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Text("Carregando itens..."),
                     );
                   }
                   return Wrap(
                    spacing: 8.0,
                    children: widget.controller.todosItens.map((item) {
                      final isSelected = _itensSelecionados.contains(item.id);
                      return FilterChip(
                        label: Text(item.nomeItem),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _itensSelecionados.add(item.id!);
                            } else {
                              _itensSelecionados.remove(item.id!);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                 }
               ),

               SizedBox(height: 30),
               ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                  child: widget.controller.isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Salvar Ponto"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Endereco end = Endereco(
                        logradouro: _ruaCtrl.text,
                        numero: _numCtrl.text,
                        bairro: _bairroCtrl.text,
                        cidade: _cidadeCtrl.text,
                        estado: _estadoCtrl.text,
                        cep: _cepCtrl.text,
                      );

                      bool sucesso = await widget.controller.salvarPonto(
                        id: widget.pontoEdicao?.id,
                        nome: _nomeCtrl.text, // Envia nome
                        horario: _horarioCtrl.text,
                        enderecoDados: end,
                        itensSelecionadosIds: _itensSelecionados
                      );

                      if (sucesso) {
                        Navigator.pop(context);
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar.")));
                      }
                    }
                  },
               )
            ],
          ),
        ),
      ),
    );
  }
}