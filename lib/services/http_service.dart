import 'dart:convert';

import 'package:http/http.dart';
import 'package:repiteexam/models/user_models.dart';

class HttpService {
  static bool isTester = true;

  static String SERVER_DEVELOPMENT = "623460a5debd056201e390c0.mockapi.io";
  static String SERVER_PRODUCTION  = "623460a5debd056201e390c0.mockapi.io";

  static Map<String,String> getHeaders() {
    Map<String,String> headers = {
      "Content-Type" : "application/json",
    };
    return headers;
  }

  static getServer() {
    if(isTester) return SERVER_DEVELOPMENT;
    return SERVER_PRODUCTION;
  }

  /* Http Request */

  static Future<String?> GET(String api, Map<String,dynamic> params) async {
    var uri = Uri.http(getServer(), api, params);
    var response = await get(uri,headers: getHeaders());
    if(response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  static Future<String?> POST(String api, Map<String,dynamic> params) async {
    var uri = Uri.http(getServer(), api);
    var response = await post(uri,headers: getHeaders(),body: jsonEncode(params));
    if(response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  static Future<String?> PATCH(String api, Map<String,dynamic> params) async {
    var uri = Uri.http(getServer(), api);
    var response = await patch(uri,headers: getHeaders(),body: jsonEncode(params));
    if(response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  static Future<String?> DEL(String api, Map<String,dynamic> params) async {
    var uri = Uri.http(getServer(), api, params);
    var response = await delete(uri,headers: getHeaders());
    if(response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  /* Http Api */

  static String API_LIST = "/users";
  static String API_ONE_ELEMENTS = "/users/"; // {ID}
  static String API_CREATE = "/users";
  static String API_UPDATE = "/users/"; // {ID}
  static String API_DELETE = "/users/"; // {ID}

  /* Http params */

  static Map<String,dynamic> paramsEmpty() {
    Map<String,dynamic> params = {};
    return params;
  }

  /* Http bodies */

  static Map<String,dynamic> bodyCreate(User user) {
    Map<String,dynamic> params = {};
    params.addAll({
      "name" : user.name,
      "relationship" : user.relationship,
      "phoneNumber" : user.phoneNumber,
    });
    return params;
  }

  static Map<String,dynamic> bodyUpdate(User user) {
    Map<String,dynamic> params = {};
    params.addAll({
      "id" : user.id,
      "name" : user.name,
      "relationship" : user.relationship,
      "phoneNumber" : user.phoneNumber,
    });
    return params;
  }

  static Map<String, String> deleteParam(String id) {
    Map<String, String> params = {};
    params.addAll({
      "id":id
    });
    return params;
  }

  static List<User> parseResponse(String response) {
    List json = jsonDecode(response);
    List<User> cards = List<User>.from(json.map((e) => User.fromJson(e)));
    return cards;
  }
}