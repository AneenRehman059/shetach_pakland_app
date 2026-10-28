import 'package:get/get.dart';

import 'package:pakland/features/billing/data/models/client_bill_model.dart';
import 'package:pakland/features/billing/data/repositories/client_bill_repo.dart';

class ClientBillController extends GetxController {
  final ClientBillRepository _repository = ClientBillRepository();

  final Rx<ClientBillModel?> clientBillModel = Rx<ClientBillModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchClientBills({
    required String brnCode,
    required String idNo,
    required int fromMonth,
    required int toMonth,
    required int year,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getClientBills(
        brnCode: brnCode,
        idNo: idNo,
        fromMonth: fromMonth,
        toMonth: toMonth,
        year: year,
      );

      clientBillModel.value = response;
    } catch (e) {
      errorMessage.value = _getUserFriendlyErrorMessage(e);
      clientBillModel.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    } else {
      return error.toString();
    }
  }

  void clearData() {
    clientBillModel.value = null;
    errorMessage.value = '';
  }
}