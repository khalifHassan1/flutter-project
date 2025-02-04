class User {
  int? id;
  String username;
  String password;
  bool isAdmin;

  User({this.id, required this.username, required this.password, this.isAdmin = false});

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        isAdmin: json['isAdmin'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password': password,
        'isAdmin': isAdmin ? 1 : 0,
      };
}
