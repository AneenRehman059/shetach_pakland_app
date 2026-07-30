import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/customer_portal/data/models/customer_portal_model.dart';

class CustomerPortalRepository {
  Future<CustomerPortalResponse> getCustomerPortalData({required String username}) async {
    final url = Uri.parse(
        "${ApiConstants.getCustomerPortalUrl}"
            "?username=$username"
            "&brn_code=000000"
            "&block_no=A"
            "&plot_no=123"
    );

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return CustomerPortalResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch customer portal data: ${response.body}");
    }
  }

  Future<CustomerPortalResponse> getCustomerProfileData({required String username}) async {
    final url = Uri.parse(
        "${ApiConstants.getCustomerPortalUrl}"
            "?username=$username"
            "&brn_code=a"
            "&block_no=A"
            "&plot_no=123"
    );

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return CustomerPortalResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch customer portal data: ${response.body}");
    }
  }
}
