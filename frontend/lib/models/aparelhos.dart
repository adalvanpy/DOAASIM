class Device {
  final int id;
  final String nome;
  final String marca;
  final String modeloAnatomico;
  final String modeloDisplay;
  final String perdaIndicada;
  final String perdaDisplay;
  final String descricao;
  final String imagem;
  final int doador;
  final String doadorNome;
  final String status;
  final DateTime criadoEm;

  Device({
    required this.id,
    required this.nome,
    required this.marca,
    required this.modeloAnatomico,
    required this.modeloDisplay,
    required this.perdaIndicada,
    required this.perdaDisplay,
    required this.descricao,
    required this.imagem,
    required this.doador,
    required this.doadorNome,
    required this.status,
    required this.criadoEm,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      marca: json['marca'] ?? '',
      modeloAnatomico: json['modelo_anatomico'] ?? '',
      modeloDisplay: json['modelo_display'] ?? '',
      perdaIndicada: json['perda_indicada'] ?? '',
      perdaDisplay: json['perda_display'] ?? '',
      descricao: json['descricao'] ?? '',
      imagem: json['imagem'] ?? '',
      doador: json['doador'] ?? 0,
      doadorNome: json['doador_nome'] ?? '',
      status: json['status'] ?? '',
      criadoEm: json['criado_em'] != null ? DateTime.parse(json['criado_em']) : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'marca': marca,
      'modelo_anatomico': modeloAnatomico,
      'modelo_display': modeloDisplay,
      'perda_indicada': perdaIndicada,
      'perda_display': perdaDisplay,
      'descricao': descricao,
      'imagem': imagem,
      'doador': doador,
      'doador_nome': doadorNome,
      'status': status,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}