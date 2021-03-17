import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';



String  name,srn,phNumber;
String route;
int vehicleType;
bool isFormEditable=false;
bool isPackageMode = true; //package :: get picked up ///transporter :: pick up
bool isSwitched = !isPackageMode;
var userType;

var imageUrl;


TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController srnController = TextEditingController();
TextEditingController phNumberController = TextEditingController();
TextEditingController vehNoController = TextEditingController();


String uid = FirebaseAuth.instance.currentUser.uid;
final databaseReference = FirebaseDatabase.instance.reference();
final userDatabaseReference = FirebaseDatabase.instance.reference().child("users");

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProfilePage());
}

class ProfilePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    getData();
    return MaterialApp(
      theme: ThemeData(
        primaryColor:  Colors.white,
      ),
      home: _ProfilePage(),
    );
  }
  /// initializing data in form
  void getData(){

    userDatabaseReference.child(uid).child("name").once().then((DataSnapshot snapshot) {
      name = snapshot.value;
      nameController.text = name;
    });

    userDatabaseReference.child(uid).child("srn").once().then((DataSnapshot snapshot) {
      srn = snapshot.value;
      srnController.text=srn;
    });

    userDatabaseReference.child(uid).child("phNumber").once().then((DataSnapshot snapshot) {
      phNumber = snapshot.value;
      phNumberController.text=phNumber;
    });

    userDatabaseReference.child(uid).child("route").once().then((DataSnapshot snapshot) {
      route = snapshot.value;
    });
    userDatabaseReference.child(uid).child("email").once().then((DataSnapshot snapshot) {
      emailController.text = snapshot.value;
    });
    userDatabaseReference.child(uid).child("vehicleType").once().then((DataSnapshot snapshot) {
      vehicleType = snapshot.value;
    });
    userDatabaseReference.child(uid).child("vehicleNumber").once().then((DataSnapshot snapshot) {
      vehNoController.text = snapshot.value;
    });
    userDatabaseReference.child(uid).child('profile_image').once().then((DataSnapshot snapshot) {
      imageUrl = snapshot.value;
    });


  }
}

class _ProfilePage extends StatefulWidget {

  @override
  _ProfilePageState createState() => _ProfilePageState();
}




class _ProfilePageState extends State<_ProfilePage>{
  Icon actionIcon=Icon(Icons.edit);
  int currentRoute;
  var switchText = 'Get Picked Up';

  @override
  Widget build(BuildContext context) {
    userDatabaseReference.child(uid).child('userType').once().then((DataSnapshot snapshot) {
      userType = snapshot.value;
      setState(() {
        userType = userType;
        userType=='Package'? isPackageMode = true : isPackageMode = false;
      });
    });
    _editActionIconInit();//to initialize the edit/upload action button


    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: [
            IconButton(icon: actionIcon, onPressed: _onEditButtonPressed)
          ],
          elevation: 20,
          backwardsCompatibility: true,
        ),
      body: isFormEditable?_editableForm():_uneditableForm(),
    );
  }

  //TODO work on this funcyion
  _loadImage()  async {

  final ref = FirebaseStorage.instance
      .ref()
      .child('path')
      .child('to')
      .child('the')
      .child('image_filejpg');

 // ref.putFile(imageFile);
// or ref.putData(Uint8List.fromList(imageData));

  var url = await ref.getDownloadURL();
   print(url);
 }


  /// editableform
  Widget _editableForm(){
    return ListView(
      children: <Widget> [
        Container(
          padding: EdgeInsets.only(top: 30),
            child : Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.white,
                  child:  Image.network(
                (imageUrl == null)
                    ? 'https://www.materialui.co/materialIcons/image/add_a_photo_black_36x36.png'//Default Picture
                    : imageUrl,
                fit: BoxFit.cover,
              ),
              ),
                Positioned(
                  left: 190,
                  top: 50,
                  child:
                  NeumorphicButton(
                      curve: Neumorphic.DEFAULT_CURVE,
                      onPressed: () => uploadImage(),
                      style: NeumorphicStyle(
                          lightSource: LightSource.topLeft,
                          shape: NeumorphicShape.concave,
                          depth: 1,
                          intensity: 1,
                          boxShape:
                          NeumorphicBoxShape.circle(),
                          border: NeumorphicBorder()
                      ),
                      child:  Container(
                        alignment: Alignment.center,
                        child : NeumorphicIcon(
                            Icons.edit,
                            style: NeumorphicStyle(
                                intensity: 0,
                                shape: NeumorphicShape.concave,
                                lightSource: LightSource.topLeft,
                                border: NeumorphicBorder(isEnabled: true,color: Colors.white,width: 1.5),
                                depth: 9,
                                color:  Colors.blueGrey
                            ),
                            size: 30
                        ),
                      )
                //  ),
               ),
                // IconButton(icon: Icon(Icons.edit), onPressed: imageEdit),
                )
              ],
            )
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
            keyboardType: TextInputType.name,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Email',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        if(isSwitched)_vehicleForm(),
        Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20,0),
          child: TextField(
            controller: srnController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'SRN',
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
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
            keyboardType: TextInputType.phone,
          ),
        ),
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
                    _uploadRoute(value);
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
                    _uploadRoute(value);
                  });
                },
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(iconSize: 80,icon: Icon(Icons.upload_rounded), onPressed: onIdUploadPressed,tooltip: 'Upload image of your ID card'),
              Text('Upload your ID Card Image',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center)
            ],
          ),
        ),
      ],
    );
  }
  /// non-editable form
  Widget _uneditableForm(){
    return ListView(
      children: <Widget> [
        Container(
            padding: EdgeInsets.only(top:20),
            child : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                imageUrl==null?
                NeumorphicIcon(
                  Icons.account_circle,size: 120,
                  style: NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      color: Colors.white10,
                      depth: 3,
                      shadowDarkColor: Colors.blueGrey
                  ),
                )
                    : Image.network(imageUrl,height: 120,width: 120),

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    NeumorphicSwitch(
                      style: NeumorphicSwitchStyle(
                      ),
                      onChanged: toggleSwitch,
                      value: isSwitched,
                      height: 70,
                    ),
                    Text('$switchText',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                  ],
                ),


              ],
            )
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: TextField(
            controller: nameController,
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),
        ),
        if(isSwitched)_vehicleForm(),
        Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: TextField(
            controller: emailController,
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Email',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20,0),
          child: TextField(
            controller: srnController,
            readOnly: true,
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
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Phone Number',
            ),
          ),
        ),
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
                    _uploadRoute(value);
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
                    _uploadRoute(value);
                  });
                },
              ),
            ],
          ),
        ),

      ],
    );
  }

  /// vehicle form when the user mode is switched to transporter mode
  Widget _vehicleForm() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20,5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              NeumorphicRadio(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  child: Center(
                    child: Text("4 Wheeler",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                  ),
                ),
                style: NeumorphicRadioStyle(
                  selectedColor: Colors.blue,
                  shape: NeumorphicShape.concave,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                ),

                value: 4,
                groupValue: vehicleType,
                onChanged: (int value) {
                  setState(() {
                    vehicleType = value;
                    _uploadVehicleType(value);
                  });
                },
              ),
              NeumorphicRadio(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  child: Center(
                    child: Text("2 Wheeler",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                  ),
                ),
                style: NeumorphicRadioStyle(
                  selectedColor: Colors.blue,
                  shape: NeumorphicShape.concave,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                ),
                value: 2,
                groupValue: vehicleType,
                onChanged: (int value) {
                  setState(() {
                    vehicleType = value;
                    _uploadVehicleType(value);
                  });
                },
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: TextField(
            controller: vehNoController,
            readOnly: !isFormEditable,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Vehicle Number',
            ),
          ),
        ),
      ],
    );
  }

  /// when app bar action edit button is pressed
  void _onEditButtonPressed() {
    if(isFormEditable == false){
      setState(() {
        actionIcon=Icon(Icons.check);
        isFormEditable=true;
      });
    }else{
      setState(() {
        onUploadPressed();
        actionIcon=Icon(Icons.edit);
        isFormEditable = false;
      });
    }
  }

  /// initialize app bar action edit button
  void _editActionIconInit(){
    if(isFormEditable)
      actionIcon=Icon(Icons.check);
    else
      actionIcon=Icon(Icons.edit);
  }

  /// when actionbar edit button is pressed to upload
  void onUploadPressed() {

    userDatabaseReference.child(uid).child("userId").set(uid).toString();
    userDatabaseReference.child(uid).child("name").set(nameController.text);
    userDatabaseReference.child(uid).child("srn").set(srnController.text);
    userDatabaseReference.child(uid).child("phNumber").set(phNumberController.text);
    userDatabaseReference.child(uid).child("email").set(emailController.text);
    userDatabaseReference.child(uid).child("vehicleNumber").set(vehNoController.text);
  }

  /// update route when radio button is selected
  void _uploadRoute(String route){
    userDatabaseReference.child(uid).child("route").set(route);
  }

  /// when user mode switch is pressed
  void toggleSwitch(bool value) {

    if(isSwitched == false)
    {
      setState(() {
        isSwitched = true;
        isPackageMode=false;
        userType = 'Transporter'; //change to transporter mode
        switchText = 'Pick Up';

        _updateUserType(userType);

      });
    }
    else
    {
      setState(() {
        isSwitched = false;
        isPackageMode=true;
        userType = 'Package';//change to package mode
        switchText = 'Get Picked Up';

        _updateUserType(userType);
      });
    }
  }

  /// updating user type (mode) in DB
  void _updateUserType(var userType){
    userDatabaseReference.child(uid).child("userType").set(userType);
  }

  /// uploading vehicle type based on radio button selected
  void _uploadVehicleType(int type){
    userDatabaseReference.child(uid).child("vehicleType").set(type);
  }

  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted){
      //Select Image
      image = await _imagePicker.getImage(source: ImageSource.gallery);
      var file = File(image.path);

      if (image != null){
        //Upload to Firebase
        var snapshot = await _firebaseStorage.ref()
            .child('images/profile_images/$uid')
            .putFile(file).whenComplete(() => SnackBar(content: Text('Uploaded')));
        var downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
          userDatabaseReference.child(uid).child('profile_image').set(downloadUrl);
        });
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }

  onIdUploadPressed() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted){
      //Select Image
      image = await _imagePicker.getImage(source: ImageSource.gallery);
      var file = File(image.path);

      if (image != null){
        //Upload to Firebase
        var snapshot = await _firebaseStorage.ref()
            .child('images/ID_cards/$uid')
            .putFile(file).whenComplete(() => SnackBar(content: Text('ID Uploaded')));
        var downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
          userDatabaseReference.child(uid).child('ID_image').set(downloadUrl);
        });
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }

}


