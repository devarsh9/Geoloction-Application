import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class crudMethods {
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else
      return false;
  }

  Future<void> addData(signUpData) async {
    if (isLoggedIn()) {
      Firestore.instance.collection('Users').add(signUpData).catchError((e) {
        print(e);
      });
    } else
      print('you need to be logged in');
  }

  Future<void> updateUserdata(String email, String username, String uid) async {
    return await Firestore.instance.document(uid).setData({
      'Email': email,
      'Username': username,
      'id': uid,
    });
  }

  getChat() async {
    return await Firestore.instance.collection('Users').snapshots();
  }
  //undoing add uid back  getChat(uid)
  // also add .document(uid).collection('Friends')
  updateData(
    selectedDoc,
  ) {
    Firestore.instance
        .collection('testcrud')
        .document(selectedDoc)
        .updateData({'unRead': "1"}).catchError((e) {
      print(e);
    });
  }
}
