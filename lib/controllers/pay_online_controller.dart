import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constant.dart';
import '../models/client_detail_model.dart';

class PayOnlineController extends GetxController {
  var isLoading = false.obs;
  var clientDetailModel = Rx<ClientDetailModel?>(null);
  var errorMessage = ''.obs;
  var hasData = false.obs;

  // Store parameters for later use
  var currentUsername = ''.obs;
  var currentBrnCode = ''.obs;
  var currentBlockNo = ''.obs;
  var currentPlotNo = ''.obs;

  Future<void> fetchClientDetails({
    required String username,
    required String brnCode,
    required String blockNo,
    required String plotNo,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Store parameters
      currentUsername.value = username;
      currentBrnCode.value = brnCode;
      currentBlockNo.value = blockNo;
      currentPlotNo.value = plotNo;

      final uri = Uri.parse(
        "${ApiConstants.getCustomerPortalUrl}"
            "?username=$username"
            "&brn_code=$brnCode"
            "&block_no=$blockNo"
            "&plot_no=$plotNo",
      );

      print('Fetching client details from: $uri'); // Debug log

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        clientDetailModel.value = ClientDetailModel.fromJson(data);
        hasData.value = true;

        print('Client details fetched successfully');
        print('Clientdetaillist length: ${getClientDetailListCount()}');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        hasData.value = false;
        print('Error fetching client details: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      hasData.value = false;
      print('Exception fetching client details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to check if Clientdetaillist is empty
  bool isClientDetailListEmpty() {
    return clientDetailModel.value?.obj.clientDetailList == null ||
        clientDetailModel.value!.obj.clientDetailList!.isEmpty;
  }

  // Helper method to get all brn_codes from Clientdetaillist
  List<String> getAllBrnCodes() {
    if (isClientDetailListEmpty()) {
      return [];
    }

    List<String> brnCodes = [];
    for (var clientDetail in clientDetailModel.value!.obj.clientDetailList!) {
      if (clientDetail.brnCode.isNotEmpty) {
        brnCodes.add(clientDetail.brnCode);
      }
    }
    return brnCodes;
  }

  // Helper method to get first brn_code
  String getFirstBrnCode() {
    if (isClientDetailListEmpty()) {
      return '';
    }
    return clientDetailModel.value!.obj.clientDetailList!.first.brnCode;
  }

  // Helper method to get Clientdetaillist count
  int getClientDetailListCount() {
    if (isClientDetailListEmpty()) {
      return 0;
    }
    return clientDetailModel.value!.obj.clientDetailList!.length;
  }

  // Helper method to get client details by index
  ClientDetail? getClientDetailByIndex(int index) {
    if (isClientDetailListEmpty() ||
        index < 0 ||
        index >= clientDetailModel.value!.obj.clientDetailList!.length) {
      return null;
    }
    return clientDetailModel.value!.obj.clientDetailList![index];
  }

  // Helper method to iterate through all client details
  void iterateThroughClientDetails(Function(ClientDetail) callback) {
    if (isClientDetailListEmpty()) {
      return;
    }

    for (var clientDetail in clientDetailModel.value!.obj.clientDetailList!) {
      callback(clientDetail);
    }
  }

  // Method to refresh client details with current stored parameters
  Future<void> refreshClientDetails() async {
    if (currentUsername.value.isNotEmpty &&
        currentBrnCode.value.isNotEmpty &&
        currentBlockNo.value.isNotEmpty &&
        currentPlotNo.value.isNotEmpty) {
      await fetchClientDetails(
        username: currentUsername.value,
        brnCode: currentBrnCode.value,
        blockNo: currentBlockNo.value,
        plotNo: currentPlotNo.value,
      );
    }
  }

  // Optional: Add a method to reset data if needed
  void resetData() {
    clientDetailModel.value = null;
    hasData.value = false;
    errorMessage.value = '';
    currentUsername.value = '';
    currentBrnCode.value = '';
    currentBlockNo.value = '';
    currentPlotNo.value = '';
  }
}