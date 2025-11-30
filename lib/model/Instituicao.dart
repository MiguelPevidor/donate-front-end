class Instituicao {
  final String? id; // Nullable
  final String nomeInstituicao;
  final String missao;
  final String cnpj;
  final String telefone;
  final String email;
  final String login;
  final String? senha;

  Instituicao({
    this.id,
    required this.nomeInstituicao,
    required this.missao,
    required this.cnpj,
    required this.telefone,
    required this.email,
    required this.login,
    this.senha,
  });

  // Enviar para API
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Se for null, o Spring geralmente ignora no cadastro
      'nome': nomeInstituicao,
      'missao': missao,
      'cnpj': cnpj,
      'telefone': telefone,
      'email': email,
      'login': login,
      'senha': senha,
    };
  }

  // Receber da API
  factory Instituicao.fromJson(Map<String, dynamic> json) {
    return Instituicao(
      id: json['id'],
      nomeInstituicao: json['nome'], // Verifique se o backend manda 'nome' ou 'nomeInstituicao'
      missao: json['missao'],
      cnpj: json['cnpj'],
      telefone: json['telefone'],
      email: json['email'],
      login: json['login'],
    );
  }
}