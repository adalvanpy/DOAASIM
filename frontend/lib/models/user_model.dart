class UserDetails {
  final int id;
  final String username;
  final String email;

  UserDetails({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserDetails.fromJson(dynamic json) {
    final data = json is Map<String, dynamic> ? json : <String, dynamic>{};

    return UserDetails(
      id: data['id'] ?? 0,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}

class Perfil {
  final int id;
  final int user;
  final UserDetails userDetails;
  final String tipo;
  final String tipoDisplay;
  final String cpfCnpj;

  Perfil({
    required this.id,
    required this.user,
    required this.userDetails,
    required this.tipo,
    required this.tipoDisplay,
    required this.cpfCnpj,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      userDetails: UserDetails.fromJson(json['user_details'] ?? {}),
      tipo: json['tipo'] ?? '',
      tipoDisplay: json['tipo_display'] ?? '',
      cpfCnpj: json['cpf_cnpj'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'user_details': userDetails.toJson(),
      'tipo': tipo,
      'tipo_display': tipoDisplay,
      'cpf_cnpj': cpfCnpj,
    };
  }
}