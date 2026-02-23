import 'package:invobharat/models/invoice.dart';

enum RecurringInterval { daily, weekly, monthly, yearly }

class RecurringProfile {
  final String id;
  final String profileId; // Belongs to which business profile
  final RecurringInterval interval;
  final DateTime nextRunDate;
  final DateTime? lastRunDate;
  final bool isActive;
  final int? dueDays; // NEW: Days until due from invoice date
  final Invoice baseInvoice; // Template data

  const RecurringProfile({
    required this.id,
    required this.profileId,
    required this.interval,
    required this.nextRunDate,
    this.lastRunDate,
    this.isActive = true,
    this.dueDays,
    required this.baseInvoice,
  });

  RecurringProfile copyWith({
    final String? id,
    final String? profileId,
    final RecurringInterval? interval,
    final DateTime? nextRunDate,
    final DateTime? lastRunDate,
    final bool? isActive,
    final int? dueDays,
    final Invoice? baseInvoice,
  }) {
    return RecurringProfile(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      interval: interval ?? this.interval,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      lastRunDate: lastRunDate ?? this.lastRunDate,
      isActive: isActive ?? this.isActive,
      dueDays: dueDays ?? this.dueDays,
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
      'dueDays': dueDays,
      'baseInvoice': baseInvoice.toJson(),
    };
  }

  factory RecurringProfile.fromJson(final Map<String, dynamic> json) {
    return RecurringProfile(
      id: json['id'],
      profileId: json['profileId'],
      interval: RecurringInterval.values[json['interval']],
      nextRunDate: DateTime.parse(json['nextRunDate']),
      lastRunDate: json['lastRunDate'] != null
          ? DateTime.parse(json['lastRunDate'])
          : null,
      isActive: json['isActive'] ?? true,
      dueDays: json['dueDays'],
      baseInvoice: Invoice.fromJson(json['baseInvoice']),
    );
  }
}
