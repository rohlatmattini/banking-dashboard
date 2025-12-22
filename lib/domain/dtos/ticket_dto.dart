class CreateTicketData {
  final String subject;
  final String message;
  final String? category;
  final String? priority;

  CreateTicketData({
    required this.subject,
    required this.message,
    this.category,
    this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'message': message,
      'category': category,
      'priority': priority,
    };
  }
}

class UpdateTicketStatusData {
  final String status;

  UpdateTicketStatusData({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status};
  }
}

class CreateMessageData {
  final String body;
  final bool? isInternal;

  CreateMessageData({
    required this.body,
    this.isInternal = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'is_internal': isInternal,
    };
  }
}