import 'package:dio/dio.dart';
import '../../domain/dtos/ticket_dto.dart';
import '../../domain/entities/ticket_entity.dart';
import '../model/ticket_entity.dart';
import 'support_data_source.dart';

class ApiSupportDataSource implements SupportDataSource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  static const String _authToken = '1|8d9DxyeC3oYBWMONOzpOJYBozOspoVy9EUzgnVkbf028fb46';

  ApiSupportDataSource() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $_authToken';
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // معالجة انتهاء صلاحية التوكن
        }
        return handler.next(error);
      },
    ));
  }

  @override
  Future<List<TicketEntity>> fetchTickets() async {
    try {
      final response = await _dio.get('/support/tickets');

      if (response.data is Map && response.data.containsKey('data')) {
        final items = List<Map<String, dynamic>>.from(response.data['data']);
        return items.map((item) => TicketModel.fromJson(item)).toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to fetch tickets: ${e.response!.data}');
      } else {
        throw Exception('Failed to fetch tickets: ${e.message}');
      }
    }
  }

  @override
  Future<TicketEntity> fetchTicketDetail(String ticketId) async {
    try {
      final response = await _dio.get('/support/tickets/$ticketId');
      return TicketModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Ticket not found');
      } else if (e.response != null) {
        throw Exception('Failed to fetch ticket details: ${e.response!.data}');
      } else {
        throw Exception('Failed to fetch ticket details: ${e.message}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> createTicket(CreateTicketData data) async {
    try {
      final response = await _dio.post(
        '/support/tickets',
        data: data.toJson(),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation failed: ${e.response!.data}');
      } else if (e.response != null) {
        throw Exception('Failed to create ticket: ${e.response!.data}');
      } else {
        throw Exception('Failed to create ticket: ${e.message}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> updateTicketStatus(
      String ticketId,
      UpdateTicketStatusData data,
      ) async {
    try {
      final response = await _dio.patch(
        '/support/tickets/$ticketId/status',
        data: data.toJson(),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Ticket not found');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Invalid status: ${e.response!.data}');
      } else if (e.response != null) {
        throw Exception('Failed to update ticket status: ${e.response!.data}');
      } else {
        throw Exception('Failed to update ticket status: ${e.message}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> deleteTicket(String ticketId) async {
    try {
      final response = await _dio.delete('/support/tickets/$ticketId');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Ticket not found');
      } else if (e.response != null) {
        throw Exception('Failed to delete ticket: ${e.response!.data}');
      } else {
        throw Exception('Failed to delete ticket: ${e.message}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> createMessage(
      String ticketId,
      CreateMessageData data,
      ) async {
    try {
      final response = await _dio.post(
        '/support/tickets/$ticketId/messages',
        data: data.toJson(),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Ticket not found');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Invalid message data: ${e.response!.data}');
      } else if (e.response != null) {
        throw Exception('Failed to send message: ${e.response!.data}');
      } else {
        throw Exception('Failed to send message: ${e.message}');
      }
    }
  }
}