import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:microtest/common/constant.dart';

import 'authorization_interceptor.dart';

class ApiBaseHelper {
  //Setting up your client with interceptors
  static final client = InterceptedClient.build(
    interceptors: [AuthorizationInterceptor()],
  );

  static Future<dynamic> httpGetRequest(String endPoint) async {
    http.Response response;

    try {
      //Request with interceptor client
      response = await client.get(Uri.parse('$baseUrl$endPoint'));

      return _returnResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('catch on http Get request');
        print(e.toString());
      }
    }
  }

  static Future<dynamic> httpPostRequest(String endPoint, Map<String, dynamic> data) async {
    http.Response response;

    try {
      //Request with interceptor client
      response = await client.post(
        Uri.parse('$baseUrl$endPoint'),
        body: jsonEncode(data),
      );
      return _returnResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('catch on http Post request');
        print(e.toString());
      }
    }
  }

  static dynamic _returnResponse(http.Response response) {
    String responseJson = response.body;
    final jsonResponse = jsonDecode(responseJson);
    switch (response.statusCode) {
      case 200:
        return jsonResponse;
      case 400:
      // throw BadRequestException(
      //     jsonResponse['message'] ?? AppConstants.exceptionMessage);
      case 401:
      // throw InvalidInputException(
      //     jsonResponse['message'] ?? AppConstants.exceptionMessage);
      case 403:
      // throw UnauthorisedException(
      //     jsonResponse['message'] ?? AppConstants.exceptionMessage);
      case 404:
      // throw FetchDataException(
      //     jsonResponse['message'] ?? AppConstants.exceptionMessage);
      case 500:
      default:
      // throw FetchDataException(
      //     jsonResponse['message'] ?? AppConstants.exceptionMessage);
    }
  }
}
