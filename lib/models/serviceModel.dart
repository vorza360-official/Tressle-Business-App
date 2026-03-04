class Service {
  int? id;
  String name;
  double price;
  String duration;
  int categoryId;

  Service({
    this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'categoryId': categoryId,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      duration: map['duration'],
      categoryId: map['categoryId'],
    );
  }
}