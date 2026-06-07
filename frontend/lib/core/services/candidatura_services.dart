import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

class CandidaturaService {
  final String token;
  
  CandidaturaService({required this.token});
  
  Future<bool> aprovarCandidatura(int candidaturaId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.candidates}$candidaturaId/aprovar/');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
  
  Future<bool> reprovarCandidatura(int candidaturaId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.candidates}$candidaturaId/reprovar/');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
  
  Future<bool> escolherCandidato(int candidaturaId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.candidates}$candidaturaId/escolher/');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
  
  Future<List<dynamic>> fetchCandidaturas() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.candidates}');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}