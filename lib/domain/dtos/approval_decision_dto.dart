class ApprovalDecisionData {
  final String decision; // 'approve' or 'reject'
  final String? note;

  ApprovalDecisionData({
    required this.decision,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'decision': decision,
      'note': note,
    };
  }
}