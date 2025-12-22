import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/ticket_entity.dart';
import '../controller/support_controller.dart';

class SupportTicketsPage extends StatelessWidget {
  final SupportController controller = Get.find<SupportController>();

  SupportTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.toNamed('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.fetchTickets,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 16),
                Text('Loading tickets...'),
              ],
            ),
          );
        }

        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    final stats = controller.getTicketStatistics();

    return Column(
      children: [
        // Statistics
        _buildStatistics(stats),
        const SizedBox(height: 8),

        // Tickets List
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.fetchTickets,
            child: controller.tickets.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Support Tickets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a new ticket to get started',
                    style: TextStyle(color: Colors.grey),
                  ),

                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.tickets.length,
              itemBuilder: (context, index) {
                final ticket = controller.tickets[index];
                return _buildTicketCard(ticket);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', stats['total']!, Colors.teal),
          _buildStatItem('Open', stats['open']!, Colors.blue),
          _buildStatItem('Pending', stats['pending']!, Colors.orange),
          _buildStatItem('Closed', stats['closed']!, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTicketCard(TicketEntity ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ticket.status.color.withOpacity(0.1),
          child: Icon(
            ticket.status.icon,
            color: ticket.status.color,
          ),
        ),
        title: Text(
          ticket.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'By: ${ticket.owner.name}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              'Last activity: ${DateFormat('MMM dd, HH:mm').format(ticket.lastMessageAt)}',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                ticket.status.value.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: ticket.status.color,
                ),
              ),
              backgroundColor: ticket.status.color.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
            if (ticket.priority != 'normal')
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(ticket.priority),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ticket.priority.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showTicketDetails(ticket),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'normal':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }


  void _showTicketDetails(TicketEntity ticket) {
    Get.to(
          () => TicketDetailPage(ticket: ticket),
      transition: Transition.rightToLeft,
    );
  }
}

class TicketDetailPage extends StatelessWidget {
  final TicketEntity ticket;
  final SupportController controller = Get.find<SupportController>();

  TicketDetailPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        backgroundColor: Colors.teal[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(value, ticket.publicId),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                ),
              ),
              const PopupMenuItem(
                value: 'close',
                child: ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text('Mark as Closed'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete Ticket'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final currentTicket = controller.selectedTicket.value ?? ticket;

        return Column(
          children: [
            // Ticket Header
            _buildTicketHeader(currentTicket),
            const Divider(height: 1),

            // Messages
            Expanded(
              child: _buildMessagesList(currentTicket),
            ),

            // Message Input
            _buildMessageInput(currentTicket.publicId),
          ],
        );
      }),
    );
  }

  Widget _buildTicketHeader(TicketEntity ticket) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  ticket.status.value.toUpperCase(),
                  style: TextStyle(
                    color: ticket.status.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: ticket.status.color.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Created by ${ticket.owner.name} (${ticket.owner.email})',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Created: ${DateFormat('MMMM dd, yyyy HH:mm').format(ticket.createdAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (ticket.assignedTo != null) ...[
            const SizedBox(height: 4),
            Text(
              'Assigned to: ${ticket.assignedTo!.name}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessagesList(TicketEntity ticket) {
    final messages = ticket.messages ?? [];

    if (messages.isEmpty) {
      return const Center(
        child: Text('No messages yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(TicketMessage message) {
    final isCurrentUser = message.sender.id == 1; // Assuming admin user ID is 1

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.teal[100],
              child: Text(
                message.sender.name[0],
                style: const TextStyle(color: Colors.teal),
              ),
            ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: isCurrentUser ? 60 : 8,
                right: isCurrentUser ? 0 : 60,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.teal : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        message.sender.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isCurrentUser
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.body,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                    ),
                  ),
                  if (message.isInternal) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Internal Note',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isCurrentUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.teal[700],
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(String ticketId) {
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Form(
        key: formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: messageController,
                cursorColor: Colors.teal,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 3,
                minLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => IconButton(
              onPressed: controller.isSendingMessage.value
                  ? null
                  : () async {
                if (formKey.currentState!.validate()) {
                  await controller.sendMessage(
                    ticketId,
                    messageController.text,
                  );
                  messageController.clear();
                }
              },
              icon: controller.isSendingMessage.value
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Icon(Icons.send),
              color: Colors.teal,
            )),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, String ticketId) {
    switch (action) {
      case 'refresh':
        controller.fetchTicketDetail(ticketId);
        break;
      case 'close':
        controller.updateTicketStatus(ticketId, 'closed');
        break;
      case 'delete':
        _confirmDeleteTicket(ticketId);
        break;
    }
  }

  void _confirmDeleteTicket(String ticketId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Ticket'),
        content: const Text('Are you sure you want to delete this ticket?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel',style:TextStyle(color: Colors.teal),),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteTicket(ticketId);
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Delete',style: TextStyle(color: Colors.teal),),
          ),
        ],
      ),
    );
  }
}