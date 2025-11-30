class Item {
  // Mantido sua versão (Nullable) para flexibilidade e compatibilidade com seu código
  final String? id; 
  final String nomeItem;

  Item({this.id, required this.nomeItem});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      nomeItem: json['nomeItem'], // Mantido seu mapeamento
    );
  }

  // Mantido seu método (Necessário para o seu cadastro)
  Map<String, dynamic> toJson() => {'id': id, 'nomeItem': nomeItem};

  // Adicionado funcionalidade do colega (Útil para logs e Dropdowns)
  @override
  String toString() => nomeItem;
}