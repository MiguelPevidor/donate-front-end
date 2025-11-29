class PontoDeColeta {
  final String id;
  final String horarioFuncionamento;
  final double latitude;
  final double longitude;

  PontoDeColeta({
    required this.id,
    required this.horarioFuncionamento,
    required this.latitude,
    required this.longitude,
  });

  factory PontoDeColeta.fromJson(Map<String, dynamic> json) {
    final endereco = json['endereco'] ?? {};
    
    return PontoDeColeta(
      // Garante que o ID seja String
      id: json['id']?.toString() ?? '',
      
      // Mapeia o campo correto do seu JSON
      horarioFuncionamento: json['horarioFuncionamento'] ?? 'Horário não informado',
      
      latitude: double.tryParse(endereco['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(endereco['longitude']?.toString() ?? '') ?? 0.0,
    );
  }

}