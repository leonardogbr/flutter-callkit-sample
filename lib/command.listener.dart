import 'dart:async';

import 'package:blip_sdk/blip_sdk.dart';
import 'package:ios_callkit_sample/callkit.service.dart';

import 'incoming_call.model.dart';

class CommandListener {
  final listener = StreamController<Command>();

  void listen() {
    listener.stream.listen((Command command) async {
      print(
        'command: $command',
      );
      if (isIncomingCall(command)) {
        CallkitService(IncomingCall.fromJson(command.resource)).receiveCall();
      }
      //  else if (isFinishingCall(command)) {
      //   // CallkitService(command.resource).receiveCall();
      // }
    });
  }

  bool isIncomingCall(Command command) =>
      command.type ==
      'application/vnd.iris.calls.incoming-call-notification+json';
  // bool isFinishingCall(Command command) =>
  //     command.type ==
  //     'application/vnd.iris.calls.finishing-call-notification+json';
}
