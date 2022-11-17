import 'package:cloud_firestore/cloud_firestore.dart';

class MicroTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userId = 'KJHjNiPqVBUzJ0ibjCrR3IV04Fa2';

  Future<void> requestMoney() async {}

  Future<DocumentSnapshot> getAllTransactions() async {
    return _firestore.collection('users').doc(userId).get();
  }

  Future<void> getTransaction() async {}
}
