import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'remote_config.dart';

class Firebase {
  /// Firebase analytics instance.
  final analytics = FirebaseAnalytics();

  /// Firebase messaging instance.
  final messaging = FirebaseMessaging();

  /// Firebase remote config instance.
  final RemoteConfig remoteConfig;

  /// Store remote configs.
  final RemoteConfigs remoteConfigs = RemoteConfigs();

  Firebase._(this.remoteConfig);

  static Future<Firebase> init() async {
    // Init remote config.
    var remoteConfigInstance = await RemoteConfig.instance;
    return Firebase._(remoteConfigInstance)..updateRemoteConfig();
  }

  /// Update and parse remote configs.
  Future<Null> updateRemoteConfig() async {
    try {
      await remoteConfig.fetch();
      await remoteConfig.activateFetched();
    } catch (_) {
      // Use old if fetch failed.
      var staticRes = remoteConfig.getString('static_resources');
      remoteConfigs.staticResources =
          StaticResources.fromJson(jsonDecode(staticRes));
      rethrow;
    }
    var staticRes = remoteConfig.getString('static_resources');
    remoteConfigs.staticResources =
        StaticResources.fromJson(jsonDecode(staticRes));
  }
}