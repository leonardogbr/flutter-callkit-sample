import 'dart:convert';

import 'package:blip_sdk/blip_sdk.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'client.service.dart';
import 'incoming_call.model.dart';

const uuid = Uuid();

class CallkitService {
  final IncomingCall _incomingCall;

  CallkitService(this._incomingCall);

  static const _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun.l.google.com:19302',
        ]
      }
    ]
  };

  final _currentUuid = uuid.v4();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool hasMicrophonePermission = false;
  bool hasCallInProgress = false;

  Future<void> requestPermission() async {
    await FlutterCallkitIncoming.requestNotificationPermission({
      "rationaleMessagePermission":
          "Notification permission is required, to show notification.",
      "postNotificationMessageRequired":
          "Notification permission is required, Please allow notification permission from setting."
    });
  }

  Future<void> receiveCall() async {
    if (!await _hasMicrophonePermission()) {
      return;
    }

    await requestPermission();
    _initListeners();

    await _createConnection();
    await _initCallkit();

    // print('resource: $resource');
  }

  void _initListeners() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      switch (event!.event) {
        case Event.actionCallIncoming:
          // TODO: received an incoming call
          print('received an incoming call');
          break;
        case Event.actionCallStart:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          print('started an outgoing call');
          break;
        case Event.actionCallAccept:
          // TODO: accepted an incoming call
          // TODO: show screen calling in Flutter
          _answer();
          print('accepted an incoming call');
          break;
        case Event.actionCallDecline:
          // TODO: declined an incoming call
          print('declined an incoming call');
          break;
        case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call
          print('ended an incoming/outgoing call');
          break;
        case Event.actionCallTimeout:
          // TODO: missed an incoming call
          print('missed an incoming call');
          break;
        case Event.actionCallCallback:
          // TODO: only Android - click action `Call back` from missed call notification
          print(
              'only Android - click action `Call back` from missed call notification');
          break;
        case Event.actionCallToggleHold:
          // TODO: only iOS
          print('toggle hold only iOS');
          break;
        case Event.actionCallToggleMute:
          // TODO: only iOS
          print('toggle mute only iOS');
          break;
        case Event.actionCallToggleDmtf:
          // TODO: only iOS
          print('toggle DMTF only iOS');
          break;
        case Event.actionCallToggleGroup:
          // TODO: only iOS
          print('toggle group only iOS');
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: only iOS
          print('toggle audio session only iOS');
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: only iOS
          print('update device push token voip only iOS');
          break;
        case Event.actionCallCustom:
          // TODO: for custom action
          print('for custom action');
          break;
      }
    });
  }

  Future<bool> _hasMicrophonePermission() async {
    return await Permission.microphone.request().isGranted;
  }

  Future<void> _createConnection() async {
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onConnectionState = (state) {
      // log('onConnectionState: $state');

      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          // callStatus.value = CallsStatus.inProgress;
          hasCallInProgress = true;
          // _stopwatch.start();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          print('onError: $state');
          // _onError();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          // callStatus.value = CallsStatus.ended;
          // closeCalls();
          print('onDisconnected: $state');
          break;
        default:
      }
    };

    _localStream = await _getUserMedia();

    if (_peerConnection != null && _localStream != null) {
      final futures = <Future>[];

      for (var track in _localStream!.getTracks()) {
        futures.add(_peerConnection!.addTrack(track, _localStream!));
      }

      await Future.wait(futures);
    }

    // Timer.periodic(
    //   const Duration(seconds: 1),
    //   (_) => _recordDuration.value = _stopwatch.elapsed,
    // );
  }

  Future<MediaStream> _getUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': false,
    };

    return navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  Future<void> _answer() async {
    try {
      // isAnswering.value = true;

      final remoteSDP = _incomingCall.connection.webrtc['sdp'];
      final sessionId = _incomingCall.sessionId;
      final ownerIdentity = _incomingCall.ownerIdentity;
      final json = jsonDecode(remoteSDP);
      final sdp = json['sdp'];
      final type = json['type'];

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp, type),
      );

      final answer = await _peerConnection!.createAnswer();

      await _peerConnection!.setLocalDescription(answer);

      await ClientService.sendCommand(
        Command(
          method: CommandMethod.set,
          to: Node.parse('postmaster@desk.msging.net'),
          type: 'application/vnd.iris.calls.incoming-call-answer+json',
          uri: "lime://$ownerIdentity/calls/session/$sessionId/answer",
          resource: {
            'action': 'accept',
            'connection': {
              'webrtc': {
                'sdp': jsonEncode(answer.toMap()),
              }
            }
          },
        ),
      );

      // callStatus.value = CallsStatus.answered;

      // SegmentService.createTrack(
      //   SegmentEvent.deskCallIncomingAnswered,
      // );
    } on LimeException catch (error) {
      // _onError(error: error);
      print('error: $error');
    } finally {
      _localStream?.getAudioTracks().forEach((track) {
        track.enableSpeakerphone(false);
      });

      // isAnswering.value = false;
    }
  }

  Future<void> _initCallkit() async {
    CallKitParams callKitParams = CallKitParams(
      id: _currentUuid,
      nameCaller: 'Leonardo G.',
      appName: 'Blip Desk',
      avatar: 'https://i.pravatar.cc/300',
      handle: '0123456789',
      type: 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      duration: 30000,
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'https://i.pravatar.cc/500',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        isShowCallID: false,
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }
}
