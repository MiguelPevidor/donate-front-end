class Item {
  final String? id;
  final String nomeItem;

  Item({this.id, required this.nomeItem});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      nomeItem: json['nomeItem'],
    );
  }

  // Para enviar apenas o ID no cadastro do ponto
  Map<String, dynamic> toJson() => {'id': id, 'nomeItem': nomeItem};
}