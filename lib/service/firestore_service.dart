import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:patrimonio_investimentos/model/patrimonio.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _patrimoniosCollection {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('patrimonios');
  }

  Future<void> create(Patrimonio patrimonio) {
    return _patrimoniosCollection.add({
      ...patrimonio.toMap(),
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> read() {
    final patrimonioStream = _patrimoniosCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
    return patrimonioStream;
  }

  Future<void> update(String docID, Patrimonio patrimonio) {
    return _patrimoniosCollection.doc(docID).update({
      ...patrimonio.toMap(),
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> delete(String docID) {
    return _patrimoniosCollection.doc(docID).delete();
  }

  Future<DocumentSnapshot> getPatrimonio(String docID) {
    return _patrimoniosCollection.doc(docID).get();
  }
}
