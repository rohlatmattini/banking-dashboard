import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/support_repository.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/dtos/ticket_dto.dart';

class SupportController extends GetxController {
  final SupportRepository repository;

  SupportController({required this.repository});

  final tickets = <TicketEntity>[].obs;
  final selectedTicket = Rxn<TicketEntity>();
  final isLoading = true.obs;
  final isCreatingTicket = false.obs;
  final isSendingMessage = false.obs;

  @override
  void onInit() {
    fetchTickets();
    super.onInit();
  }

  Future<void> fetchTickets() async {
    isLoading.value = true;
    try {
      final result = await repository.getTickets();
      tickets.assignAll(result);
    } catch (e) {
      _showError('Failed to load tickets', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTicketDetail(String ticketId) async {
    try {
      final result = await repository.getTicketDetail(ticketId);
      selectedTicket.value = result;
    } catch (e) {
      _showError('Failed to load ticket details', e.toString());
    }
  }

  Future<Map<String, dynamic>> createNewTicket({
    required String subject,
    required String message,
    String? category,
    String? priority,
  }) async {
    try {
      isCreatingTicket.value = true;

      final data = CreateTicketData(
        subject: subject,
        message: message,
        category: category,
        priority: priority,
      );

      final result = await repository.createTicket(data);

      // Refresh tickets list
      await fetchTickets();

      _showSuccess('Ticket created successfully');
      return result;
    } catch (e) {
      _showError('Failed to create ticket', e.toString());
      rethrow;
    } finally {
      isCreatingTicket.value = false;
    }
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      final data = UpdateTicketStatusData(status: status);
      await repository.updateTicketStatus(ticketId, data);

      // Update local ticket
      final index = tickets.indexWhere((t) => t.publicId == ticketId);
      if (index != -1) {
        await fetchTicketDetail(ticketId);
        await fetchTickets();
      }

      _showSuccess('Ticket status updated');
    } catch (e) {
      _showError('Failed to update ticket status', e.toString());
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    try {
      await repository.deleteTicket(ticketId);

      // Remove from local list
      tickets.removeWhere((t) => t.publicId == ticketId);

      _showSuccess('Ticket deleted successfully');
    } catch (e) {
      _showError('Failed to delete ticket', e.toString());
    }
  }

  Future<void> sendMessage(String ticketId, String message) async {
    try {
      isSendingMessage.value = true;

      final data = CreateMessageData(body: message);
      await repository.createMessage(ticketId, data);

      // Refresh ticket details
      await fetchTicketDetail(ticketId);

      _showSuccess('Message sent');
    } catch (e) {
      _showError('Failed to send message', e.toString());
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Statistics
  Map<String, int> getTicketStatistics() {
    final open = tickets.where((t) => t.status == TicketStatus.OPEN).length;
    final pending = tickets.where((t) => t.status == TicketStatus.PENDING_STAFF).length;
    final inProgress = tickets.where((t) => t.status == TicketStatus.IN_PROGRESS).length;
    final resolved = tickets.where((t) => t.status == TicketStatus.RESOLVED).length;
    final closed = tickets.where((t) => t.status == TicketStatus.CLOSED).length;

    return {
      'total': tickets.length,
      'open': open,
      'pending': pending,
      'in_progress': inProgress,
      'resolved': resolved,
      'closed': closed,
    };
  }

  // Filter tickets by status
  List<TicketEntity> getTicketsByStatus(TicketStatus status) {
    return tickets.where((t) => t.status == status).toList();
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
}