import 'package:get/get.dart';
import 'package:sigma_new/controller/mock_model.dart';
import 'package:sigma_new/models/sub_cahp_datum.dart';


class MockExamController extends GetxController {
  RxList<SubCahpDatum> filteredQuestions = <SubCahpDatum>[].obs;
  RxInt currentQuestionIndex = 0.obs;
  RxString currentLevel = 's'.obs;

  Future<void> loadQuestions(String path) async {
    final data = await loadSubjectQuestions(path);
    filteredQuestions.value =
        filterQuestionsByComplexity(data.subCahpData ?? [], currentLevel.value);
    currentQuestionIndex.value = 0;
  }

  void changeLevel(String newLevel, String path) async {
    currentLevel.value = newLevel;
    final data = await loadSubjectQuestions(path);
    filteredQuestions.value =
        filterQuestionsByComplexity(data.subCahpData ?? [], currentLevel.value);
    currentQuestionIndex.value = 0;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < filteredQuestions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }
}
