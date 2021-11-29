import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/models/utils.dart';
import 'package:sdp_transform/sdp_transform.dart';

import '../call_view.dart';
import 'auth_model.dart';
import 'user_model.dart';



enum SignalingState {
  connectionOpen,
  connectionClosed,
  connectionError,
}


enum CallState {
  callStateNew,
  callStateRinging,
  callStateInvite,
  callStateConnected,
  callStateBye,
}

typedef SignalingStateCallback = void Function(SignalingState state);
typedef CallStateCallback = void Function(Session session, CallState state);
typedef StreamStateCallback = void Function(Session? session, MediaStream stream);
typedef OtherEventCallback = void Function(dynamic event);

class Session {
  Session({this.sid="", this.pid=""});
  String pid;
  String sid;
  RTCPeerConnection? pc;
  List<RTCIceCandidate> remoteCandidates = [];
}

class CallManager {
  late BuildContext context;
  static CallManager get instance => _getInstance();
  static CallManager? _instance;

  static CallManager _getInstance () {
    _instance ??= CallManager._internal();
    return _instance!;
  }
  dynamic channel;
  var deviceId;
  CallManager._internal();
  init(BuildContext context) async {
    this.context = context;
    channel = Provider.of<Auth>(context, listen: false).channel;
    deviceId = await Utils.getDeviceId();
  }


  late SignalingStateCallback onSignalingStateChange;
  late CallStateCallback onCallStateChange;
  late StreamStateCallback onLocalStream;
  late StreamStateCallback onAddRemoteStream;
  late StreamStateCallback onRemoveRemoteStream;
  late OtherEventCallback onPeersUpdate;

  MediaStream? localStream;
  late String _selfId;
  final Map<String, Session> _sessions={};
  bool isMuteMic = false;
  bool isOnVideo = false;
  void onMessage (message, context) async {
    switch (message['type']) {
      case "offer":
        _selfId = Provider.of<User>(context, listen: false).me["user_id"];
        var sessionId = message["session_id"];
        var peer = message["from"];
        var peerId = peer["user_id"];
        var session = Session(pid: peerId, sid: sessionId);
        
        Future<void> onDoneView () async {
          var newSession = await _createSession(session: session, peerId: peerId, sessionId: sessionId);
          // print("Create Session Done >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
          if (_sessions[sessionId] != null) {
            newSession = mergeSession(newSession, _sessions[sessionId]!);
          }
          _sessions[sessionId] = newSession;
          var sdpSession = await jsonDecode(message["description"]);
          String sdp = write(sdpSession, null);
          RTCSessionDescription description = RTCSessionDescription(sdp, "offer");
          await newSession.pc!.setRemoteDescription(description);
          await _createAnswer(newSession);
          // print("Candidate lenght>>>>>>>>>>>>>>>>>>>>>>>>>>>: ${newSession.remoteCandidates.length}");
          if (newSession.remoteCandidates.isNotEmpty) {
            for (var candidate in newSession.remoteCandidates) {
              // print("Add candidate from host>>>>>>>>>>>>>>>>>>>>>>");
              await newSession.pc!.addCandidate(candidate);
            }
            newSession.remoteCandidates.clear();
          }

        }
        Navigator.push(context,
          PageRouteBuilder(pageBuilder: (context, ani1, ani2){
            return CallView(type: "answer", user: peer,session: session,onDoneView: onDoneView);
          })
        );
        break;
      case "answer":
        var sessionId = message["session_id"];

        var sdpSession = await jsonDecode(message["description"]);
        String sdp = write(sdpSession, null);
        RTCSessionDescription description = RTCSessionDescription(sdp, "answer");
        Session session = _sessions[sessionId]!;
        session.pc!.setRemoteDescription(description);
        onCallStateChange.call(session, CallState.callStateConnected);
        break;
      case "candidate":
        var peerId = message["from"];
        var sessionId = message["session_id"];
        Session? session = _sessions[sessionId];
        RTCIceCandidate candidate = RTCIceCandidate(message["candidate"], message["sdpMid"], message["sdpMlineIndex"]);
        if (session != null) {
          if (session.pc != null) {
            print("Add candidate from socket >>>>>>>>>>>>>>>>>>>>>>>>>>");
            await session.pc!.addCandidate(candidate);
          }
          else {
            session.remoteCandidates.add(candidate);
          }
        }
        else {
          _sessions[sessionId] = Session(pid: peerId, sid: sessionId)..remoteCandidates.add(candidate);
        }
        break;
      case "broad_cast":
        var otherDevice = message["device_id"];
        var sessionId = message["session_id"];
        var session = _sessions[sessionId];
        if (deviceId != otherDevice) {
          onCallStateChange.call(session!, CallState.callStateBye);
        }
        break;
      case "call_end":
        var sessionId = message["session_id"];
        print("$sessionId >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        print(_sessions);
        if (_sessions[sessionId] != null) {
          onCallStateChange.call(_sessions[sessionId]!, CallState.callStateBye);
          closeSession(_sessions[sessionId]!);
        }
        break;
    }
  }
  Map<String, dynamic> configuration = {
    "iceServers": [
      {
        'url': "turn:113.20.119.31:3478",
        'username': "panchat",
        'credential': "panchat"
      },
    ]
  };
  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  Future<Session> _createSession({Session? session, required String peerId, required String sessionId}) async {
    var newSession = session ?? Session(sid: sessionId, pid: peerId);
    localStream = await createStream();
    RTCPeerConnection pc = await createPeerConnection(configuration, offerSdpConstraints);
    pc.addStream(localStream!);
    pc.onAddStream = (stream) {
      onAddRemoteStream.call(newSession, stream);
    };
    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        send('candidate', {
          'from': _selfId,
          'to': peerId,
          'session_id': sessionId,
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
        });
      }
    };
    pc.onIceConnectionState = (state) {
      print(state.toString());
    };
    newSession.pc = pc;
    return newSession;
  }
  Future<void> _createOffer(Session session) async {
    try {
      RTCSessionDescription description = await session.pc!.createOffer({'offerToReceiveVideo': 1});
      await session.pc!.setLocalDescription(description);
      var sdp = parse(description.sdp as String);
      send('offer', {
        'from': _selfId,
        'to': session.pid,
        'session_id': session.sid,
        'description': json.encode(sdp)
      }); 
    } catch (e) {
      print(StackTrace.fromString(e.toString()));
    }
  }
  Future<void> _createAnswer(Session session) async {
    try {
      RTCSessionDescription description = await session.pc!.createAnswer({'offerToReceiveVideo': 1});
      await session.pc!.setLocalDescription(description);
      var sdp = parse(description.sdp as String);
      send('answer', {
        'from': _selfId,
        'to': session.pid,
        'session_id': session.sid,
        'description': json.encode(sdp),
        'device_id': deviceId
      });
    // ignore: empty_catches
    } catch (e) {
    }
  }
  Future<MediaStream> createStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    onLocalStream.call(null, stream);
    return stream;
  }
  mergeSession(Session session1, Session session2) {
    var newSession = session1;
    newSession.remoteCandidates = List.from(session2.remoteCandidates);
    return newSession;
  }
  send(event, data) {
    print("send: $data");
    channel.push(event: event, payload: data);
  }

  calling (context, peer) async {
    _selfId = Provider.of<User>(context, listen: false).me["user_id"];
    var sessionId = _selfId + '_' + peer["user_id"];
    var _session = Session(pid: peer["user_id"], sid: sessionId);

    Future<void> onDoneView() async {
      Session session = await _createSession(sessionId: sessionId, peerId: peer["user_id"]);
      _sessions[sessionId] = session;
      // print(_sessions);
      _createOffer(session);
      onCallStateChange.call(session, CallState.callStateNew);
    }
    Navigator.push(context,
      PageRouteBuilder(pageBuilder: (context, ani1, ani2){
        return CallView(type: "offer", user: peer,session: _session,onDoneView: onDoneView);
      })
    );
  }
  byeCall (String sessionId) {
    Session session = _sessions[sessionId]!;
    send('call_end', {
      'from': _selfId,
      'to': session.pid,
      'session_id': session.sid,
      'device_id': deviceId
    });
    closeSession(_sessions[sessionId]!);
  }

  Future<void> setEnableMic(value) async {
    if (localStream != null) {
      localStream!.getAudioTracks()[0].enabled = value;
      localStream!.getAudioTracks()[0].setMicrophoneMute(!value);
    }
  }

  Future<void> setEnableVideo(value) async {
    if (localStream != null) {
      localStream!.getVideoTracks()[0].enabled = value;
    }
  } 

  closeSession(Session session) async {
    if (localStream != null) await localStream!.dispose();
    if (session.pc != null) await session.pc!.close();
    session.remoteCandidates.clear();
    session.pc = null;
  }
}
class Calls extends ChangeNotifier {
  void onMessage(message, context) {
    // print("receive $message");
    CallManager.instance.onMessage(message, context);
  }
}