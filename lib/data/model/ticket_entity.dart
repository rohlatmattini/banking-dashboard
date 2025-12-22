import '../../domain/entities/ticket_entity.dart';

class TicketModel extends TicketEntity {
  TicketModel({
    required super.publicId,
    required super.subject,
    required super.status,
    super.category,
    required super.priority,
    required super.owner,
    super.assignedTo,
    required super.lastMessageAt,
    super.resolvedAt,
    super.closedAt,
    required super.createdAt,
    required super.updatedAt,
    super.messages,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      return DateTime.parse(value.toString());
    }

    TicketOwner parseOwner(Map<String, dynamic> ownerData) {
      return TicketOwner(
        id: ownerData['id'] as int,
        publicId: ownerData['public_id'] as String,
        name: ownerData['name'] as String,
        email: ownerData['email'] as String,
      );
    }

    TicketAssignee? parseAssignee(Map<String, dynamic>? assigneeData) {
      if (assigneeData == null) return null;
      return TicketAssignee(
        id: assigneeData['id'] as int,
        publicId: assigneeData['public_id'] as String,
        name: assigneeData['name'] as String,
        email: assigneeData['email'] as String,
      );
    }

    List<TicketMessage> parseMessages(List<dynamic>? messagesData) {
      if (messagesData == null) return [];
      return messagesData.map((msg) {
        return TicketMessage(
          id: msg['id'] as int,
          body: msg['body'] as String,
          isInternal: msg['is_internal'] as bool,
          sender: TicketSender(
            id: msg['sender']['id'] as int,
            publicId: msg['sender']['public_id'] as String,
            name: msg['sender']['name'] as String,
            email: msg['sender']['email'] as String,
          ),
          createdAt: DateTime.parse(msg['created_at'] as String),
        );
      }).toList();
    }

    return TicketModel(
      publicId: json['public_id'] as String,
      subject: json['subject'] as String,
      status: TicketStatus.fromValue(json['status'] as String),
      category: json['category'] as String?,
      priority: json['priority'] as String? ?? 'normal',
      owner: parseOwner(Map<String, dynamic>.from(json['owner'])),
      assignedTo: json['assigned_to'] != null
          ? parseAssignee(Map<String, dynamic>.from(json['assigned_to']))
          : null,
      lastMessageAt: parseDateTime(json['last_message_at'])!,
      resolvedAt: parseDateTime(json['resolved_at']),
      closedAt: parseDateTime(json['closed_at']),
      createdAt: parseDateTime(json['created_at'])!,
      updatedAt: parseDateTime(json['updated_at'])!,
      messages: json['messages'] != null
          ? parseMessages(List<dynamic>.from(json['messages']))
          : null,
    );
  }
}