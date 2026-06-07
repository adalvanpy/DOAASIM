import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

class DeviceService {
  final String token;
  
  DeviceService({required this.token});
  
  Future<bool> approveDevice(int deviceId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.devices}$deviceId/aprovar/');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
  
  Future<bool> rejectDevice(int deviceId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.devices}$deviceId/reprovar/');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
  
  // ADICIONAR ESTE MÉTODO
  Future<List<dynamic>> fetchAparelhos() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.devices}');
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