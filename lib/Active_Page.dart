import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Home_Page.dart';
import 'Profile_Page.dart';


 //String chatRoomId;

 String rideId;

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(ActivePage());

}

class ActivePage extends StatelessWidget {



  getRideId(){
    String now = DateTime.now().toString();
    String time = now.replaceAll('-', 'D');
    time = time.replaceAll(':', 'U');
    time = time.replaceAll(' ' , 'S');
    time = time.replaceAll('.' , 'd');

    if(userType == 'Package')
      rideId = '$time$uid$acceptedByGlobal';
    else
      rideId = '$time$packageUserIdForActiveSession$uid';
  }



  @override
  Widget build(BuildContext context) {

    getRideId();

    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: _ActivePage(),
    );
  }

}

class _ActivePage extends StatefulWidget{

  @override
  _ActivePageState createState() => new _ActivePageState();
}


class _ActivePageState extends State<_ActivePage>{

  static const platform = const MethodChannel("razorpay_flutter");
  //Razorpay _razorpay;

  int amount = 0;

  TextEditingController messageTextFieldController = TextEditingController();

  final String uid = FirebaseAuth.instance.currentUser.uid;
  final databaseReference = FirebaseDatabase.instance.reference();
  final userDatabaseReference = FirebaseDatabase.instance.reference().child("users");

  bool isPackageMode=true;
  String route;

  double cardFontSize = 17;

  String packageName = 'Name';
  String vehicleNumber = 'KA03 AH 0007';
  String transporterName = 'Name';
  String dropLocation = 'XYZ Cross';




  @override
  Widget build(BuildContext context) {

   //
    getData();

    return new WillPopScope(
        onWillPop: () async => false,

    child: Scaffold(
      body: Column(
        children: <Widget>[
          userType=='Package'?_headingForPackage():_headingForTransporter(),
          Expanded(
              child : Container(
                color: Colors.black12,
                child: chatMessages(),
              )
          ),
          _footer(),
        ],),
    ),
    );

  }
/*
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_VFu5D0Mx71cbqi',
      'amount': amount,
      'name': '$acceptedByGlobal',
      'description': 'Payment to $transporterName on ride to $route',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, timeInSecForIosWeb: 4);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIosWeb: 4);
  }
*/

  /// initialization of data
  void getData() {

    userDatabaseReference.child(uid).child('userType').once().then((
        DataSnapshot snapshot) {
        setState(() {
          userType = snapshot.value;
        });
    });

    userDatabaseReference.child(uid).child('route').once().then((
        DataSnapshot snapshot) {
      route = snapshot.value;
    });

    if (userType == 'Package' && acceptedByGlobal != null) {

      userDatabaseReference.child(acceptedByGlobal).child('name').once().then((
          DataSnapshot snapshot) {
        transporterName = snapshot.value;
      });

      userDatabaseReference.child(acceptedByGlobal).child('vehicleNumber')
          .once()
          .then((DataSnapshot snapshot) {
        vehicleNumber = snapshot.value;
      });

    }

    if(userType == 'Transporter') {
      setState(() {
        isPackageMode = false;
      });

      // print(packageUserIdForActiveSession);
      if (packageUserIdForActiveSession != null)
        {
        userDatabaseReference.child(packageUserIdForActiveSession)
            .child('name')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            packageName = snapshot.value;
          });
        });

      userDatabaseReference.child(packageUserIdForActiveSession)
          .child('route')
          .once()
          .then((DataSnapshot snapshot) {
        setState(() {
          route = snapshot.value;
          dropLocation = route;
        });
      });


        userDatabaseReference.child(uid).child('dropCount').once().then((
            DataSnapshot snapshot) {
          setState(() {
            if (snapshot.value == null)
              dropCount = 0;
            else
              dropCount = snapshot.value;
          });

        });

    }
    }

  }

  ///HEAD
  Widget _headingForPackage() {
    return new Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.fromLTRB( 10, 15, 10,15),
          color: Colors.lightBlue,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
              child : Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: 10,top: 15,bottom: 5),
                        child:Text('$transporterName',textAlign: TextAlign.start,style: TextStyle(color: Colors.white,fontSize: 27,fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.only(left: 10),
                        child:Text('$vehicleNumber',textAlign: TextAlign.end,style: TextStyle(color: Colors.white,fontSize: 23,fontWeight: FontWeight.normal)),
                      ),
                    ],
              ),
              ),
              Container(
                  alignment: Alignment.bottomRight,
                  child: new NeumorphicButton(
                    onPressed: () => _endRideButtonPressed(),
                      curve: Neumorphic.DEFAULT_CURVE,
                      margin: EdgeInsets.only(top: 30,right: 10,bottom: 5),
                      //onPressed: _endRideButtonPressedTest(),
                      style: NeumorphicStyle(
                          lightSource: LightSource.topLeft,
                          shape: NeumorphicShape.convex,
                          depth: 20,
                          intensity: 1,
                          boxShape:
                          NeumorphicBoxShape.circle(),
                          border: NeumorphicBorder()
                      ),
                      padding: const EdgeInsets.all(20),
                      child: NeumorphicText(
                        "END",
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            depth: 1,
                            color: Colors.red
                        ),
                        curve: Neumorphic.DEFAULT_CURVE,
                        textStyle: NeumorphicTextStyle(fontSize: 20, fontWeight: FontWeight.bold ),
                      ),

                    // style: TextStyle(fontSize: 32,color: Colors.blue),
                  )
              )
            ],
          ),
        );
  }

  Widget _headingForTransporter() {
    return new Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.fromLTRB( 10, 15, 10,15),
      color: Colors.lightBlue,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child : Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 10,top: 15,bottom: 5),
                  child:Text('$packageName',textAlign: TextAlign.start,style: TextStyle(color: Colors.white,fontSize: 27,fontWeight: FontWeight.bold)),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(left: 10),
                  child:Text('$dropLocation',textAlign: TextAlign.end,style: TextStyle(color: Colors.white,fontSize: 23,fontWeight: FontWeight.normal)),
                ),
              ],
            ),
          ),
          Container(
              alignment: Alignment.bottomRight,
              child: new NeumorphicButton(
                onPressed: () => _endRideButtonPressed(),
                curve: Neumorphic.DEFAULT_CURVE,
                margin: EdgeInsets.only(top: 30,right: 10,bottom: 5),
                //onPressed: _endRideButtonPressedTest(),
                style: NeumorphicStyle(
                    lightSource: LightSource.topLeft,
                    shape: NeumorphicShape.convex,
                    depth: 20,
                    intensity: 1,
                    boxShape:
                    NeumorphicBoxShape.circle(),
                    border: NeumorphicBorder()
                ),
                padding: const EdgeInsets.all(20),
                child: NeumorphicText(
                  "END",
                  style: NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      depth: 1,
                      color: Colors.red
                  ),
                  curve: Neumorphic.DEFAULT_CURVE,
                  textStyle: NeumorphicTextStyle(fontSize: 20, fontWeight: FontWeight.bold ),
                ),

                // style: TextStyle(fontSize: 32,color: Colors.blue),
              )
          )

        ],
      ),
    );
  }

  var dropCount = 0;
  _endRideButtonPressed() {
    var now = new DateTime.now();
    if(userType == 'Package') {
      //databaseReference.child('activeRides').child(packageUserIdForActiveSession).remove();
      //databaseReference.child('requests').child(route).child(uid).remove();

      //databaseReference.child('history').child(uid).child('transporterId').set(acceptedBy);

      String now = DateTime.now().toString();
      String time = now.replaceAll('-', '_');
      time = time.replaceAll(':', '_');
      time = time.replaceAll(' ' , '_');
      time = time.replaceAll('.' , '_');

      databaseReference.child('history').child(time).child(uid).child('transporter').set(acceptedByGlobal);
      databaseReference.child('history').child(time).child(uid).child('paymentStatus').set('pending');

      ///go to payment pop
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Stack(
                clipBehavior: Clip.none, children: <Widget>[
                Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('END RIDE',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,fontFamily: 'Devanagari Sangam MN'),),
                      Text('Would you like to treat $transporterName with a..',style: TextStyle(fontWeight: FontWeight.bold,) ),
                      Row(
                        children: <Widget>[
                          TextButton(onPressed: onPaymentClicked(5),
                              child: Column(
                                children: [
                                  Text('TEA'),
                                  Text('(₹5)')
                                ],
                              )

                          ),
                          TextButton(onPressed: onPaymentClicked(10),
                              child: Column(
                                children: [
                                  Text('COFFEE'),
                                  Text('(₹10)')
                                ],
                              )
                          ),
                          TextButton(onPressed: onPaymentClicked(20),
                              child: Column(
                                children: [
                                  Text('SAMOSA'),
                                  Text('(₹20)')
                                ],
                              )
                          ),
                        ],
                      ),
                     /*
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(),
                      ),
                      */
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          child: Text("Naah"),
                          onPressed: () {
                            exitActivePage();
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
              ),
            );
          });
    }
    else {

      userDatabaseReference.child(uid).child('availableToDrop').set(true);
      print('dropsCount is :::::::::: $dropCount');
      userDatabaseReference.child(uid).child('dropCount').set(dropCount+1);


      databaseReference.child('history').child(uid).child('paymentStatus').set('pending');

      databaseReference.child('activeRides').child(packageUserIdForActiveSession).remove();

      databaseReference.child('requests').child(route).child(packageUserIdForActiveSession).remove();
      
      databaseReference.child('history').child(now.toString()).child(uid).child('packageId').set(packageUserIdForActiveSession);
      databaseReference.child('history').child(now.toString()).child(uid).child('paymentStatus').set('pending');
      databaseReference.child('history').child(now.toString()).child(uid).child('route').set(route);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

    }
    print('Ride ended');
  }


  ///BODY
  Widget chatMessages() {
    final databaseReference = FirebaseDatabase.instance.reference().child('messages').child(rideId).orderByChild('time');
    return StreamBuilder(
      stream: databaseReference.onValue,
      builder: (context, snapshot) {

        //TODO show in order.......firebaselist??---potential solution---github--bookmarked------helloFlutter

        if (snapshot.hasData && !snapshot.hasError && snapshot.data.snapshot.value != null) {
          /*
          Map data;
          List item;
          databaseReference.onChildAdded
              .forEach((index, data) => {

          item.add({"key": index, ...data}));

              // print(event.snapshot.value)
          });

          print('""""data:::::::::: $item');*/
          Map data = snapshot.data.snapshot.value;
          List item = [];
          data.forEach((index, data) => item.add({"key": index, ...data}));
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 50),
              itemCount: item.length,
              itemBuilder: (context, index) {
                return MessageTile(
                  message: item[index]["message"],
                  sendByMe: uid == item[index]["sendBy"],
                  time: item[index]["time"]
                );
              });

        }else return Container();

      },
    );
  }
  addMessage() {
    var now = new DateTime.now();
    String messageTime = now.toString().replaceAll('-', '_');
    messageTime = messageTime.replaceAll(':', '_');
    messageTime = messageTime.replaceAll(' ' , '_');
    messageTime = messageTime.replaceAll('.' , '_');

    if (messageTextFieldController.text.isNotEmpty) {
      if(userType == 'Transporter') {
        databaseReference.child('messages').child(rideId).child(messageTime).child('sendBy').set(uid);
        databaseReference.child('messages').child(rideId).child(messageTime).child('message').set(messageTextFieldController.text);
        databaseReference.child('messages').child(rideId).child(messageTime).child('time').set(now.toString());
      }
      else {
        databaseReference.child('messages').child(rideId).child(messageTime).child('sendBy').set(uid);
        databaseReference.child('messages').child(rideId).child(messageTime).child('message').set(messageTextFieldController.text);
        databaseReference.child('messages').child(rideId).child(messageTime).child('time').set(now.toString());
      }
      setState(() {
        messageTextFieldController.text = "";
      });
    }
  }
  sendPopMessage(String message) {
    var now = new DateTime.now();
    String messageTime = now.toString().replaceAll('-', '_');
    messageTime = messageTime.replaceAll(':', '_');
    messageTime = messageTime.replaceAll(' ' , '_');
    messageTime = messageTime.replaceAll('.' , '_');

    if(userType == 'Transporter') {
      databaseReference.child('messages').child(rideId).child(messageTime).child('sendBy').set(uid);
      databaseReference.child('messages').child(rideId).child(messageTime).child('message').set(message);
      databaseReference.child('messages').child(rideId).child(messageTime).child('time').set(now.toString());
    }
    else {
      databaseReference.child('messages').child(rideId).child(messageTime).child('sendBy').set(uid);
      databaseReference.child('messages').child(rideId).child(messageTime).child('message').set(message);
      databaseReference.child('messages').child(rideId).child(messageTime).child('time').set(now.toString());

    }
  }

  ///FOOT
  Widget _footer(){

    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 8,top: 4,right: 4,bottom: 4),
                  child: GestureDetector(
                    onTap: () => sendPopMessage('Hello'),
                    child : Card(
                        shape:RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)
                        ),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          child: Text('Hello',style: TextStyle(fontSize: cardFontSize),textAlign: TextAlign.center,),
                        )
                    ),
                  )

                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => sendPopMessage('Okay'),
                    child: Card(
                      shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)
                      ),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text('Okay',style: TextStyle(fontSize: cardFontSize),textAlign: TextAlign.center,),
                      )
                  ),
                  )
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => sendPopMessage('Waiting near parking entrance'),
                    child: Card(
                      shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)
                      ),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text('Waiting near parking entrance',style: TextStyle(fontSize: cardFontSize),textAlign: TextAlign.center,),
                      )
                  ),
                  )
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => sendPopMessage('waiting near auto stand'),
                  child: Card(
                      shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)
                      ),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text('Waiting near auto stand',style: TextStyle(fontSize: cardFontSize),textAlign: TextAlign.center,),
                      )
                  ),
                  )
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => sendPopMessage('Thank you'),
                  child: Card(
                      shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)
                      ),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text('Thank you',style: TextStyle(fontSize: cardFontSize),textAlign: TextAlign.center,),
                      )
                  ),
                  )
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 4,top: 4,right: 4,bottom: 8),
                  child: GestureDetector(
                    onTap: () => sendPopMessage('No Problem'),
                  child: Card(
                      shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)
                      ),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text('No problem',style: TextStyle(fontSize: cardFontSize),textAlign: TextAlign.center,),
                      )
                  ),
                  )
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(1),
            child:Row(
              children: <Widget>[
                ///use it later for sharing location
                /*
                GestureDetector(
                  onTap: (){
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 20, ),
                  ),
                ),
                */
                SizedBox(width: 15,),
                Expanded(
                  child: TextField(
                    controller: messageTextFieldController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                FloatingActionButton(
                  onPressed: (){
                    addMessage();
                  },
                  child: Icon(Icons.send,color: Colors.blue,size: 35,),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
              ],

            ),
          ),
        ],
      ),
    );
  }

  exitActivePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  onPaymentClicked(int amt) {

    databaseReference.child('paymentOrders').child('id').set('order_$rideId');
    databaseReference.child('paymentOrders').child('entity').set('order_$rideId');
    databaseReference.child('paymentOrders').child('amount').set(amt);
    databaseReference.child('paymentOrders').child('amount_paid').set(0);
    databaseReference.child('paymentOrders').child('amount_due').set(amt);
    databaseReference.child('paymentOrders').child('receipt').set("receipt_$rideId");
    databaseReference.child('paymentOrders').child('status').set('created');
    databaseReference.child('paymentOrders').child('notes').set('to be paid to: $acceptedByGlobal');
    databaseReference.child('paymentOrders').child('created_at').set(DateTime.now());


    setState(() {
      amount = amt;
    });
   // openCheckout();
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String time;
  MessageTile({@required this.message, @required this.sendByMe, @required this.time});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),

      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
            top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe ? [
                const Color(0xff007EF4),
                const Color(0xff2A75BC)
              ]
                  : [
                const Color(0x1AFFFFFF),
                const Color(0x1AFFFFFF)
              ],
            )
        ),
        child: Text(message == null? 'NULL':message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}

class PopUpForRideEnd extends StatelessWidget{
    final _formKey = GlobalKey<FormState>();

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Flutter"),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Stack(
                        clipBehavior: Clip.none, children: <Widget>[
                          Positioned(
                            right: -40.0,
                            top: -40.0,
                            child: InkResponse(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: CircleAvatar(
                                child: Icon(Icons.close),
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                    child: Text("Submitß"),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
            child: Text("Open Popup"),
          ),
        ),
      );
    }
}