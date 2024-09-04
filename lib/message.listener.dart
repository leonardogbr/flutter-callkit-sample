import 'dart:async';

import 'package:blip_sdk/blip_sdk.dart';

class MessageListener {
  final listener = StreamController<Message>();

  StreamController<dynamic> ticketMessagelistener = StreamController<dynamic>();

  void listen() {
    listener.stream.listen(
      (Message message) async {
        print('Message: $message');
      },
    );
  }
}
