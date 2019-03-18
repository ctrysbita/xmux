import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lottie/flutter_lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:xmux/globals.dart';

class VPNPage extends StatefulWidget {
  @override
  _VPNPageState createState() => _VPNPageState();
}

class _VPNPageState extends State<VPNPage> {
  var currentState = FlutterVpnState.disconnected;
  StreamSubscription _stateSubscription;
  LottieController _lottieController;

  Color get color {
    switch (currentState) {
      case FlutterVpnState.disconnected:
        return Colors.black54;
      case FlutterVpnState.connecting:
        return Colors.orangeAccent;
      case FlutterVpnState.connected:
        return Colors.greenAccent;
      case FlutterVpnState.disconnecting:
        return Colors.orangeAccent;
      default:
        return Colors.red;
    }
  }

  @override
  void initState() {
    FlutterVpn.currentState.then((s) => setState(() => currentState = s));
    FlutterVpn.prepare();
    _stateSubscription = FlutterVpn.onStateChanged
        .listen((s) => setState(() => currentState = s));
    super.initState();
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VPN'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: <Widget>[
          // Animation & Icon.
          Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Container(
                height: 150.0,
                child: LottieView.fromFile(
                  filePath: "res/animations/vpn.json",
                  autoPlay: false,
                  reverse: false,
                  onViewCreated: (c) {
                    _lottieController = c;
                    if (currentState == FlutterVpnState.connected)
                      c.playWithProgress(fromProgress: 0.0, toProgress: 0.8);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Hero(
                  tag: 'res/academic/vpn.svg',
                  child: SvgPicture.asset(
                    'res/academic/vpn.svg',
                    height: 66.0,
                    width: 66.0,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          Text(i18n('Campus/AcademicTools/VPN/Warning', context),
              textAlign: TextAlign.center),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: currentState == FlutterVpnState.connected
                        ? null
                        : () {
                            _lottieController.playWithProgress(
                                fromProgress: 0.0, toProgress: 0.8);
                            FlutterVpn.simpleConnect(
                                'ikev2.xmu.edu.my',
                                firebaseUser.uid,
                                store.state.authState.campusIDPassword);
                          },
                    child:
                        Text(i18n('Campus/AcademicTools/VPN/Connect', context)),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      _lottieController.playWithProgress(
                          fromProgress: 0.8, toProgress: 1.2);
                      FlutterVpn.disconnect();
                    },
                    child: Text(
                        i18n('Campus/AcademicTools/VPN/Disconnect', context)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
