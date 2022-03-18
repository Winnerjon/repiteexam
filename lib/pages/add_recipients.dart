import 'dart:async';

import 'package:badges/badges.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:repiteexam/models/user_models.dart';
import 'package:repiteexam/pages/home_page.dart';
import 'package:repiteexam/services/db_service.dart';
import 'package:repiteexam/services/http_service.dart';

class AddRecients extends StatefulWidget {
  static const String id = "/add_recients";

  const AddRecients({Key? key}) : super(key: key);

  @override
  _AddRecientsState createState() => _AddRecientsState();
}

class _AddRecientsState extends State<AddRecients> {
  TextEditingController nameController = TextEditingController();
  TextEditingController relationshipController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  ConnectivityResult _connectionStatus = ConnectivityResult.bluetooth;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void addUser() async {
    String name = nameController.text.trim().toString();
    String relationship = relationshipController.text.trim().toString();
    String phoneNumber = phoneNumberController.text.trim().toString();

    if (name.isEmpty || relationship.isEmpty || phoneNumber.isEmpty) return;

    User user = User(name: name, relationship: relationship, phoneNumber: phoneNumber);
    List<User> users = HiveDB.loadSavedCards();
    users.add(user);

    if (_connectionStatus == ConnectivityResult.wifi ||
        _connectionStatus == ConnectivityResult.mobile) {
      await HttpService.POST(HttpService.API_CREATE, HttpService.bodyCreate(user));
    }else if (_connectionStatus == ConnectivityResult.none) {
      List<User> noInternet = HiveDB.loadNoInternetCards();
      noInternet.add(user);
      HiveDB.storeNoInternetCards(noInternet);
    }

    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: (){
            Navigator.pushReplacementNamed(context, HomePage.id);
          },
          icon: Icon(Icons.arrow_back_ios,color: Colors.black,size: 30,),
        ),
        title: Text("Add Recipints",style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.w500),),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    /// #profile image
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: CircleAvatar(
                        radius: 60,
                        child: Badge(
                          position: BadgePosition.bottomEnd(),
                          badgeColor: Colors.grey,
                          badgeContent: Icon(Icons.photo_camera),
                          child: CircleAvatar(
                            radius: 50,
                          ),
                        ),
                      ),
                    ),

                    /// #name
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text("Name"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    /// #relationship
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: relationshipController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text("Relationship"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    /// #phone number
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text("Phone Number"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MaterialButton(
                height: 60,
                minWidth: 300,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                child: Text(
                  "Save",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: addUser,
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
