import 'package:blip_sdk/blip_sdk.dart';
import 'package:flutter/material.dart';

class User {
  String fullName;
  String email;
  Identity identity;
  Locale? culture;
  DateTime creationDate;
  Identity? alternativeAccount;
  Uri? photoUri;
  String? phoneNumber;
  Map<String, dynamic>? extras;

  User({
    required this.fullName,
    required this.email,
    required this.identity,
    this.culture,
    required this.creationDate,
    this.alternativeAccount,
    this.photoUri,
    this.phoneNumber,
    this.extras,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final country = json.containsKey('culture')
        ? json['culture'].contains('/')
            ? json['culture'].split('-')[0]
            : json['culture']
        : null;

    final culture = country == 'en'
        ? const Locale('en', 'US')
        : country == 'es'
            ? const Locale('es', 'LA')
            : const Locale('pt', 'BR');

    return User(
      fullName: json['fullName'],
      email: json['email'],
      identity: Identity.parse(json['identity']),
      culture: culture,
      creationDate: DateTime.parse(json['creationDate']),
      alternativeAccount: json['alternativeAccount'] != null
          ? Identity.parse(json['alternativeAccount'])
          : null,
      photoUri: json['photoUri'] != null ? Uri.parse(json['photoUri']) : null,
      phoneNumber: json['phoneNumber'],
      extras: json['extras'],
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'identity': identity.toString(),
        'culture': culture?.toString().replaceAll('_', '-'),
        'creationDate': creationDate.toIso8601String(),
        'alternativeAccount': alternativeAccount?.toString(),
        'photoUri': photoUri?.toString(),
        'phoneNumber': phoneNumber?.toString(),
        'extras': extras,
      };
}
