import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';

class BookingRepository {
  Future<List<Map<String, dynamic>>> getBranches() async {
    final response = await http.get(
      Uri.parse(ApiConstants.getProjectUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded["StatusCode"] == "200") {
        final List branches = decoded["obj"]["Branchlist"];
        return List<Map<String, dynamic>>.from(branches);
      } else {
        throw Exception(decoded["Message"] ?? "Failed to load branches");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchBlocks(String branchCode) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.getBlockUrl}?brn_code=$branchCode"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded["StatusCode"] == "200") {
        final List blocks = decoded["obj"]["Blocklist"];
        return List<Map<String, dynamic>>.from(blocks);
      } else {
        throw Exception(decoded["Message"] ?? "Failed to load blocks");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchPlotSizes(String branchCode, String blockNo) async {
    final url = Uri.parse("${ApiConstants.getPlotSizeUrl}?brn_code=$branchCode&block_no=$blockNo");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded["StatusCode"] == "200") {
        final List sizes = decoded["obj"];
        return List<Map<String, dynamic>>.from(sizes);
      } else {
        throw Exception(decoded["Message"] ?? "Failed to load plot sizes");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }

  // Add this method to your BookingRepository class
  Future<List<Map<String, dynamic>>> fetchPlotNatures() async {
    final response = await http.get(
      Uri.parse(ApiConstants.getPlotNatureUrl), // Define this constant
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded["StatusCode"] == "200") {
        final List natures = decoded["obj"];
        return List<Map<String, dynamic>>.from(natures);
      } else {
        throw Exception(decoded["Message"] ?? "Failed to load plot natures");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchPlotTypes() async {
    final response = await http.get(
      Uri.parse(ApiConstants.getPlotTypeUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded["StatusCode"] == "200") {
        final List types = decoded["obj"];
        return List<Map<String, dynamic>>.from(types);
      } else {
        throw Exception(decoded["Message"] ?? "Failed to load plot types");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }

  Future<bool> createBooking(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(ApiConstants.addBookingUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded["StatusCode"] == "200") {
        return true;
      } else {
        throw Exception(decoded["Message"] ?? "Booking failed");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }
}
