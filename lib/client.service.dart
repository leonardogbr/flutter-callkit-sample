import 'dart:async';

import 'package:blip_sdk/blip_sdk.dart';
import 'package:flutter/material.dart';
import 'package:ios_callkit_sample/command.listener.dart';
import 'package:ios_callkit_sample/message.listener.dart';

abstract class ClientService {
  static late BuildContext context;
  static late final Client sdkClient;

  static final connectionListener = StreamController<bool>.broadcast();

  static void Function()? removeSessionFailedHandler;
  static void Function()? removeCommandListener;
  static void Function()? removeMessageListener;

  static var sessionFailedHandler = StreamController<Session>();
  static var commandListener = CommandListener();
  static var messageListener = MessageListener();

  static var hasMultipleInstances = false;

  static Future<void> init({
    required String identifier,
    required String token,
    required BuildContext buildContext,
  }) async {
    context = buildContext;
    await login(identifier, token);
  }

  static Future<void> login(String identifier, String token) async {
    final sdkClientBuilder = ClientBuilder(transport: WebSocketTransport())
        .withIdentifier(identifier)
        .withEcho(false)
        .withNotifyConsumed(false)
        .withDomain('blip.ai')
        .withHostName('compliance-c5a30.ws.blip.ai')
        .withPort(443)
        .withScheme('wss')
        .withInstance('!desk')
        .withCommandTimeout(6000)
        .withToken(token, 'account.blip.ai')
        .withConnectionFunction(() => Future.value());

    sdkClient = sdkClientBuilder.build();

    removeSessionFailedHandler =
        sdkClient.addSessionFailedHandlers(sessionFailedHandler);
    removeCommandListener =
        sdkClient.addCommandListener(commandListener.listener);
    removeMessageListener =
        sdkClient.addMessageListener(messageListener.listener);

    sessionFailedHandler.stream.listen(
      (session) {
        final isInstanceOverwritten = session.reason?.code == 11 &&
            session.reason?.description ==
                'The session instance was overwritten by a other session with the same instance';

        if (isInstanceOverwritten) {
          hasMultipleInstances = true;

          sdkClient.close();
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                title: Text('Multiple instances'),
                content: Text(
                  'There are multiple instances of the same session. Please close the app and try again.',
                ),
              ),
            );
          }
        }
      },
    );
    commandListener.listen();
    messageListener.listen();

    try {
      await sdkClient.connect();
      connectionListener.add(true);
    } catch (e, stackTrace) {
      sdkClient.close();
      connectionListener.add(false);

      print('Error: $e - $stackTrace');

      rethrow;
    }
  }

  static Future<Command> sendCommand(Command command, {timeout}) async {
    timeout ??= 61000;

    _injectSaveCommandMetadata(command);

    return await sdkClient.sendCommand(
      command,
      timeout: timeout,
    );
  }

  static void _injectSaveCommandMetadata(Command requestCommand) {
    requestCommand.metadata ??= {};
    if (requestCommand.uri != '/tickets/waiting') {
      requestCommand.metadata = {'server.shouldStore': true};
    }
  }
}
