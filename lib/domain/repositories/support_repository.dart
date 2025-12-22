import '../dtos/ticket_dto.dart';
import '../entities/ticket_entity.dart';

abstract class SupportRepository {
  Future<List<TicketEntity>> getTickets();
  Future<TicketEntity> getTicketDetail(String ticketId);
  Future<Map<String, dynamic>> createTicket(CreateTicketData data);
  Future<Map<String, dynamic>> updateTicketStatus(
      String ticketId,
      UpdateTicketStatusData data,
      );
  Future<Map<String, dynamic>> deleteTicket(String ticketId);
  Future<Map<String, dynamic>> createMessage(
      String ticketId,
      CreateMessageData data,
      );
}