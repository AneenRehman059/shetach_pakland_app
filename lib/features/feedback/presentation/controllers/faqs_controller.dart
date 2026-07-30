import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pakland/features/feedback/data/models/faqs_model.dart';
import 'package:pakland/features/feedback/data/repositories/faqs_repo.dart';

class FaqController extends GetxController {
  final FaqRepository _repo = FaqRepository();
  final storage = GetStorage();

  var selectedIndex = (-1).obs;

  var faqs = <FaqModel>[].obs;
  var isLoading = false.obs;

  // 🔍 Search Query
  var searchQuery = "".obs;

  // 🔍 Filtered FAQs based on Question
  List<FaqModel> get filteredFaqs {
    if (searchQuery.value.isEmpty) {
      return faqs;
    }

    return faqs.where((faq) =>
        faq.question.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadLocalFaqs();
    fetchFaqsFromServer();
  }

  // 📌 Load stored FAQs from local storage (GetStorage)
  void loadLocalFaqs() {
    final data = storage.read("faqs");

    if (data != null) {
      List list = data;
      faqs.value = list.map((e) => FaqModel.fromJson(e)).toList();
    }
  }

  // 📌 Fetch new FAQs from API
  Future<void> fetchFaqsFromServer() async {
    try {
      if (faqs.isEmpty) {
        isLoading.value = true;
      }

      final List<FaqModel> data = await _repo.fetchFaqs();
      faqs.value = data;

      // Save to local storage
      storage.write(
        "faqs",
        data.map((e) => e.toJson()).toList(),
      );

    } catch (e) {
      print("FAQ Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
