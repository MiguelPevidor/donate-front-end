class Item {
  final String id;
  final String nomeItem; // Ou 'nome', verifique seu JSON

  Item({required this.id, required this.nomeItem});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'], 
      nomeItem: json['nomeItem'], // Se no JSON vier 'nome', mude aqui
    );
  }

  // Sobrescrevemos o toString para facilitar logs
  @override
  String toString() => nomeItem;
}