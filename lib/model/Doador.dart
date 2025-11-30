class Doador {
  
  final String? id; 
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
  final String login;
  final String? senha; // Senha também pode ser nula se estivermos apenas listando usuários

  Doador({
    this.id, // Opcional no construtor
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.login,
    this.senha, // Opcional (não precisamos mandar senha ao editar, por exemplo)
  });

  // 2. toJson: Transforma Objeto -> JSON (Para enviar ao Backend)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'login': login,
      'senha': senha,
    };
    
    // Só envia o ID se ele existir para Updates
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  // Transforma JSON -> Objeto (Ao receber do Backend)
  factory Doador.fromJson(Map<String, dynamic> json) {
    return Doador(
      id: json['id'], 
      nome: json['nome'],
      cpf: json['cpf'],
      telefone: json['telefone'],
      email: json['email'],
      login: json['login'],
      senha: null, 
    );
  }
}