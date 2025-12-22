class TransactionQueryDto {
  final String? accountId;
  final String? scope;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final int? offset;

  TransactionQueryDto({
    this.accountId,
    this.scope,
    this.startDate,
    this.endDate,
    this.limit,
    this.offset,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (scope != null) params['scope'] = scope;
    if (startDate != null) params['start_date'] = startDate!.toIso8601String();
    if (endDate != null) params['end_date'] = endDate!.toIso8601String();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();

    return params;
  }
}