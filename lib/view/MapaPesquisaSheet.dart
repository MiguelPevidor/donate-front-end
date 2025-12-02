import 'package:flutter/material.dart';
import 'package:donate/model/Item.dart';
import 'package:donate/model/PontoDeColeta.dart';

class MapaPesquisaSheet extends StatelessWidget {
  final List<Item> tiposItens;
  final List<String> idsSelecionados;
  final List<PontoDeColeta> pontosEncontrados;
  final bool isLoading;
  
  // Callbacks
  final Function(String, bool) onFiltroChanged;
  final Function(PontoDeColeta) onPontoSelected;

  const MapaPesquisaSheet({
    Key? key,
    required this.tiposItens,
    required this.idsSelecionados,
    required this.pontosEncontrados,
    required this.isLoading,
    required this.onFiltroChanged,
    required this.onPontoSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        

        // Título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "O que você deseja doar?",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 18,
              color: Colors.grey[800]
            ),
          ),
        ),

        // --- AQUI ESTÁ A VOLTA PARA O ROW COM SCROLL ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: tiposItens.map((Item item) {
              final String idStr = item.id.toString();
              final isSelected = idsSelecionados.contains(idStr);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0), // Espacinho entre eles
                child: FilterChip(
                  label: Text(item.nomeItem),
                  selected: isSelected,
                  selectedColor: Colors.teal[100],
                  checkmarkColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.teal[900] : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[100],
                  onSelected: (bool selected) {
                    onFiltroChanged(idStr, selected);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        // ------------------------------------------------

        const Divider(height: 30, thickness: 1),

        // Cabeçalho da Lista
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            children: [
              const Icon(Icons.place, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Pontos de Coleta Próximos",
                style: TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 14, 
                  color: Colors.grey[600]
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Lista de Resultados
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30), 
              child: CircularProgressIndicator()
            )
          )
        else if (pontosEncontrados.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40), 
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 40, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text(
                    "Nenhum local encontrado.\nTente selecionar outro item.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              )
            )
          )
        else
          // Lista de resultados
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pontosEncontrados.length,
            itemBuilder: (ctx, index) {
              final ponto = pontosEncontrados[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.location_on, color: Colors.white),
                ),
                title: Text(
                  ponto.nome, 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                subtitle: Text(
                  "${ponto.endereco.bairro} • ${ponto.horarioFuncionamento}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => onPontoSelected(ponto),
              );
            },
          ),
          
          const SizedBox(height: 20),
      ],
    );
  }
}