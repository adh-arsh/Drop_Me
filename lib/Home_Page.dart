import 'dart:async';
import 'dart:ui';
import 'package:drop_me/Profile_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'Active_Page.dart';
import 'Setting_Page.dart';

//TODO ADD DOUBLE BACK TAP TO EXIT FEATURE

String packageUserIdForActiveSession;
String acceptedByGlobal;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HomePage());
}

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  String currentUId;
  String uid;
  String currentEmail;

  @override
  void initState() {
    super.initState();

    user = auth.currentUser;
    // Future.delayed(Duration(seconds: 5));
    // sleep(Duration(seconds: 5));
    currentUId = user.uid;
    uid = currentUId;
    currentEmail = user.email;
    print(currentUId);
  }

  bool isAvailable = false;
  var availableTs;
 // bool requestedBtn = false;
  var switchText = 'Not Available';
  String acceptedBy;
  String route = '';
  bool requested = false;
  bool activeStatus=false;



  final databaseReference = FirebaseDatabase.instance.reference();
  final userDatabaseReference = FirebaseDatabase.instance.reference().child("users");

  @override
  Widget build(BuildContext context) {
    getData();

    databaseReference.child('requests').child(route).child(uid).child('active').once().then((
        DataSnapshot snapshot) {
      activeStatus = snapshot.value;
    });

    getAcceptedBy();


    return new WillPopScope(
      onWillPop: () async => false,

      child: Scaffold(
        appBar: NeumorphicAppBar(
          buttonStyle: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            lightSource: LightSource.topLeft,
            border: NeumorphicBorder(isEnabled: true,color: Colors.lightBlue,width: 1.5),
            depth: 6,
            color:  Colors.white24
        ),
          centerTitle: true,
          title: Text(userType=='Package' ? '$availableTs Online' : isAvailable ? '$switchText' : '$switchText',
            style: TextStyle(color: userType=='Package' ? Colors.green : isAvailable ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold),
          ),

          leading:
          GestureDetector(
            child:
            NeumorphicButton(
                curve: Neumorphic.DEFAULT_CURVE,
                onPressed: onProfilePressed,
                style: NeumorphicStyle(
                    lightSource: LightSource.topLeft,
                    shape: NeumorphicShape.convex,
                    depth: 2,
                    intensity: 1,
                    boxShape:
                    NeumorphicBoxShape.circle(),
                    border: NeumorphicBorder()
                ),
              child: Container(
                alignment: Alignment.center,
                child : NeumorphicIcon(
                    Icons.account_circle_rounded,
                    style: NeumorphicStyle(
                      intensity: 2,
                        shape: NeumorphicShape.concave,
                        lightSource: LightSource.topLeft,
                        border: NeumorphicBorder(isEnabled: true,color: Colors.white,width: 1.5),
                        depth: 9,
                        color:  Colors.blueGrey
                    ),
                    size: 50
                ),
              )
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child:
              NeumorphicButton(
                  curve: Neumorphic.DEFAULT_CURVE,
                  onPressed: _onSettingButtonPress,
                  style: NeumorphicStyle(
                      lightSource: LightSource.topLeft,
                      shape: NeumorphicShape.convex,
                      depth: 2,
                      intensity: 1,
                      boxShape:
                      NeumorphicBoxShape.circle(),
                      border: NeumorphicBorder()
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child : NeumorphicIcon(
                        Icons.settings,
                        style: NeumorphicStyle(
                            intensity: 2,
                            shape: NeumorphicShape.concave,
                            lightSource: LightSource.topLeft,
                            border: NeumorphicBorder(isEnabled: true,color: Colors.white,width: 1.5),
                            depth: 9,
                            color:  Colors.blueGrey
                        ),
                        size: 50
                    ),
                  )
              ),
            ),
          ],
        ),
        body: Column(
        children: <Widget>[
          NeumorphicText(userType == 'Package'?'Leader Board': isAvailable?'Requests' : 'Leader Board',
           textAlign: TextAlign.center,
           style: NeumorphicStyle(
             color: Colors.blue
           ),
           textStyle: NeumorphicTextStyle(fontSize: 30,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,decoration: TextDecoration.overline),
                ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width-10,
              child: Neumorphic(
                child : userType=='Package'?_buildTextViewFoPackage():_buildTextViewFoTransporter(),
                style: (
                NeumorphicStyle(
                  shape: NeumorphicShape.concave,
                  lightSource: LightSource.topLeft,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                  depth: -9
                )
                ),
              ),
              color: Colors.white24,
              padding: EdgeInsets.fromLTRB(15, 5, 15, 60),
            ),
          ),
          Container(
            // This align moves the children to the bottom
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  // This container holds all the children that will be aligned
                  // on the bottom and should not scroll with the above ListView
                  child: Container(
                      child: Column(
                        children: <Widget>[
                          _setRouteText(),
                          userType=='Package'?_setButtonForPackage():_setSwitchForTransporter(),
                        ],
                      )
                  )
              )
          )

        ],
      ),
    ),
    );
  }

  /// initialization of data
  void getData(){
    userDatabaseReference.child(uid).child('route').once().then((DataSnapshot snapshot) {
      route = snapshot.value;
      setState(() {
        route = route;
      });
    });
    userDatabaseReference.child(uid).child('userType').once().then((
        DataSnapshot snapshot) {
      userType = snapshot.value;
    });
    userDatabaseReference.orderByChild('availableToDrop').equalTo(true).once().then((
        DataSnapshot snapshot) {
      Map map = snapshot.value;

      if(map.length == null || map.length == 0)
        availableTs = 0;
      else
      availableTs = map.length;
    });
  }

  void getAcceptedBy(){
    databaseReference.child("requests").child(route).child(uid).child('acceptedBy').once().then((DataSnapshot snapshot) {
      setState(() {
        acceptedBy = snapshot.value;
        acceptedByGlobal = acceptedBy;
      });
    });
  }

  /// listview----for transporter----------------------------
  Widget _buildTextViewFoTransporter(){
    final databaseReference = userDatabaseReference.orderByChild('requested').equalTo(true);

    if(isAvailable)
    return StreamBuilder(
      stream: databaseReference.onValue,
      builder: (context, snap) {
        if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;
          List item = [];
          data.forEach((index, data) => item.add({"key": index, ...data}));
          print(isAvailable);
          return ListView.builder(
            padding: EdgeInsets.all(5.0),
            itemCount: item.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 10,
                  child : ListTile(
                    title: Text(item[index]['name'],
                      style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    subtitle: Text(item[index]['route'],
                        style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
                    trailing: _acceptRequest(item[index]['route'] , item[index]['userId']),
                minVerticalPadding: 5,
              )
              );
            },
          );
        }
        else
          return Container(
            alignment: Alignment.center,
              child : Text('No Requests so far',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center),
          );
      },
    );
    else
      return _buildTextViewFoPackage();
  }

  /// listview----for package----------------------------
  Widget _buildTextViewFoPackage(){
   final databaseReference = FirebaseDatabase.instance.reference().child("users").orderByChild('dropCount').limitToLast(3);
   //TODO-----LEADER BOARD LIST------make it efficient
    return StreamBuilder(
      stream: databaseReference.onValue,
      builder: (context, snap) {
        if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;
          List item = [];
          data.forEach((index, data) => item.add({"key": index, ...data}));
          return ListView.builder(
            padding: EdgeInsets.all(5.0),
            itemCount: item.length,
            itemBuilder: (context, index) {
              return Card(
                  elevation: 10,
                  child : ListTile(
                    title: Text(item[index]['name'],
                      style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text('${item[index]['dropCount'].toString()} drops',
                        style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    onTap: (){
                    },
                    minVerticalPadding: 5,
                  )
              );
            },
          );
        }
        else
          return Container(
            alignment: Alignment.center,
            child : Text('Nobody is in top spot now, your name can be here',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center),
          );
      },
    );
  }

  void _goToActiveRide(){

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActivePage()),
    );
    print('ride active');
  }

  /// profile button
  void onProfilePressed(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
    print('Profile button pressed');
  }

  /// setting button
  void _onSettingButtonPress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingPage()),
    );
    print('Settings button pressed');
  }

  /// set route text
  Widget _setRouteText(){
    return Text(route==null ? '' : '$route',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold));
  }

  /// set button for package user type
  Widget _setButtonForPackage(){
    return
      NeumorphicButton(
          curve: Neumorphic.DEFAULT_CURVE,
          onPressed: _onRequestButtonPress,
          margin: EdgeInsets.all(30),
          style: NeumorphicStyle(
              lightSource: LightSource.topLeft,
              shape: NeumorphicShape.convex,
              depth: 20,
              intensity: 1,
              boxShape:
              NeumorphicBoxShape.circle(),
              border: NeumorphicBorder()
          ),
          padding: const EdgeInsets.all(30),
          child: NeumorphicText(
            "Call",
            style: NeumorphicStyle(
                shape: NeumorphicShape.convex,
                depth: 1,
                color: Colors.blueGrey
            ),
            curve: Neumorphic.DEFAULT_CURVE,
            textStyle: NeumorphicTextStyle(fontSize: 32, fontWeight: FontWeight.bold ),
          )
        // style: TextStyle(fontSize: 32,color: Colors.blue),
      );
  }

  /// request button
  void _onRequestButtonPress() {
    if(route==null || route == '')
      _promptToUpdateDetails();
    else {
      databaseReference.child("requests").child(route).child(uid).child("active").set(true);

      userDatabaseReference.child(uid).child("requested").set(true);

      _promptWhileSearching();
      print('request pressed');
    }
    print('Request button pressed');
  }



  /// prompt while searching for transporter
  Future<void> _promptWhileSearching() async {
    startTimeout(10);

    while (acceptedBy == null) {



      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {

          Future.delayed(const Duration(milliseconds: 5000), () {

            _cancelRequest(context);

          });

          return AlertDialog(
            elevation: 10,
            title: Text('Waiting for Response'),
            content: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                height: 110,
                width: 100,
                child:Transform.scale(scale: 3.1,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )

            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  _cancelRequest(context);
                },
              ),
            ],
          );
        },
      );
    }
    if (acceptedBy != null && activeStatus == false) {
      _goToActiveRide();
    }
  }

  //TODO show count down
  startTimeout([int milliseconds]) {
    const timeout = const Duration(seconds: 5);
    const ms = const Duration(milliseconds: 1000);
    var duration = milliseconds == null ? timeout : ms * milliseconds;

    return new Timer(duration, handleTimeout);
  }


  void handleTimeout() {
    print(acceptedBy);
    if (acceptedBy != null && activeStatus == false) {
      _goToActiveRide();
    }else _cancelRequest(context);
  }

  /// cancel the request
  void _cancelRequest(BuildContext context) {
    Navigator.of(context).pop();
    databaseReference.child("requests").child(route).child(uid).remove();
    userDatabaseReference.child(uid).child("requested").set(false);

    print('cancel function');
  }

  /// to inform user to update their profile
  Future<void> _promptToUpdateDetails() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          title: Text('Incomplete Profile'),
          content: Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.bottomCenter,
            height: 70,
            width: 100,

            child: Text('Please Update you Profile to proceed'),


          ),
          actions: <Widget>[
            TextButton(
              child: Text('UPDATE'),
              onPressed: () {
                Navigator.of(context).pop();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),

                );
                setState(() {
                  isFormEditable = true;
                });
              },
            ),
          ],
        );
      },
    );

  }

  /// set switch for transporter user type
  Widget _setSwitchForTransporter(){
    return
      Container(
        padding: EdgeInsets.fromLTRB(1, 20, 1, 60),
        child : NeumorphicSwitch(
          style: NeumorphicSwitchStyle(
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.red,
          ),
          onChanged: toggleSwitch,
          value: isAvailable,
          height: 70,
        ),
      );
  }

  /// Switch
  void toggleSwitch(bool value) {

    if(isAvailable == false)
    {

      setState(() {
        isAvailable = true;
        _updateAvailableDatabase(isAvailable);
        switchText = 'Available';
      });
    }
    else
    {
      setState(() {
        isAvailable = false;
        _updateAvailableDatabase(isAvailable);
        switchText = 'Unavailable';
      });
    }
  }

  /// update DB on switch update
  void _updateAvailableDatabase(bool status){
    if(status)
      userDatabaseReference.child(uid).child('availableToDrop').set(status);
    else
      userDatabaseReference.child(uid).child('availableToDrop').remove();
  }

  Widget _acceptRequest(String packageRoute,String packageUserId){
   // final databaseReference = FirebaseDatabase.instance.reference();
    return IconButton(iconSize: 40,
      icon: Icon(Icons.check_circle_outline),color: Colors.green,
      onPressed: () {

        packageUserIdForActiveSession = packageUserId;


        userDatabaseReference.child(packageUserId).child("requested").set(false);



        databaseReference..child("requests").child(packageRoute).child(packageUserId).child('acceptedBy').set(uid);
      databaseReference..child("requests").child(packageRoute).child(packageUserId).child('active').set(false);
      databaseReference.child('activeRides').child(packageUserId).set(uid);
      userDatabaseReference.child(uid).child('availableToDrop').set(false);
      print(' accept pressed ::::::: packageRoute is = $packageRoute::::::::::: packageUserId is $packageUserId ');

        print(packageUserIdForActiveSession);

        _goToActiveRideForTransporter();

      },
    );
  }

  _goToActiveRideForTransporter(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActivePage()),
    );
  }
}