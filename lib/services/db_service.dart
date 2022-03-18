import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:repiteexam/models/user_models.dart';

class HiveDB {
  static String DB_NAME = "telegram";
  static var box = Hive.box(DB_NAME);

// #store_saved_cards

  static Future<void> storeSavedCards(List<User> cards) async {
    List<String> list =
    List<String>.from(cards.map((card) => jsonEncode(card.toJson())));
    await box.put("cards", list);
  }

  // #load_saved_cards

  static List<User> loadSavedCards() {
    List<String> response = box.get("cards", defaultValue: <String>[]);
    List<User> list =
    List<User>.from(response.map((x) => User.fromJson(jsonDecode(x))));
    return list;
  }

  // store_noInternet_cards

  static Future<void> storeNoInternetCards(List<User> users) async {
    List<String> list =
    List<String>.from(users.map((card) => jsonEncode(card.toJson())));
    await box.put("no connection", list);
  }

  // #load_noInternet_cards

  static List<User> loadNoInternetCards() {
    List<String> response = box.get("no connection", defaultValue: <String>[]);
    List<User> list =
    List<User>.from(response.map((x) => User.fromJson(jsonDecode(x))));
    return list;
  }
}