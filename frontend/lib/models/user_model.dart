class UserModel {
  final int id;
  final String name;
  final String email;
  final String token; // API'dan alınan JWT token

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  // Backend'den gelen JSON verisini UserModel objesine dönüştüren factory metot

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name:
          json['name'] as String ??
          'Kullanıcı', //Backend değer göndermezse default değer verdim.
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }

  //Model objesini JSON formatına dönüştüren metot (özellikle secure storage için gerekli)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'token': token};
  }
}
