import 'dart:ui';
import 'package:flutter/material.dart';
class TicketEntity {
  final String publicId;
  final String subject;
  final TicketStatus status;
  final String? category;
  final String priority;
  final TicketOwner owner;
  final TicketAssignee? assignedTo;
  final DateTime lastMessageAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketMessage>? messages;

  TicketEntity({
    required this.publicId,
    required this.subject,
    required this.status,
    this.category,
    required this.priority,
    required this.owner,
    this.assignedTo,
    required this.lastMessageAt,
    this.resolvedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });
}

class TicketOwner {
  final int id;
  final String publicId;
  final String name;
  final String email;

  TicketOwner({
    required this.id,
    required this.publicId,
    required this.name,
    required this.email,
  });
}

class TicketAssignee {
  final int id;
  final String publicId;
  final String name;
  final String email;

  TicketAssignee({
    required this.id,
    required this.publicId,
    required this.name,
    required this.email,
  });
}

class TicketMessage {
  final int id;
  final String body;
  final bool isInternal;
  final TicketSender sender;
  final DateTime createdAt;

  TicketMessage({
    required this.id,
    required this.body,
    required this.isInternal,
    required this.sender,
    required this.createdAt,
  });
}

class TicketSender {
  final int id;
  final String publicId;
  final String name;
  final String email;

  TicketSender({
    required this.id,
    required this.publicId,
    required this.name,
    required this.email,
  });
}

enum TicketStatus {
  OPEN('open'),
  PENDING_STAFF('pending_staff'),
  IN_PROGRESS('in_progress'),
  RESOLVED('resolved'),
  CLOSED('closed');

  final String value;

  const TicketStatus(this.value);

  static TicketStatus fromValue(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => OPEN,
    );
  }

  Color get color {
    switch (this) {
      case TicketStatus.OPEN:
        return Colors.blue;
      case TicketStatus.PENDING_STAFF:
        return Colors.orange;
      case TicketStatus.IN_PROGRESS:
        return Colors.purple;
      case TicketStatus.RESOLVED:
        return Colors.green;
      case TicketStatus.CLOSED:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case TicketStatus.OPEN:
        return Icons.circle_outlined;
      case TicketStatus.PENDING_STAFF:
        return Icons.pending;
      case TicketStatus.IN_PROGRESS:
        return Icons.hourglass_bottom;
      case TicketStatus.RESOLVED:
        return Icons.check_circle;
      case TicketStatus.CLOSED:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}