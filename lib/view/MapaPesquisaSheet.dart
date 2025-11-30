import 'package:flutter/material.dart';
import 'package:donate/model/Item.dart';
import 'package:donate/model/PontoDeColeta.dart';

class MapaPesquisaSheet extends StatelessWidget {
  final TextEditingController searchController;
  final List<Item> tiposItens;
  final List<String> idsSelecionados;
  final List<PontoDeColeta> pontosEncontrados;
  final bool isLoading;
  
  // Callbacks para comunicar com o Pai (MapaPage)
  final Function(String, bool) onFiltroChanged;
  final Function(PontoDeColeta) onPontoSelected;
  final VoidCallback onSearchTap;

  const MapaPesquisaSheet({
    Key? key,
    required this.searchController,
    required this.tiposItens,
    required this.idsSelecionados,
    required this.pontosEncontrados,
    required this.isLoading,
    required this.onFiltroChanged,
    required this.onPontoSelected,
    required this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de Pesquisa
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Buscar...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onTap: onSearchTap,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Título Filtros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("O que você deseja doar?",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[700])),
        ),

        const SizedBox(height: 10),

        // Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: tiposItens.map((Item item) {
              final String idStr = item.id.toString();
              final isSelected = idsSelecionados.contains(idStr);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(item.nomeItem),
                  selected: isSelected,
                  selectedColor: Colors.teal[100],
                  checkmarkColor: Colors.teal,
                  onSelected: (bool selected) {
                    onFiltroChanged(idStr, selected);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 30),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Pontos de Coleta Próximos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),

        // Lista de Resultados
        if (isLoading)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (pontosEncontrados.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(20), child: Text("Nenhum local encontrado.")))
        else
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
                title: Text(ponto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                
                // --- CORREÇÃO AQUI ---
                // Voltamos a mostrar Bairro + Horário de funcionamento
                subtitle: Text(
                    "${ponto.endereco.bairro} • ${ponto.horarioFuncionamento}"),
                
                onTap: () => onPontoSelected(ponto),
              );
            },
          ),
      ],
    );
  }
}