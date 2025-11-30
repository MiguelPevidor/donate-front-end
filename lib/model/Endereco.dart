class Endereco {
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final double? latitude;
  final double? longitude;

  Endereco({
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.latitude,
    this.longitude,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      logradouro: json['logradouro'] ?? '',
      numero: json['numero'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      cep: json['cep'] ?? '',
      // Tratamento seguro para converter String ou Number para double
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
    );
  }

  // CORREÇÃO AQUI: Incluindo latitude e longitude no envio
  Map<String, dynamic> toJson() {
    return {
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      // O Backend espera String, então convertemos com toString() para garantir
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
    };
  }
}