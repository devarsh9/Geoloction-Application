import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/database.dart';
import 'package:location/Animation/FadeAnimation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'crud.dart';
import 'package:location/fragments/Home_fragment.dart';
import 'package:location/fragments/Bookmark_fragment.dart';
import 'package:location/fragments/Setting_Fragment.dart';
import 'package:location/fragments/Friend_Fragment.dart';
import 'dart:io';

void main() => runApp(MyApp());
crudMethods crudObj = new crudMethods();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      //theme: ThemeData(),
      initialRoute: MyHomePage.id,
      routes: {
        MyHomePage.id: (context) => MyHomePage(),
        Registration.id: (context) => Registration(),
        Login.id: (context) => Login(),
        Gps.id: (context) => Gps(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const String id = "HOMESCREEN";
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushNamed(Login.id);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.blue[700]),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/images/logo3.png"),
                        radius: 95.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30.0),
                      ),
                      Text(
                        "Geolocation app ",
                        style: TextStyle(
                          fontSize: 44.0,
                          color: Colors.blueGrey[900],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                        // backgroundColor: Colors.blue[400],
                        ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text("")
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;
  const CustomButton({Key key, this.callback, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Material(
        elevation: 11.0,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: callback,
          minWidth: 200.0,
          height: 45.0,
          child: Text(text,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          color: Colors.blue,
          splashColor: Colors.lightGreen,
        ),
      ),
    );
  }
}

class Registration extends StatefulWidget {
  static const String id = "REGISTRATION";
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String email, username;
  String password, cpassword;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerUser() async {
    final formState = formkey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        AuthResult user = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String uid = (await FirebaseAuth.instance.currentUser()).uid;
        print("-----Sign Up-----");
        print(uid);
        await DatbaseSevice(uid: user.user.uid)
            .updateUserData(email, username, uid);
        user.user.sendEmailVerification();
        Navigator.of(context).pop();
        print(user.user.email);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Gps(),
          ),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.blue[400],
          Colors.blue[600],
          Colors.blue[900]
        ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 35,
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Enroll Yourself",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/images/logo3.png"),
                    radius: 45.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(50, 50, 50, .85),
                          blurRadius: 20,
                          offset: Offset(0, 10))
                    ],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60))),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(27, 95, 225, .5),
                                    blurRadius: 20,
                                    offset: Offset(0, 10))
                              ]),
                          child: Form(
                            key: formkey,
                            child: Column(
                              children: <Widget>[
                                // Text('Email',style:TextStyle(color: Colors.grey,fontSize: 10)),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]))),
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: "E-Mail ",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    validator: (input) {
                                      if (input.isEmpty) {
                                        return 'Please type email';
                                      }
                                    },
                                    onChanged: (input) => email = input,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]))),
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                        hintText: "USERNAME",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    validator: (input) {
                                      if (input.isEmpty) {
                                        return 'Please type Username';
                                      }
                                    },
                                    onChanged: (input) => username = input,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]))),
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    obscureText: true,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        hintText: "PASSWORD",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    validator: (input) {
                                      if (input.isEmpty) {
                                        return 'Please type password';
                                      }
                                    },
                                    onChanged: (input) => password = input,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]))),
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    obscureText: true,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        hintText: "CONFIRM-PASSWORD",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    validator: (input) {
                                      if (input.isEmpty) {
                                        return 'Please type password again';
                                      } else if (password != cpassword) {
                                        return 'Password doesnt match';
                                      }
                                    },
                                    onChanged: (input) => cpassword = input,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(children: <Widget>[
                          // Expanded(
                          SizedBox(
                            width: 120,
                            child: Center(
                              child: CustomButton(
                                text: "Register",
                                callback: () async {
                                  await registerUser();
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          //  Expanded(
                          SizedBox(
                            //width: 120,
                            child: Center(
                              child: RaisedButton(
                                  child: Text('Back to Login',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                  color: Colors.blueGrey[900],
                                  splashColor: Colors.lightGreen,
                                  elevation: 12.0,
                                  onPressed: () {
                                    print('Clicked');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Login(),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ])
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  static const String id = "LOGIN";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email, password;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser() async {
    final formState = formkey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        final user = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        print(user);
        String UserId = (await FirebaseAuth.instance.currentUser()).uid;
        print("-----Login-----");
        print(UserId);
        //widget.onSignedIn();
        // Navigator.of(context).pop();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Gps()));
      } catch (e) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.blue[400],
          Colors.blue[600],
          Colors.blue[900]
        ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 35),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Welcome Back",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/images/logo3.png"),
                    radius: 45.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(50, 50, 50, .85),
                          blurRadius: 20,
                          offset: Offset(0, 10))
                    ],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60))),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(27, 95, 225, .5),
                                    blurRadius: 20,
                                    offset: Offset(0, 10))
                              ]),
                          child: Form(
                            key: formkey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]))),
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: "Enter your E-Mail ",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    validator: (input) {
                                      if (input.isEmpty) {
                                        return "Please type email";
                                      }
                                    },
                                    // validator:(value)=>value.isEmpty?'Email cant be empty':null,
                                    onChanged: (input) => email = input,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]))),
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    obscureText: true,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        hintText: "Enter your Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    validator: (input) {
                                      if (input.isEmpty) {
                                        return 'Please type password';
                                      }
                                    },
                                    // validator:(value)=>value.isEmpty?'Password cant be empty':null,
                                    onChanged: (input) => password = input,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 50),
                          child: Center(
                            child: CustomButton(
                              text: "Login",
                              callback: () async {
                                await loginUser();
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Don't have an account- Sign up now ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 50),
                          child: Center(
                            child: RaisedButton(
                                child: Text('Sign up',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                color: Colors.blueGrey[900],
                                splashColor: Colors.lightGreen,
                                elevation: 11.0,
                                onPressed: () {
                                  print('Clicked');
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Registration()));
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class Gps extends StatefulWidget {
  static const String id = "GPS";
  FirebaseUser user;

  //const Gps({Key key, this.user}) : super(key: key);
  @override
  final drawerItems = [
    new DrawerItem("Home", Icons.menu),
    new DrawerItem("Bookmarks", Icons.bookmark),
    new DrawerItem("Settings", Icons.settings),
    new DrawerItem("Friends", Icons.face),

    // new DrawerItem("Fragment 3", Icons.info)
  ];
  _GpsState createState() => _GpsState();
}

class _GpsState extends State<Gps> {
  String result, email, Username;
  bool showUser = false, showEmail = false;
  DocumentSnapshot snap;
  var title, snippet;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firesstore = Firestore.instance;
  int _selectedDrawerIndex = 0;
  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new HomeFragment();
      case 1:
        return new BookmarkFragment();
      case 2:
        return new SettingFragment();
      case 3:
        return new FriendFragment();
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  void initState() {
    getData();
    super.initState();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            elevation: 10.0,
            backgroundColor: Colors.white,
            title: Text(
              'Are you sure?',
              style: TextStyle(
                  color: Colors.blueGrey[900], fontWeight: FontWeight.bold),
            ),
            content: Text('You want to exit '),
            actions: <Widget>[
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: Icon(Icons.cancel,size: 34.0,),
                color: Colors.red[600],
              ),
              IconButton(
                onPressed: () {
                  _auth.signOut();
                  exit(0);
                },
                /*Navigator.of(context).pop(true)*/
                icon: Icon(Icons.check_circle,size: 34.0,),
                color: Colors.green[600],
              ),
            ],
          ),
        ) ??
        false;
  }

  void getData() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String uid = user.uid.toString();
    print(uid);
    try {
      snap = await Firestore.instance.collection('Users').document(uid).get();
      //showMap=true;
    } catch (e) {
      print('Hi');
    }
    setState(() {
      email = snap.data['Email'];
      Username = snap.data['Username'];
      showEmail = true;
      showUser = true;
    });
    print(email);
    print(Username);
    // snapshot=await Firestore.instance.collection('Users').getDocuments();
    //print(UserId);
  }


  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          // backgroundColor: Colors.white,
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    /* image: DecorationImage(
              image: new AssetImage(
              'assets/images/logo3.png'),
                 fit: BoxFit.fill,
              ),*/
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.lightBlue[900],
                        Colors.lightBlue[400],
                      ],
                    ),
                  ),
                  accountName: showUser
                      ? Text(
                          Username,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      : Text(
                          "Username",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                  accountEmail: showEmail
                      ? Text(email,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))
                      : Text("email",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                  currentAccountPicture: new CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/logo3.png'),
                  ),
                ),
                Column(children: drawerOptions),
//            ListTile(
//              leading: Icon(Icons.settings),
//              title: Text('Settings'),
//              onTap: () {
//
//                },
//            ),
                ListTile(
                  leading: Icon(Icons.power_settings_new),
                  title: Text('Logout'),
                  onTap: () {
                    //dialogTrigger(context);
                    _auth.signOut();
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => Login()));
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text(
              widget.drawerItems[_selectedDrawerIndex].title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0.0,
            actions: <Widget>[],
          ),
          body: _getDrawerItemWidget(_selectedDrawerIndex)),
    );
  }
}
