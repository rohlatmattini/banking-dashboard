// lib/presentation/controller/report_controller.dart
import 'package:get/get.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/patterns/composite/account_component.dart';

class ReportController extends GetxController {
  final ReportRepository repository;
  ReportController({required this.repository});

  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final reportHierarchy = Rxn<AccountComponent>();
  final dailyReports = <Map<String, dynamic>>[].obs;
  final accountSummaries = <Map<String, dynamic>>[].obs;
  final auditLogs = <Map<String, dynamic>>[].obs;
  final systemSummary = <String, dynamic>{}.obs;

  @override
  void onInit() {
    loadAllReports();
    super.onInit();
  }

  Future<void> loadAllReports() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadDailyReport(),
        loadAccountSummaries(),
        loadAuditLogs(),
        loadSystemSummary(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDailyReport() async {
    try {
      final reports = await repository.getDailyReport(selectedDate.value);
      dailyReports.assignAll(reports);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load daily report: $e');
    }
  }

  Future<void> loadAccountSummaries() async {
    try {
      final summaries = await repository.getAccountSummaries();
      accountSummaries.assignAll(summaries);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load account summaries: $e');
    }
  }

  Future<void> loadAuditLogs() async {
    try {
      final logs = await repository.getAuditLogs();
      auditLogs.assignAll(logs);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load audit logs: $e');
    }
  }

  Future<void> loadSystemSummary() async {
    try {
      final summary = await repository.getSystemSummary();
      systemSummary.value = summary;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load system summary: $e');
    }
  }

  void changeDate(DateTime newDate) {
    selectedDate.value = newDate;
    loadDailyReport();
  }

  void exportReport(String format) {
    Get.snackbar('Success', 'Report exported as $format');
  }
}