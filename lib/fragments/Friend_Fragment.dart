import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/crud.dart';
import 'package:location/fragments/chatting.dart';

var snap1,snap, document, snapShots;
bool showEmail1 = false, showUsername1 = false;
String uid;
crudMethods crudObj = new crudMethods();

class FriendFragment extends StatefulWidget {
  @override
  _FriendFragmentState createState() => _FriendFragmentState();
}

class _FriendFragmentState extends State<FriendFragment>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelector);
  }

  void getData() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uid = user.uid.toString();
    print(uid);
  }

  void _handleTabSelector() {
    setState(() {});
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0.0,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorWeight: 7.0,
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.face,
                      size: 26.0,
                      color: _tabController.index == 0
                          ? Colors.white
                          : Colors.blue[900]),
                  child: Text(
                    "Friends",
                    style: TextStyle(
                        color: _tabController.index == 0
                            ? Colors.white
                            : Colors.blue[900]),
                  ),
                ),
                Tab(
                    icon: Icon(Icons.person_add,
                        size: 26.0,
                        color: _tabController.index == 1
                            ? Colors.white
                            : Colors.blue[900]),
                    child: Text(
                      "Requests",
                      style: TextStyle(
                          color: _tabController.index == 1
                              ? Colors.white
                              : Colors.blue[900]),
                    )),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            FriendSection(),
            RequestSection(),
          ],
        ),
      ),
//      children: <Widget>[
//        FriendSection(),
//      ],
    );
  }
}
class FriendSection extends StatefulWidget {
  @override
  _FriendSectionState createState() => _FriendSectionState();
}

class _FriendSectionState extends State<FriendSection> {
  String result, email, Username, status = '0';
  void getData() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uid = user.uid.toString();
    print(uid);
    try {
      snap = await Firestore.instance.collection('Users').document(uid).get();
    } catch (e) {
      print('Hi');
    }
    setState(() {
      email = snap.data['Email'];
      Username = snap.data['Username'];
    });
    print(email);
    print(Username);
    // snapshot=await Firestore.instance.collection('Users').getDocuments();
    //print(UserId);
  }
  @override
  void initState() {
    getData();
    crudObj.getChat().then((results) {
      setState(() {
        snapShots = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: Column(
          children: <Widget>[
            SizedBox(
              height: 15.0,
            ),
            //CategorySelector(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 3.0,
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 5.0),
                  height: 500,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45.0),
                      // topRight: Radius.circular(35.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 190, 1.0),
                          blurRadius: 18,
                          offset: Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      // FavouriteContacts(),
                      //RecentChats(),
                      GroupChat(),
                    ],
                  ),
                ),
              ),
            )
          ],
      ),
    );
  }
}

class GroupChat extends StatelessWidget {
  Widget build(BuildContext context) {
    if (snapShots != null) {
      return Expanded(
        child: Container(
            margin: EdgeInsets.only(left: 6.0),
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45.0),
                //topRight: Radius.circular(35.0),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45.0),
                //topRight: Radius.circular(35.0),
              ),
              child: StreamBuilder(
                  stream: snapShots,
                  builder: (context, snapShots) {
                    return ListView.builder(
                      itemCount: snapShots.data.documents.length,
                      padding: EdgeInsets.all(5.0),
                      itemBuilder: (context, i) {
                        if (snapShots.data.documents[i].data['id'] == uid) {
                          return Container();
                        } else {
                          return GestureDetector(
                            onTap: () {
                              // update = snapShots.data.documents[i].documentID;
                              //crudObj.updateData(update);
                              // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: chat.sender),),),
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Chat(
                                            uid: uid,
                                            peerId: snapShots
                                                .data.documents[i].documentID,
                                            name: snapShots.data.documents[i]
                                                .data['Username'],
                                          )));
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 4.0, bottom: 7.0, right: 0.0, left: 0.0),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
//                                    snapShots.data.documents[i].data['Email'] ==
//                                            '0'
//                                        ? Colors.grey[100]
//                                        : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage(
                                            'assets/images/logo3.png'),
                                        backgroundColor: Colors.blueGrey,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            snapShots.data.documents[i]
                                                .data['Username'],
                                            style: TextStyle(
                                              color: Colors.grey[900],
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width *
                                                0.45,
                                            child: Text(
                                              snapShots.data.documents[i]
                                                  .data['Email'],
                                              style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      snapShots.data.documents[i]
                                          .data['Email'] ==
                                          '0'
                                          ? Container(
                                        width: 40,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                          BorderRadius.circular(30.0),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'NEW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                          : Text(''),
                                      SizedBox(
                                        height: 18.0,
                                      ),
                                      Text(
                                        //chat.time,
                                        '',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        ;
                      },
                    );
                  }),
            )),
      );
    } else {
      return Text(
        'Loading',
      );
    }
  }
}

class RequestSection extends StatefulWidget {
  @override
  _RequestSectionState createState() => _RequestSectionState();
}

class _RequestSectionState extends State<RequestSection> {
  String reqEmail;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: Center(
            child: Text("Request Section"),
          ),
        ),
        Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      //  lat = _lastMapPosition.latitude;
                      // long = _lastMapPosition.longitude;
                      showModalBottomSheet(
                        context: context,
                        builder: (builder) {
                          return Container(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Send a friend request ",
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                      hintText:
                                      'Enter the email of your friend'),
                                  onChanged: (value) {
                                    this.reqEmail = value;
                                  },
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                FlatButton(
                                    child: Text('Add'),
                                    textColor: Colors.white,
                                    color: Colors.blueGrey[900],
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      findUser(reqEmail);
                                    }),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.add,
                      size: 36.0,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  var friendId;

  void findUser(reqEmail) async {
//    final docRef = await Firestore.instance.collection('Users').where("Email", isEqualTo: reqEmail).getDocuments();
//
  }
}
