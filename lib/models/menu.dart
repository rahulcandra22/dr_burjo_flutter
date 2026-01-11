class Menu {
  final int? id;
  final String name;
  final int price;
  final String description;
  final String? imagePath;

  Menu({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.imagePath,  
  }) : assert(price >= 0, 'Harga tidak boleh negatif');


  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: map['price'] as int,
      description: map['description'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imagePath,
    };
  }

  Menu copyWith({
    int? id,
    String? name,
    int? price,
    String? description,
    String? imagePath,
  }) {
    return Menu(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  String get formattedPrice =>
      'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  String toString() => 'Menu(id: $id, name: $name, price: $price, description: $description)';
}