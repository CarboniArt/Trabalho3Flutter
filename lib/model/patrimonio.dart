//pensando se utilizo

class Patrimonio {
  String? id;
  String tipoItem;
  double valorEstimado;
  String categoriaUso;
  String descricao;
  String? dataAquisicao;
  String? fotos;
  String? detalhesExtra;

  Patrimonio({
    this.id,
    required this.tipoItem,
    required this.valorEstimado,
    required this.categoriaUso,
    required this.descricao,
    this.dataAquisicao,
    this.fotos,
    this.detalhesExtra,
  });


  factory Patrimonio.fromMap(String id, Map<String, dynamic> map) {
    return Patrimonio(
      id: id,
      tipoItem: map['tipoItem'] ?? '',
      valorEstimado: (map['valorEstimado'] ?? 0.0).toDouble(),
      categoriaUso: map['categoriaUso'] ?? '',
      descricao: map['descricao'] ?? '',
      dataAquisicao: map['dataAquisicao'],
      fotos: map['fotos'],
      detalhesExtra: map['detalhesExtra'],
    );
  }


  factory Patrimonio.fromFirestore(String id, Map<String, dynamic> data) {
    return Patrimonio.fromMap(id, data);
  }


  Map<String, dynamic> toMap() {
    return {
      'tipoItem': tipoItem,
      'valorEstimado': valorEstimado,
      'categoriaUso': categoriaUso,
      'descricao': descricao,
      'dataAquisicao': dataAquisicao,
      'fotos': fotos,
      'detalhesExtra': detalhesExtra,
    };
  }


  @override
  String toString() {
    return 'Patrimonio{id: $id, tipoItem: $tipoItem, valorEstimado: R\$ ${valorEstimado.toStringAsFixed(2)}, categoriaUso: $categoriaUso, descricao: $descricao, dataAquisicao: $dataAquisicao}';
  }


  Patrimonio copyWith({
    String? id,
    String? tipoItem,
    double? valorEstimado,
    String? categoriaUso,
    String? descricao,
    String? dataAquisicao,
    String? fotos,
    String? detalhesExtra,
  }) {
    return Patrimonio(
      id: id ?? this.id,
      tipoItem: tipoItem ?? this.tipoItem,
      valorEstimado: valorEstimado ?? this.valorEstimado,
      categoriaUso: categoriaUso ?? this.categoriaUso,
      descricao: descricao ?? this.descricao,
      dataAquisicao: dataAquisicao ?? this.dataAquisicao,
      fotos: fotos ?? this.fotos,
      detalhesExtra: detalhesExtra ?? this.detalhesExtra,
    );
  }


  bool isValid() {
    return tipoItem.isNotEmpty &&
           valorEstimado > 0 &&
           categoriaUso.isNotEmpty &&
           descricao.isNotEmpty;
  }


  String getIconName() {
    switch (tipoItem) {
      case 'Casa':
        return 'home';
      case 'Terreno':
        return 'landscape';
      case 'Veículo':
        return 'directions_car';
      case 'Ação':
        return 'trending_up';
      case 'Outros':
        return 'category';
      default:
        return 'account_balance_wallet';
    }
  }


  bool canHavePhotos() {
    return tipoItem == 'Casa' || 
           tipoItem == 'Terreno' || 
           tipoItem == 'Veículo';
  }
}