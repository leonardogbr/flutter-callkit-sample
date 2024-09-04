import 'package:blip_sdk/blip_sdk.dart';

import 'connection.model.dart';

class IncomingCall {
  String sessionId;
  Identity ownerIdentity;
  Connection connection;
  String ticketId;

  IncomingCall({
    required this.sessionId,
    required this.ownerIdentity,
    required this.connection,
    required this.ticketId,
  });

  IncomingCall.fromJson(Map<String, dynamic> json)
      : sessionId = json['sessionId'],
        ownerIdentity = Identity.parse(json['ownerIdentity']),
        connection = Connection.fromJson(json['connection']),
        ticketId = json['ticketId'];

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'ownerIdentity': ownerIdentity.toString(),
      'connection': connection.toJson(),
      'ticketId': ticketId,
    };
  }
}
