import 'invoice.dart';

enum RecurringInterval { daily, weekly, monthly, yearly }

class RecurringProfile {
  final String id;
  final String profileId; // Belongs to which business profile
  final RecurringInterval interval;
  final DateTime nextRunDate;
  final DateTime? lastRunDate;
  final bool isActive;
  final Invoice baseInvoice; // Template data

  const RecurringProfile({
    required this.id,
    required this.profileId,
    required this.interval,
    required this.nextRunDate,
    this.lastRunDate,
    this.isActive = true,
    required this.baseInvoice,
  });

  RecurringProfile copyWith({
    String? id,
    String? profileId,
    RecurringInterval? interval,
    DateTime? nextRunDate,
    DateTime? lastRunDate,
    bool? isActive,
    Invoice? baseInvoice,
  }) {
    return RecurringProfile(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      interval: interval ?? this.interval,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      lastRunDate: lastRunDate ?? this.lastRunDate,
      isActive: isActive ?? this.isActive,
      baseInvoice: baseInvoice ?? this.baseInvoice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'interval': interval.index,
      'nextRunDate': nextRunDate.toIso8601String(),
      'lastRunDate': lastRunDate?.toIso8601String(),
      'isActive': isActive,
      'baseInvoice': baseInvoice.toJson(),
    };
  }

  factory RecurringProfile.fromJson(Map<String, dynamic> json) {
    return RecurringProfile(
      id: json['id'],
      profileId: json['profileId'],
      interval: RecurringInterval.values[json['interval']],
      nextRunDate: DateTime.parse(json['nextRunDate']),
      lastRunDate: json['lastRunDate'] != null
          ? DateTime.parse(json['lastRunDate'])
          : null,
      isActive: json['isActive'] ?? true,
      baseInvoice: Invoice.fromJson(json['baseInvoice']),
    );
  }
}
