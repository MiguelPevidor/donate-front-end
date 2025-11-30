import 'Endereco.dart';
import 'Item.dart';

class PontoDeColeta {
  final String? id;
  final String horarioFuncionamento;
  final int capacidadeMaxima;
  final int? capacidadeAtual;
  final Endereco endereco;
  final List<Item> itensAceitos;
  final String? instituicaoId;

  PontoDeColeta({
    this.id,
    required this.horarioFuncionamento,
    required this.capacidadeMaxima,
    this.capacidadeAtual,
    required this.endereco,
    required this.itensAceitos,
    this.instituicaoId,
  });

  factory PontoDeColeta.fromJson(Map<String, dynamic> json) {
    var listaItens = json['itensAceitos'] as List? ?? [];
    List<Item> itens = listaItens.map((i) => Item.fromJson(i)).toList();

    return PontoDeColeta(
      id: json['id'],
      horarioFuncionamento: json['horarioFuncionamento'],
      capacidadeMaxima: json['capacidadeMaxima'],
      capacidadeAtual: json['capacidadeAtual'],
      endereco: Endereco.fromJson(json['endereco']),
      itensAceitos: itens,
      instituicaoId: json['instituicaoId'],
    );
  }

  // Para enviar ao criar/editar (PontoDeColetaRequestDTO)
  Map<String, dynamic> toRequestJson(List<String> itensIdsSelecionados) {
    return {
      'horarioFuncionamento': horarioFuncionamento,
      'capacidadeMaxima': capacidadeMaxima,
      'instituicaoId': instituicaoId,
      'endereco': endereco.toJson(),
      'itensIds': itensIdsSelecionados, // Set<UUID> no Java
    };
  }
}