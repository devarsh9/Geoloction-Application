import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
//import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  bool mapToggle = false;
  var currentLocation;
  var locName;
  String uid;
//  var bookmarks1 = [];
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final Set<Marker> bookmarks1 = {};
  GoogleMapController mapController;
  void initState() {
    super.initState();
    Geolocator().getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
        getBookmarks();
        currentMarker();
      });
    });
  }

  currentMarker() {
    setState(() {
      bookmarks1.add(
        Marker(
          markerId: MarkerId("CurrentMarker"),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          draggable: false,
          // infoWindow:InfoWindow(title: bookmark['Place'],
          //  snippet: 'This is a snippet',
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  getBookmarks() async {
    print('HI');
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uid = user.uid.toString();
    print(uid);
    Firestore.instance
        .collection('Users')
        .document(uid)
        .collection('Bookmarks')
        .getDocuments()
        .then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; ++i) {
          // bookmarks1.add(docs.documents[i].data);
          getAddress(docs.documents[i].data);
          initBookmark(docs.documents[i].data, docs.documents[i].documentID,address);
        }
        print(bookmarks1);
      }
    });
  }

  String address;
  List<Placemark> placemark;
  void getAddress(bookmark) async {
    placemark = await Geolocator().placemarkFromCoordinates(
        bookmark['Location'].latitude, bookmark['Location'].longitude);
     address = placemark[0].name.toString() +
        " , " +
        placemark[0].locality.toString() +
        ", Postal Code :" +
        placemark[0].postalCode.toString();
         print(address);
  }

  initBookmark(bookmark, bookmarkId,address) {
    setState(() {
      bookmarks1.add(
        Marker(
          markerId: MarkerId(bookmarkId),
          position: LatLng(
              bookmark['Location'].latitude, bookmark['Location'].longitude),
          draggable: false,
          infoWindow: InfoWindow(
            title: bookmark['Place'],
            snippet: address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  final CameraPosition _position1 = CameraPosition(
    //bearing: 192.833,
    target: LatLng(0.0, 0.0),
    //tilt: 59.440,
    zoom: 2.0,
  );

  Future<void> _goToPosition1() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed() {
    setState(() {
      print(_lastMapPosition);
//      bookmarks1.add(
//        Marker(
//          markerId: MarkerId(_lastMapPosition.toString()),
//          position: _lastMapPosition,
//          infoWindow: InfoWindow(
//            title: 'This is a Title',
//            snippet: 'This is a snippet',
//          ),
//          icon:
//              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//        ),
//      );
    });
  }

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      heroTag: null,
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height - 80,
            width: double.infinity,
            child: mapToggle
                ? GoogleMap(
                    rotateGesturesEnabled: false,
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          currentLocation.latitude, currentLocation.longitude),
                      zoom: 15.0,
                    ),
                    mapType: _currentMapType,
                    markers: bookmarks1,
                    onCameraMove: _onCameraMove,
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                button(_onMapTypeButtonPressed, Icons.map),
                SizedBox(
                  height: 16.0,
                ),
                //button(_onAddMarkerButtonPressed(), Icons.add_location),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    //  lat = _lastMapPosition.latitude;
                    // long = _lastMapPosition.longitude;
                    showModalBottomSheet(
                      context: context,
                      builder: (builder) {
                        return Container(
                          height: 500.0,
                          padding: EdgeInsets.only(left: 10, right: 10.0),
                          color: Colors.lightBlue[50],
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Add location to your Bookmark",
                                style: TextStyle(
                                    fontSize: 19.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 1.0,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromRGBO(27, 95, 225, .5),
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
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            hintText: "Name for this bookmark ",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none,
                                          ),
                                          validator: (input) {
                                            if (input.isEmpty) {
                                              return 'Please type a name ';
                                            }
                                          },
                                          onChanged: (input) => locName = input,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 3.0,
                              ),
                              Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    _lastMapPosition.latitude.toString(),
                                    style: TextStyle(fontSize: 10.0),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    _lastMapPosition.longitude.toString(),
                                    style: TextStyle(fontSize: 10.0),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromRGBO(27, 95, 225, .5),
                                          blurRadius: 20,
                                          offset: Offset(0, 10))
                                    ]),
                                height: 180,
                                margin: EdgeInsets.only(
                                    top: 10.0, left: 6.0, right: 6.0),
                                child: Stack(
                                  children: <Widget>[
                                    GoogleMap(
                                      rotateGesturesEnabled: false,
                                      myLocationEnabled: false,
                                      zoomControlsEnabled: false,
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                            _lastMapPosition.latitude,
                                            _lastMapPosition.longitude),
                                        zoom: 18.0,
                                      ),
                                    ),
                                    Center(
                                      child: IconButton(
                                        icon: Icon(Icons.add_location),
                                        iconSize: 35.0,
                                        onPressed: () {},
                                        color: Colors.red,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 2.01,
                              ),
                              RaisedButton(
                                  child: Text('ADD',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Colors.blue[900],
                                  splashColor: Colors.lightGreen,
                                  elevation: 11.0,
                                  onPressed: () {
                                    print(_lastMapPosition);
                                    addBookmark();
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
                    Icons.add_location,
                    size: 36.0,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                button(_goToPosition1, Icons.my_location),
              ],
            ),
          ),
        ),
        Center(
          //top:MediaQuery.of(context).size.height/2,
          //left: MediaQuery.of(context).size.width/2,
          child: IconButton(
            icon: Icon(Icons.add),
            iconSize: 35.0,
            onPressed: () {},
            color: Colors.black,
          ),
//          child: CircleAvatar(
//            radius: 2.0,
//            backgroundColor: Colors.red,
//          ),
        ),
      ],
    );
  }
  Future<void> addBookmark() async {
    final formState = formkey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        print("Hi");
        firestore
            .collection('Users')
            .document(uid)
            .collection('Bookmarks')
            .add({
          'Location': new GeoPoint(
              _lastMapPosition.latitude, _lastMapPosition.longitude),
          'Place': locName
        });
        Navigator.of(context).pop();
      } catch (e) {
        print(e.message);
      }
    }
  }
}
