import 'Endereco.dart';
import 'Item.dart';

class PontoDeColeta {
  final String? id;
  final String nome; // Novo campo
  final String horarioFuncionamento;
  // Capacidade removida
  
  final Endereco endereco;
  final List<Item> itensAceitos;
  final String? instituicaoId;

  PontoDeColeta({
    this.id,
    required this.nome,
    required this.horarioFuncionamento,
    required this.endereco,
    required this.itensAceitos,
    this.instituicaoId,
  });

  factory PontoDeColeta.fromJson(Map<String, dynamic> json) {
    var listaItens = json['itensAceitos'] as List? ?? [];
    List<Item> itens = listaItens.map((i) => Item.fromJson(i)).toList();

    return PontoDeColeta(
      id: json['id']?.toString(),
      nome: json['nome'] ?? 'Ponto de Coleta', // Fallback se o backend antigo mandar null
      horarioFuncionamento: json['horarioFuncionamento'] ?? 'Horário não informado',
      endereco: Endereco.fromJson(json['endereco'] ?? {}),
      itensAceitos: itens,
      instituicaoId: json['instituicaoId'],
    );
  }

  Map<String, dynamic> toRequestJson(List<String> itensIdsSelecionados) {
    return {
      'nome': nome,
      'horarioFuncionamento': horarioFuncionamento,
      'instituicaoId': instituicaoId,
      'endereco': endereco.toJson(),
      'itensIds': itensIdsSelecionados, 
    };
  }
}