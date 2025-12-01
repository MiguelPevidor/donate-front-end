import 'package:donate/util/localizador.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:donate/model/PontoDeColeta.dart';

class PontoColetaCard extends StatelessWidget {
  final PontoDeColeta ponto;
  final VoidCallback onFechar;

  const PontoColetaCard({Key? key, required this.ponto, required this.onFechar}) : super(key: key);

 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.location_on, color: Colors.teal, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ponto.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("${ponto.endereco.bairro} ${ponto.endereco.cidade}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: onFechar)
            ],
          ),
          const Divider(height: 30),
          _infoRow(Icons.access_time, "Horário", ponto.horarioFuncionamento),
          const SizedBox(height: 12),
          _infoRow(Icons.map_outlined, "Endereço", "${ponto.endereco.logradouro}, ${ponto.endereco.numero}"),
          const SizedBox(height: 20),
          const Text("Itens Aceitos:", style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: ponto.itensAceitos.map((item) => Chip(
              label: Text(item.nomeItem),
              backgroundColor: Colors.teal[50],
            )).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.directions, color: Colors.white),
              label: const Text("IR PARA O PONTO", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                if (ponto.endereco.latitude != null && ponto.endereco.longitude != null) {
                  Localizador.abrirGoogleMaps(
                    ponto.endereco.latitude!, 
                    ponto.endereco.longitude!
                  );
                  
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ]))
      ],
    );
  }
}