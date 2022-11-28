import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
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
      response = await client.get(Uri.parse('$baseUrl$endPoint'),
          headers: _getHerders());

      return _returnResponse(response);
    } on SocketException {
      //No internet connection
    } catch (e) {
      if (kDebugMode) {
        print('catch on http Get request');
      }
    }
  }

  static Future<dynamic> httpPostRequest(
      String endPoint, Map<String, dynamic> data) async {
    http.Response response;

    try {
      //Request with interceptor client
      response = await client.post(
        Uri.parse('$baseUrl$endPoint'),
        headers: _getHerders(),
        body: jsonEncode(data),
      );

      return _returnResponse(response);
    } on SocketException {
      // no internet message
    } catch (e) {
      if (kDebugMode) {
        print('catch on http Post request');
        print(Hive.box(userBoxName).get('token', defaultValue: null));
      }
      print(e.toString());
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

  static Map<String, String> _getHerders() {
    var token =
        Hive.box(userBoxName).get('token', defaultValue: null) as String?;

    return {
      //'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
