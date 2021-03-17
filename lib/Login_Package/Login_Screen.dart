import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../Home_Page.dart';

//TODO ALLOW GOOGLE SIGN IN
//TODO update register form


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {

  var databaseReference = FirebaseDatabase.instance.reference();


  String route;

  
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController srnController = TextEditingController();
  TextEditingController phNumberController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login Screen App'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Drop Me',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () {

                  },
                  textColor: Colors.blue,
                  child: Text('Forgot Password'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    // ignore: deprecated_member_use
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Login'),
                      onPressed: () {
                        _signInWithEmailAndPassword();
                      },
                    )
                ),
                Container(
                    child: Row(
                      children: <Widget>[
                        Text('Does not have account?'),
                        TextButton(
                          child: Text(
                            'Sign in',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            _pushSignUp();//signup screen
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ))
              ],
            )
        )
    );
  }



  Future<void> _signInWithEmailAndPassword() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      print('login');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        _pushSignUp();
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  //for registration
  void _pushSignUp(){

    Navigator.of(context).push(
    MaterialPageRoute<void>(
        builder: (BuildContext context){
              return Scaffold(
                appBar: AppBar(
                  title: Text('Registration'),
                  actions: [
                    IconButton(icon: Icon(Icons.check_circle_outline), onPressed:_submit),
                  ],
                ),
                body: ListView(
                  children: <Widget> [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20,0),
                      child: TextField(
                        controller: srnController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'SRN',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20,20),
                      child: TextField(
                        controller: phNumberController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Phone Number',
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Text('From which side do you usually go?', style: TextStyle( fontSize: 17 , fontWeight: FontWeight.bold , fontStyle: FontStyle.normal)),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 10, 20,20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                NeumorphicRadio(
                                  padding: EdgeInsets.all(20),
                                  child: SizedBox(
                                    child: Center(
                                      child: Text("Belhalli Cross",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  style: NeumorphicRadioStyle(
                                    selectedColor: Colors.blue,
                                    shape: NeumorphicShape.concave,
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                                  ),

                                  value: 'Belhalli',
                                  groupValue: route,
                                  onChanged: (String value) {
                                    setState(() {
                                      route = value;
                                    });
                                  },
                                ),

                                NeumorphicRadio(
                                  padding: EdgeInsets.all(20),
                                  child: SizedBox(
                                    child: Center(
                                      child: Text("Bagalur Cross",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  style: NeumorphicRadioStyle(
                                    selectedColor: Colors.blue,
                                    shape: NeumorphicShape.concave,
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                                  ),

                                  value: 'Bagalur',
                                  groupValue: route,
                                  onChanged: (String value) {
                                    setState(() {
                                      route = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            ));
  }

  _submit() async {
    try {
      String uid;
      uid = FirebaseAuth.instance.currentUser.uid;
      databaseReference = databaseReference.child("users").child(uid);
      databaseReference.child("userId").set(uid).toString();
      databaseReference.child("name").set(nameController.text).toString();
      databaseReference.child("srn").set(srnController.text);
      databaseReference.child("phNumber").set(phNumberController.text);
      databaseReference.child("email").set(emailController.text).toString();
      databaseReference.child("route").set(route);

      print('_sumit');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}

