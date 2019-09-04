import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry/sentry.dart' as sentry_lib;
import 'package:xmux/config.dart';
import 'package:xmux/globals.dart';
import 'package:xmux/init/login_handler.dart';
import 'package:xmux/mainapp/main_app.dart';
import 'package:xmux/modules/firebase/firebase.dart';
import 'package:xmux/modules/xia/xia.dart';
import 'package:xmux/modules/xmux_api/xmux_api_v2.dart' as v2;
import 'package:xmux/modules/xmux_api/xmux_api_v3.dart';
import 'package:xmux/redux/redux.dart';

/// Main initialization progress.
Future<bool> init() async {
  // Register sentry to capture errors. (Release mode only)
  if (bool.fromEnvironment('dart.vm.product'))
    FlutterError.onError = (e) =>
        sentry.captureException(exception: e.exception, stackTrace: e.stack);

  if (Platform.isAndroid || Platform.isIOS) await mobileInit();

  // Create APIv3 Client.
  XMUXApi(BackendApiConfig.address);

  // Init XiA async.
  XiA.init(ApiKeyConfig.dialogflowToken)
      .then((x) => xiA = x)
      .catchError((_) {});

  // Select XMUX API server. (Deprecated)
  v2.XMUXApi([BackendApiConfig.address]);
  await v2.XMUXApi.selectingServer;
  // Register SystemChannel to handle lifecycle message. (Deprecated)
  SystemChannels.lifecycle.setMessageHandler((msg) async {
    print('SystemChannels/LifecycleMessage: $msg');
    // Update language for XMUX API.
    if (msg == AppLifecycleState.resumed.toString())
      v2.XMUXApi.instance.configure();
    return msg;
  });

  // Check if local state is available.
  try {
    var appDocDir = (await getApplicationDocumentsDirectory()).path;
    var initMap =
        jsonDecode(await (File('$appDocDir/state.dat')).readAsString());

    // Init store from initMap
    store.dispatch(InitAction(initMap));
  } catch (e) {
    FirebaseAuth.instance.signOut();
    return false;
  }

  // If not login yet.
  if (store.state.authState.campusID == null ||
      store.state.authState.campusIDPassword == null) return false;

  postInit();
  return true;
}

/// Post initialization after authentication.
void postInit() async {
  // Set user info for sentry report.
  sentry.userContext = sentry_lib.User(id: store.state.authState.campusID);

  // Register APIv2 user. (Deprecated)
  try {
    await v2.XMUXApi.instance.getUser(firebaseUser.uid);
    await v2.XMUXApi.instance.updateUser(v2.User(
        firebaseUser.uid, firebaseUser.displayName, firebaseUser.photoUrl));
  } catch (e) {
    await LoginHandler.campus(
        store.state.authState.campusID, store.state.authState.campusIDPassword);
    await LoginHandler.createUser();
  }

  if (Platform.isAndroid) await androidInit();
  if (Platform.isIOS) await iOSInit();

  store.dispatch(UpdateAssignmentsAction());
  store.dispatch(UpdateInfoAction());
  store.dispatch(UpdateHomepageAnnouncementsAction());
  store.dispatch(UpdateAcAction());
  store.dispatch(UpdateCoursesAction());

  runApp(MainApp());
}

Future<Null> mobileInit() async {
  // Get package Info.
  packageInfo = await PackageInfo.fromPlatform();

  // Register sentry again with release info. (Release mode only)
  if (bool.fromEnvironment('dart.vm.product'))
    FlutterError.onError = (e) => sentry.capture(
          event: sentry_lib.Event(
              exception: e.exception,
              stackTrace: e.stack,
              release: packageInfo.version),
        );

  // Init firebase services.
  firebase = await Firebase.init();

  // Register FirebaseAuth state listener.
  FirebaseAuth.instance.onAuthStateChanged.listen((user) {
    if (user == null && firebaseUser != null) logout();
    if (user != null) {
      firebaseUser = user;

      // Configure JWT generator for current user.
      XMUXApi.instance.getIdToken =
          () async => (await firebaseUser.getIdToken()).token;
      // APIv2 JWT configure. (Deprecated)
      v2.XMUXApi.instance.getIdToken = XMUXApi.instance.getIdToken;
    }
  });

  // Configure FCM.
  firebase.messaging.configure();
}

Future<Null> androidInit() async {
  try {
    var deviceInfo = await DeviceInfoPlugin().androidInfo;

    // Replace android transition theme if >= 9.0
    if (int.parse(deviceInfo.version.release.split('.').first) >= 9)
      ThemeConfig.defaultTheme = ThemeConfig.defaultTheme.copyWith(
          pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
      }));

    XMUXApi.instance.refreshDevice(
      deviceInfo.androidId,
      deviceInfo.model,
      deviceInfo.host,
      pushChannel: 'fcm',
      pushKey: await firebase.messaging.getToken(),
    );
  } catch (e) {
    rethrow;
  } finally {}
}

Future<Null> iOSInit() async {
  try {
    var deviceInfo = await DeviceInfoPlugin().iosInfo;

    XMUXApi.instance.refreshDevice(
      deviceInfo.identifierForVendor,
      deviceInfo.model,
      deviceInfo.name,
      pushChannel: 'fcm',
      pushKey: await firebase.messaging.getToken(),
    );
  } catch (e) {
    rethrow;
  } finally {}
}
