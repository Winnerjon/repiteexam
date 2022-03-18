import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:repiteexam/models/user_models.dart';
import 'package:repiteexam/pages/add_recipients.dart';
import 'package:repiteexam/services/db_service.dart';
import 'package:repiteexam/services/http_service.dart';

class HomePage extends StatefulWidget {
  static const String id = "/home_page";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> users = [];
  ConnectivityResult _connectionStatus = ConnectivityResult.values[0];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // #load_users
  void _apiUsersList() async {
    if (_connectionStatus == ConnectivityResult.wifi || _connectionStatus == ConnectivityResult.mobile) {
      await HttpService.GET(HttpService.API_LIST, HttpService.paramsEmpty()).then((response) {
        setState(() {
          users = HttpService.parseResponse(response!);
          HiveDB.storeSavedCards(users);
        });
      });
    } else if (_connectionStatus == ConnectivityResult.none) {
      setState(() {
        users = HiveDB.loadSavedCards();
      });
    }
  }

  delete(String id,int index)async{
    users.remove(users[index]);
    HiveDB.storeSavedCards(users);
    await HttpService.DEL(HttpService.API_DELETE + users[index].id!, HttpService.paramsEmpty());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity().then((value) => _apiUsersList());
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
    if ((_connectionStatus == ConnectivityResult.wifi ||
        _connectionStatus == ConnectivityResult.mobile) &&
        HiveDB.loadNoInternetCards().isNotEmpty) {
      for (int i = 0; i < HiveDB.loadNoInternetCards().length; i++) {
        await HttpService.POST(HttpService.API_CREATE,
            HttpService.bodyCreate(HiveDB.loadNoInternetCards()[i]));
      }
      HiveDB.storeNoInternetCards([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  hintText: "Search",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return itemUserList(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddRecients.id);
        },
        child: Icon(
          Icons.add,
          size: 35,
        ),
      ),
    );
  }

  Widget itemUserList(int index) {
    return Dismissible(
      key: const ValueKey(0),
      onDismissed: (_) async {
        users.remove(users[index]);
        HiveDB.storeSavedCards(users);
        await HttpService.DEL(HttpService.API_DELETE + users[index].id!, HttpService.paramsEmpty());
      },
      child: Card(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage("assets/images/profile.png"),
          ),
          title: Text(
            users[index].name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            users[index].phoneNumber,
            style: TextStyle(
                color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          trailing: MaterialButton(
            height: 35,
            minWidth: 60,
            color: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7)
            ),
            child: Text(
              "Send",
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onPressed: (){},
          ),
        ),
      ),
    );
  }
}
