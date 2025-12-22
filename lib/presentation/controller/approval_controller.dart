import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/dtos/approval_decision_dto.dart';

class ApprovalController extends GetxController {
  final AccountRepository repository;

  ApprovalController({required this.repository});

  final pendingApprovals = <TransactionEntity>[].obs;
  final isLoading = true.obs;
  final isProcessingDecision = false.obs;

  @override
  void onInit() {
    fetchPendingApprovals();
    super.onInit();
  }

  Future<void> fetchPendingApprovals() async {
    isLoading.value = true;
    try {
      final result = await repository.getPendingApprovals();
      pendingApprovals.assignAll(result);
    } catch (e) {
      _showError('Failed to load pending approvals', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitDecision(
      String transactionId,
      String decision,
      String? note
      ) async {
    try {
      isProcessingDecision.value = true;

      final decisionData = ApprovalDecisionData(
        decision: decision,
        note: note,
      );

      final result = await repository.submitApprovalDecision(
          transactionId,
          decisionData
      );

      pendingApprovals.removeWhere((t) => t.publicId == transactionId);

      _showSuccess('Decision submitted successfully');

      await fetchPendingApprovals();

    } catch (e) {
      _showError('Failed to submit decision', e.toString());
    } finally {
      isProcessingDecision.value = false;
    }
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.teal,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  int get pendingCount => pendingApprovals.length;
}