import 'Endereco.dart';
import 'Item.dart';

class PontoDeColeta {
  // Mantemos String? (nullable) para permitir criar pontos novos (sem ID ainda)
  final String? id;
  final String horarioFuncionamento;
  final int capacidadeMaxima;
  final int? capacidadeAtual;
  
  // Mantemos o objeto Endereco completo (essencial para o Geocoding e edição)
  final Endereco endereco;
  
  // Mantemos a lista de itens (essencial para o filtro e cadastro)
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
      id: json['id']?.toString(), // Garante conversão segura para String
      horarioFuncionamento: json['horarioFuncionamento'] ?? 'Horário não informado',
      capacidadeMaxima: json['capacidadeMaxima'] ?? 0,
      capacidadeAtual: json['capacidadeAtual'],
      
      // Mapeia o objeto Endereco completo
      endereco: Endereco.fromJson(json['endereco'] ?? {}),
      
      itensAceitos: itens,
      instituicaoId: json['instituicaoId'],
    );
  }

  // Método essencial para o seu Formulário de Cadastro enviar os dados
  Map<String, dynamic> toRequestJson(List<String> itensIdsSelecionados) {
    return {
      'horarioFuncionamento': horarioFuncionamento,
      'capacidadeMaxima': capacidadeMaxima,
      'instituicaoId': instituicaoId,
      'endereco': endereco.toJson(), // Envia o endereço com lat/long
      'itensIds': itensIdsSelecionados, 
    };
  }
}