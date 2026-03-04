class Product {
  int? id;
  String name;
  String type;
  double price;
  String description;
  String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.description,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      price: map['price'].toDouble(),
      description: map['description'],
      imagePath: map['imagePath'],
    );
  }
}