import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e305/ui-Toolkit.dart';
import 'package:package_info/package_info.dart';

String userAgentHead;
int maxRequestsPerSec = 2;
int delay = 0;
int netRebuild = 10;
int count = 0;
bool setupNetLimitSwitch = false;
var cache = Map<Uri, Map<String, dynamic>>();
DateTime lastRequest = DateTime.now();
Dio network = Dio();
Duration calculatedDurationOffset =
    Duration(milliseconds: (1000 ~/ maxRequestsPerSec));

Dio networkingPriority(
    {int priority = 1,
    bool refresh = false,
    CancelToken token,
    bool overrideSpamGaurd = false}) {
  if (userAgentHead == null) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String buildN = packageInfo.buildNumber;
      String version = packageInfo.version;
      String plat = Platform.operatingSystem;
      print(Platform.operatingSystemVersion);
      if (Platform.isAndroid) {
        plat = 'Android';
      } else if (Platform.isIOS) {
        plat = 'iOS';
      } else if (Platform.isFuchsia) {
        plat = 'Fuchsia';
      } else if (Platform.isWindows) {
        plat = 'Windows';
      } else if (Platform.isLinux) {
        plat = 'Linux';
      } else if (Platform.isMacOS) {
        plat = 'MacOS';
      }
      userAgentHead = packageInfo.appName +
          '-' +
          plat +
          '/' +
          version +
          ' [' +
          buildN +
          '] (Dev: [Insert Username Here])';
      log(userAgentHead);
    });
  }
  network.options = BaseOptions(
    extra: {"refresh": refresh, "token": token, "override": overrideSpamGaurd},
    headers: {HttpHeaders.userAgentHeader: userAgentHead},
  );
  return network;
}

setupNetLimiter() {
  //startCache();
  if (!setupNetLimitSwitch) {
    log('SET NET LIMIT RAN!');
    network.interceptors.add(CacheInterceptor());
    network.interceptors
        .add(InterceptorsWrapper(onRequest: (Options options) async {
      network.interceptors.requestLock.lock();
      delay += 1;
      Duration diff = lastRequest.difference(DateTime.now());
      //await Future.delayed(Duration(milliseconds: 1000));
      if (diff.abs() < calculatedDurationOffset) {
        await Future.delayed((calculatedDurationOffset - diff).abs());
      }
      network.interceptors.requestLock.unlock();
      lastRequest = DateTime.now();
      return options; //continue
    }, onError: (error) {
      log('onError Delay: ${error.message}');
    }));
    network.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options) async {},
        onResponse: (Response options) async {},
        onError: (DioError error) {
          log('onError Metric: ${error.message}');
        }));
    setupNetLimitSwitch = true;
  } else {
    log('SET NET LIMIT tried to RUN!');
  }
}

class CacheInterceptor extends Interceptor {
  CacheInterceptor();

  //var _cache = Map<Uri, Map<String, dynamic>>();

  @override
  Future onRequest(RequestOptions options) async {
    Map<String, dynamic> cacheMinor = cache[options.uri];
    network.interceptors.requestLock.lock();
    log('Recieved request: ${options.uri}');
    if (cacheMinor != null) {
      log("cache hit: ${options.uri} \n");
      if (options.extra["refresh"] == true) {
        if (!options.extra["override"] &&
            DateTime.now().difference(cacheMinor['time']).abs() <=
                Duration(seconds: 30)) {
          log("${options.uri}: force refresh, repeat! \n");
          network.interceptors.requestLock.unlock();
          return cacheMinor['response'];
        }
        log("${options.uri}: force refresh, ignore cache! \n");
        network.interceptors.requestLock.unlock();
        return options;
      } else if (DateTime.now().difference(cacheMinor['time']).abs() <=
          Duration(minutes: 10)) {
        network.interceptors.requestLock.unlock();
        return cacheMinor['response'];
      } else {
        network.interceptors.requestLock.unlock();
        log("Stale cache: ${options.uri} REFRESHING!\n");
      }
    }
    network.interceptors.requestLock.unlock();
    log('Getting request: ${options.uri} \n');
    return options;
  }

  @override
  Future onResponse(Response response) async {
    cache[response.request.uri] = {
      'time': DateTime.now(),
      'response': response
    };
  }

  @override
  Future onError(DioError e) async {
    log('onError Cache: $e');
  }
}
