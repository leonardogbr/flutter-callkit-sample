import 'package:blip_sdk/blip_sdk.dart';
import 'package:flutter/material.dart';

import 'attendant.model.dart';
import 'attendat_status.enum.dart';
import 'client.service.dart';
import 'user.model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ClientService client;

  User? _me;
  AttendantStatus _lastStatusOnDatabase = AttendantStatus.unknown;
  AttendantStatus _currentStatus = AttendantStatus.unknown;

  @override
  void initState() {
    super.initState();

    ClientService.init(
      buildContext: context,
      identifier: 'leonardo.gabriel%40blip.ai',
      token:
          'eyJhbGciOiJSUzI1NiIsImtpZCI6IjYyN2JjMGZjOTZmZmNiMWM1NDRkZDY2NGI2ODQwYWNmIiwidHlwIjoiSldUIn0.eyJuYmYiOjE3MjUzOTQyMjAsImV4cCI6MTcyNTQ4MDYyMCwiaXNzIjoiaHR0cHM6Ly9hY2NvdW50LmJsaXAuYWkiLCJhdWQiOiJodHRwczovL2FjY291bnQuYmxpcC5haS9yZXNvdXJjZXMiLCJjbGllbnRfaWQiOiJibGlwLWRlc2siLCJzdWIiOiJiODk4NjI3Zi1jNGQ5LTQyMTQtYTdmNS0yYmFmNmM3OTIzNmIiLCJhdXRoX3RpbWUiOjE3MjUzODQ3MTYsImlkcCI6Imdvb2dsZSIsIlByb3ZpZGVyRGlzcGxheU5hbWUiOiJnb29nbGUiLCJGdWxsTmFtZSI6Ikxlb25hcmRvIEdhYnJpZWwiLCJVc2VyTmFtZSI6Imxlb25hcmRvLmdhYnJpZWxAYmxpcC5haSIsIkZpcnN0TmFtZSI6Ikxlb25hcmRvIiwiU3VyTmFtZSI6IkdhYnJpZWwiLCJjdWx0dXJlIjoiZW4iLCJDb21wYW55TnVtYmVyT2ZFbXBsb3llZXMiOiJCYW5kMTAwMF8xMDAwMCIsIkNvbXBhbnlTaXRlIjoidGFsZS5uZXQiLCJQaG9uZU51bWJlciI6Iis1NSAoNTQpIDk5MjA5LTk1NDQiLCJDcmVhdGVkQnlOZXdBY2NvdW50UmVnaXN0ZXIiOiJGYWxzZSIsIkVtYWlsIjoibGVvbmFyZG8uZ2FicmllbEBibGlwLmFpIiwiRW1haWxDb25maXJtZWQiOiJUcnVlIiwic2NvcGUiOlsib3BlbmlkIiwicHJvZmlsZSIsImVtYWlsIl0sImFtciI6WyJleHRlcm5hbCJdfQ.thFSeouTUjwp08vfBKteKk1twMhJ-nuikEPhy_GxrbDxPfPyHuihNHasUk_Z5j8TghYsQ5-VV6MzQOKmNhA42pAEuvEgsgTzujJuCTsreG2o0WCUrPE5VjrUn06vst5THKpwKw62AODraqaFKGwZIzH5UMspxSCvr6t-zcMH1Ikfk65uZDR6h3emDWgpf8YAtbUZVVFzyMH44MCdTXb6vvjvPCncjm53hrOxKkzwrjoid5GyAs6V0d2-A2q1Noqbe0FS1ZMhb9G-yHG1v0IBZ0EfleJ3FhUSG6QXlVM-jKtpZPJODJOGAZMsP5GNvQueCXzvdFbdPEaqP8LMk9mfNg',
    );

    ClientService.connectionListener.stream.listen((connected) async {
      if (connected) {
        await _setUser();
        await _setUserStatus();
      }
    });
  }

  Future<void> _setAgentStatusOnline(AttendantStatus status) async {
    try {
      await ClientService.sendCommand(
        Command(
          method: CommandMethod.set,
          type: 'application/vnd.iris.desk.attendant-status-device+json',
          to: Node.parse('postmaster@desk.msging.net'),
          uri: '/attendants/change-status',
          resource: {
            'status': status == AttendantStatus.online ? 'Online' : 'Invisible',
            'device': 'Mobile',
          },
        ),
      );

      setState(() => _currentStatus = status);
    } catch (e) {
      print('Error setting status to online: $e');
    }
  }

  Future<void> _setUser() async {
    try {
      final result = await ClientService.sendCommand(
        Command(
          method: CommandMethod.get,
          uri: '/account',
        ),
      );

      setState(
        () => _me = User.fromJson(result.resource),
      );
    } catch (e, stackTrace) {
      print('Error setting user: $e - $stackTrace');

      rethrow;
    }
  }

  Future<void> _getLastAgentStatusFromDatabase(final Identity identity) async {
    final command = await ClientService.sendCommand(
      Command(
        id: guid(),
        method: CommandMethod.get,
        to: Node.parse('postmaster@desk.msging.net'),
        uri:
            '/agents/status?ownerIdentity=${Uri.encodeComponent(identity.toString())}',
      ),
    );

    final result = Attendant.fromJson(command.resource);

    setState(() {
      _lastStatusOnDatabase = result.status;
      _currentStatus = result.status;
    });
  }

  Future<void> _setUserStatus() async {
    try {
      await _getLastAgentStatusFromDatabase(_me!.identity);

      final shouldKeepAgentOnline =
          _lastStatusOnDatabase == AttendantStatus.online;

      await _setAgentStatusOnline(
        shouldKeepAgentOnline
            ? AttendantStatus.online
            : AttendantStatus.invisible,
      );

      await _setPresence(PresenceStatus.available);
    } catch (e, stackTrace) {
      print('Error setting user status: $e - $stackTrace');

      await _setAgentStatusOnline(AttendantStatus.offline);
      await _setPresence(PresenceStatus.unavailable);

      rethrow;
    }
  }

  Future<Command> _setPresence(final PresenceStatus presence) {
    return ClientService.sendCommand(
      Command(
        method: CommandMethod.set,
        type: Presence.mimeType,
        uri: '/presence',
        resource: Presence(
          status: presence,
          routingRule: RoutingRule.identity,
          echo: false,
        ).toJson(),
        metadata: {
          'server.shouldStore': false,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _currentStatus.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _me?.fullName ?? 'Sem Nome',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _me?.email ?? 'Sem Email',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _setAgentStatusOnline(AttendantStatus.online),
        tooltip: 'Set status to online',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
