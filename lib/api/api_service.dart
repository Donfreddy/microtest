import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:microtest/api/api_base_helper.dart';

import '../common/constant.dart';

class ApiService {
  static Future<dynamic> makePayment(Map<String, dynamic> data) async {
    return await ApiBaseHelper.httpPostRequest( '/collect/', data);
  }

  static Future<dynamic> getPaymentStatus(String reference) async {
    return await ApiBaseHelper.httpGetRequest('/transaction/$reference/');
  }

  static Future<dynamic> withdraw(Map<String, dynamic> data) async {
    return await ApiBaseHelper.httpPostRequest( '/withdraw/', data);
  }

  static Future<void> refreshToken() async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"username": appUsername, "password": appPassword}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        await Hive.box(userBoxName).put('token', jsonResponse['token']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('catch on refresh token');
        print(e.toString());
      }
    }
  }
}
