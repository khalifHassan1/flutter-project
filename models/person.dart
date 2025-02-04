class Person {
  int? id;
  String name;
  String phone;

  Person({this.id, required this.name, required this.phone});

  factory Person.fromMap(Map<String, dynamic> json) => Person(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
      };
}
