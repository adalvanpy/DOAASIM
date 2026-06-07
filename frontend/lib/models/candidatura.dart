class Candidatura {
  final int id;
  final int aparelho;
  final String aparelhoNome;
  final int candidato;
  final String candidatoNome;
  final String laudoExame;
  final String status;
  final String statusDisplay;
  final DateTime dataCandidatura;

  Candidatura({
    required this.id,
    required this.aparelho,
    required this.aparelhoNome,
    required this.candidato,
    required this.candidatoNome,
    required this.laudoExame,
    required this.status,
    required this.statusDisplay,
    required this.dataCandidatura,
  });

  factory Candidatura.fromJson(Map<String, dynamic> json) {
    return Candidatura(
      id: json['id'] ?? 0,
      aparelho: json['aparelho'] ?? 0,
      aparelhoNome: json['aparelho_nome'] ?? '',
      candidato: json['candidato'] ?? 0,
      candidatoNome: json['candidato_nome'] ?? '',
      laudoExame: json['laudo_exame'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      dataCandidatura: json['data_candidatura'] != null ? DateTime.parse(json['data_candidatura']) : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aparelho': aparelho,
      'aparelho_nome': aparelhoNome,
      'candidato': candidato,
      'candidato_nome': candidatoNome,
      'laudo_exame': laudoExame,
      'status': status,
      'status_display': statusDisplay,
      'data_candidatura': dataCandidatura.toIso8601String(),
    };
  }
}