import 'package:cloud_firestore/cloud_firestore.dart';
class DatbaseSevice{
  final String uid;
  DatbaseSevice({this.uid});
  final CollectionReference collectionReference=Firestore.instance.collection('Users');

  Future updateUserData(String email,String username,String uid) async
  {
    return await collectionReference.document(uid).setData({
      'Email':email,
      'Username':username,
      'id':uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'chattingWith': null
    });
  }
}