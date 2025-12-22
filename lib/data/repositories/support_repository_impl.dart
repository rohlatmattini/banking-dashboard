import '../../domain/dtos/ticket_dto.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasource/api_support_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  final ApiSupportDataSource dataSource;

  SupportRepositoryImpl({required this.dataSource});

  @override
  Future<List<TicketEntity>> getTickets() async {
    return await dataSource.fetchTickets();
  }

  @override
  Future<TicketEntity> getTicketDetail(String ticketId) async {
    return await dataSource.fetchTicketDetail(ticketId);
  }

  @override
  Future<Map<String, dynamic>> createTicket(CreateTicketData data) async {
    return await dataSource.createTicket(data);
  }

  @override
  Future<Map<String, dynamic>> updateTicketStatus(
      String ticketId,
      UpdateTicketStatusData data,
      ) async {
    return await dataSource.updateTicketStatus(ticketId, data);
  }

  @override
  Future<Map<String, dynamic>> deleteTicket(String ticketId) async {
    return await dataSource.deleteTicket(ticketId);
  }

  @override
  Future<Map<String, dynamic>> createMessage(
      String ticketId,
      CreateMessageData data,
      ) async {
    return await dataSource.createMessage(ticketId, data);
  }
}