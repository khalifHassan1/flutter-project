class House {
  int? id;
  String address;
  double price;
  String description;

  House({this.id, required this.address, required this.price, required this.description});

  factory House.fromMap(Map<String, dynamic> json) => House(
        id: json['id'],
        address: json['address'],
        price: json['price'],
        description: json['description'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'address': address,
        'price': price,
        'description': description,
      };
}
