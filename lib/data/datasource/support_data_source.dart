import '../../domain/dtos/ticket_dto.dart';
import '../../domain/entities/ticket_entity.dart';

abstract class SupportDataSource {
  Future<List<TicketEntity>> fetchTickets();
  Future<TicketEntity> fetchTicketDetail(String ticketId);
  Future<Map<String, dynamic>> createTicket(CreateTicketData data);
  Future<Map<String, dynamic>> updateTicketStatus(String ticketId, UpdateTicketStatusData data);
  Future<Map<String, dynamic>> deleteTicket(String ticketId);
  Future<Map<String, dynamic>> createMessage(String ticketId, CreateMessageData data);
}