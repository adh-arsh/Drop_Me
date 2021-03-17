import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'Login_Package/Login_Screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SettingPage());
}

class SettingPage extends StatefulWidget{
  @override
  _SettingPageState createState() => _SettingPageState();

}

class _SettingPageState extends State<SettingPage>{
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       elevation: 20,
       title : Text('Settings'),
       backgroundColor: Colors.black12,
     ),
     body: Column(
       children: [
         Expanded(
          child: ListView(
             children: <Widget>[
               Container(
                 color: Colors.white,
                 width: MediaQuery.of(context).size.width,
                 height: 50,
                 margin: EdgeInsets.only(top: 8,bottom: 4),
                 child: TextButton(
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => AboutDeveloper()),
                     );
                   },
                   child:
                     Text('About Developer',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                 ),
               ),
               Container(
                 color: Colors.white,
                 width: MediaQuery.of(context).size.width,
                 height: 50,
                 margin: EdgeInsets.only(top: 8,bottom: 4),

                 child: TextButton(
                   onPressed: () {
                     Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => ContactDeveloper()),
                   );
                   },
                   child:
                   Text('Contact Developers',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                 ),
               ),
               Container(
                 color: Colors.white,
                 width: MediaQuery.of(context).size.width,
                 height: 50,
                 margin: EdgeInsets.only(top: 8,bottom: 4),

                 child: TextButton(
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => CreditsAndLicense()),
                     );
                   },
                   child:
                   Text('Credits and License',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                 ),
               ),
             ],
           ),
         ),
         Container(
           color: Colors.red,
           width: MediaQuery.of(context).size.width,
           height: 50,
           child: TextButton(
             onPressed: () {
               _signOut();
               print('LOG OUT');
             },
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 Text('LOG OUT',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
               ],
             ),

           ),
         ),
       ],
     ),

   );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );


  }


}

class AboutDeveloper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:AppBar(
        title: Text('About Developer'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Made by adh-arsh',textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
          ],
        ),
      ),
    );
  }

}

class ContactDeveloper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:AppBar(
        title: Text('Contact Developer'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('0001-0002-112-21',textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
          ],
        ),
      ),
    );
  }

}

class CreditsAndLicense extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:AppBar(
        title: Text('Credits and License'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('bleh bleh bleh',textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
          ],
        ),
      ),
    );
  }

}