import 'package:dio/dio.dart';

import 'ui-Toolkit.dart';

bool flareDetect(context, Response response) {
  int status = response.statusCode;
  if (status == 500) {
    log(response.data);
    return true;
  } else if (status == 502 || status == 504) {
    log(response.data);
    return true;
  } else if (status == 503) {
    log(response.data);
    return true;
  } else if (status == 520) {
    log(response.data);
    return true;
  } else if (status == 521) {
    log(response.data);
    return true;
  } else if (status == 522) {
    log(response.data);
    return true;
  } else if (status == 523) {
    log(response.data);
    return true;
  } else if (status == 524) {
    log(response.data);
    return true;
  } else if (status == 525) {
    log(response.data);
    return true;
  } else if (status == 526) {
    log(response.data);
    return true;
  } else if (status == 527) {
    log(response.data);
    return true;
  } else if (status == 530) {
    log(response.data);
    return true;
  } else {
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text('No Cloudflare intervention')));
    //log('Network Reason: ' + response.reasonPhrase.toString());
    return false;
  }
}
