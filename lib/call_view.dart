import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'cache_avatar.dart';
import 'models/call_modal.dart';

class CallView extends StatefulWidget {
  const CallView({Key? key, required this.user, required this.type, this.session, required this.onDoneView}) : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final user;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  // ignore: prefer_typing_uninitialized_variables
  final session;
  // ignore: prefer_typing_uninitialized_variables
  final onDoneView;
  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  dynamic callManager = CallManager.instance;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isCalling = false;
  // late Session _session;
  // ignore: prefer_typing_uninitialized_variables
  late final user;
  bool isMicEnable = true;
  bool isVideoEnable = true;
  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    user = widget.user;
    CallManager.instance.onCallStateChange = (session, state) {
      switch (state) {
        case CallState.callStateConnected:
          setState(() {
            _isCalling = true;
          });
          break;
        case CallState.callStateBye:
          setState(() {
            _isCalling = false;
          });
          Navigator.pop(context);
          break;
        default:
      }
    };
    CallManager.instance.onLocalStream = ((session, stream) {
      setState(() {
        _localRenderer.srcObject = stream;
      });
    });

    CallManager.instance.onAddRemoteStream = ((_, stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (widget.type == "offer") widget.onDoneView();
    });

  }

  @override
  void dispose() {
    // print("dispose");
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    if (widget.session != null) CallManager.instance.closeSession(widget.session);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCalling || widget.type == "offer" ? SizedBox(
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isVideoEnable = !isVideoEnable;
                  CallManager.instance.setEnableVideo(isVideoEnable);
                });
              } ,
              child: Container(child: Center(child: Icon( isVideoEnable ? Icons.videocam : Icons.videocam_off, size: 30, color: Colors.white)), width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.blue)),
            ),
            InkWell(
              // backgroundColor: Colors.red,
              onTap: (){
                setState(() {
                  CallManager.instance.byeCall(widget.session.sid);
                  _isCalling = false;
                  Navigator.pop(context);
                });
              },
              child: Container(child: const Center(child: Icon(Icons.call_end, size: 30, color: Colors.white,)),width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.red),)
            ),
            InkWell(
              // backgroundColor: Colors.green,
              onTap: (){
                setState(() {
                  isMicEnable = !isMicEnable;
                  CallManager.instance.setEnableMic(isMicEnable);
                });
              },
              child: Container(child: Center(child: Icon(isMicEnable ? Icons.mic_rounded : Icons.mic_off_rounded, size: 30, color: Colors.white,)),width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.green),)
            )
          ],
        ),
      ) : SizedBox(
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: (){
                CallManager.instance.byeCall(widget.session.sid);
                Navigator.pop(context);
              }, 
              child: const Icon(CupertinoIcons.phone_down_circle_fill, size: 50, color: Colors.red,)
            ),
            InkWell(
              onTap: (){
                setState(() {
                  widget.onDoneView();
                  _isCalling = true;
                });
              }, 
              child: const Icon(CupertinoIcons.videocam_circle_fill, size: 50, color: Colors.blue,)
            ),
          ],
        ),
      ),
      body: !_isCalling ? widget.type == "offer" ? outComingCall() : inComingCall() : callingView(),
    );
  }
  Widget outComingCall() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 100, bottom: 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CachedAvatar(
            user["avatar_url"], 
            name: user["full_name"], 
            width: 100, 
            height: 100
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(user["full_name"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.all(5),
            child: Text("Đang đổ chuông", style: TextStyle(fontSize: 20)),
          ),
          SizedBox(
            width: 250,
            height: 350,
            child: RTCVideoView(_localRenderer),
          ),
          
        ],
      ),
    );
  }
  Widget inComingCall() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 100, bottom: 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CachedAvatar(
            user["avatar_url"], 
            name: user["full_name"], 
            width: 100, 
            height: 100
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(user["full_name"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.all(5),
            child: Text("Đang đổ chuông", style: TextStyle(fontSize: 20)),
          ),
          Expanded(child: SizedBox(
            width: 250,
            height: 350,
            child: RTCVideoView(_localRenderer),
          )),
          
        ],
      ),
    );
  }
  Widget callingView() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: RTCVideoView(_remoteRenderer),
          ),
        ),
        Positioned(
          right: 20,
          top: 50,
          child: isVideoEnable ?  Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5)
            ),
            width: 200,
            height: 140,
            child: RTCVideoView(_localRenderer, mirror: true,objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,),
          ) : Container(),
        )
      ],
    );
  }
}