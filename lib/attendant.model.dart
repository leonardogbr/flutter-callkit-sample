import 'package:blip_sdk/blip_sdk.dart';

import 'attendat_status.enum.dart';

class Attendant {
  static const String mimeType = 'application/vnd.iris.desk.attendant+json';

  Identity identity;
  String? fullName;
  String? email;
  List<dynamic>? teams;
  AttendantStatus status;
  DateTime? lastServiceDate;
  int? agentSlots;
  int? ticketsInService;
  bool? isEnabled;

  Attendant({
    required this.identity,
    required this.status,
    this.fullName,
    this.email,
    this.teams,
    this.lastServiceDate,
    this.agentSlots,
    this.ticketsInService,
    this.isEnabled,
  });

  factory Attendant.fromJson(Map<String, dynamic> json) => Attendant(
        identity: Identity.parse(json['identity']),
        status: AttendantStatus.unknown.getValue(json['status']),
        fullName: json['fullName'],
        email: json['email'],
        teams: json['teams'],
        lastServiceDate: DateTime.tryParse(json['lastServiceDate'] ?? ''),
        agentSlots: json['agentSlots'],
        ticketsInService: json['ticketsInService'],
        isEnabled: json['isEnabled'],
      );
}
