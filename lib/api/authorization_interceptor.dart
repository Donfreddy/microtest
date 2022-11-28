import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/models/request_data.dart';
import 'package:http_interceptor/models/response_data.dart';
import 'package:http_interceptor/models/retry_policy.dart';

import '../common/constant.dart';
import 'api_service.dart';

class AuthorizationInterceptor implements InterceptorContract {
  // We need to intercept request
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    try {
      // Fetching token from local storage
      var token = Hive.box(userBoxName).get('token', defaultValue: null);

      // Clear previous header and update it with updated token
      data.headers.clear();

      data.headers['authorization'] = 'Bearer ${token!}';
      data.headers['content-type'] = 'application/json';
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return data;
  }

  // Currently we do not have any need to intercept response
  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    return data;
  }
}

//This is where request retry
class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async {
    if (response.statusCode == 401) {
      await ApiService.refreshToken();
      return true;
    }
    return false;
  }
}
