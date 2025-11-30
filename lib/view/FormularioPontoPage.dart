import 'package:flutter/material.dart';
import '../controllers/GerenciarPontosController.dart';
import '../model/PontoDeColeta.dart';
import '../model/Endereco.dart';
import '../components/MyTextField.dart';

class FormularioPontoPage extends StatefulWidget {
  final GerenciarPontosController controller;
  final PontoDeColeta? pontoEdicao;

  const FormularioPontoPage({required this.controller, this.pontoEdicao});

  @override
  _FormularioPontoPageState createState() => _FormularioPontoPageState();
}

class _FormularioPontoPageState extends State<FormularioPontoPage> {
  final _formKey = GlobalKey<FormState>();

  final _horarioCtrl = TextEditingController();
  final _capacidadeCtrl = TextEditingController();
  
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
    widget.controller.carregarItens();

    if (widget.pontoEdicao != null) {
      final p = widget.pontoEdicao!;
      _horarioCtrl.text = p.horarioFuncionamento;
      _capacidadeCtrl.text = p.capacidadeMaxima.toString();
      
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
               Text("Endereço do Ponto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               SizedBox(height: 10),
               
               // CEP e Rua
               MyTextField(controller: _cepCtrl, labelText: "CEP", obscureText: false),
               Row(children: [
                  Expanded(child: MyTextField(controller: _ruaCtrl, labelText: "Rua", obscureText: false)),
                  SizedBox(width: 10),
                  Expanded(flex: 0, child: Container(width: 80, child: MyTextField(controller: _numCtrl, labelText: "Nº", obscureText: false))),
               ]),
               
               // Bairro, Cidade, Estado
               MyTextField(controller: _bairroCtrl, labelText: "Bairro", obscureText: false),
               Row(children: [
                  Expanded(child: MyTextField(controller: _cidadeCtrl, labelText: "Cidade", obscureText: false)),
                  SizedBox(width: 10),
                  Expanded(child: MyTextField(controller: _estadoCtrl, labelText: "Estado", obscureText: false)),
               ]),

               SizedBox(height: 20),
               Text("Detalhes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               MyTextField(controller: _horarioCtrl, labelText: "Horário (ex: 08:00 - 18:00)", obscureText: false),
               MyTextField(controller: _capacidadeCtrl, labelText: "Capacidade (Kg ou Qtd)", obscureText: false),

               SizedBox(height: 20),
               Text("Quais itens este ponto aceita?", style: TextStyle(fontSize: 16)),
               
               // Chips para seleção de itens
               AnimatedBuilder(
                 animation: widget.controller,
                 builder: (context, _) {
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
                      
                      // Cria objeto endereço apenas com os textos
                      Endereco end = Endereco(
                        logradouro: _ruaCtrl.text,
                        numero: _numCtrl.text,
                        bairro: _bairroCtrl.text,
                        cidade: _cidadeCtrl.text,
                        estado: _estadoCtrl.text,
                        cep: _cepCtrl.text,
                        // latitude e longitude deixamos null ou 0.0 aqui
                        // O controller vai preencher!
                      );

                      bool sucesso = await widget.controller.salvarPonto(
                        id: widget.pontoEdicao?.id,
                        horario: _horarioCtrl.text,
                        capacidade: _capacidadeCtrl.text,
                        enderecoDados: end, // Envia para o controller processar
                        itensSelecionadosIds: _itensSelecionados
                      );

                      if (sucesso) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ponto salvo com sucesso!"), backgroundColor: Colors.green));
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar. Verifique o endereço."), backgroundColor: Colors.red));
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