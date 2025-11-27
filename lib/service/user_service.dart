import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> createUserDocument({
    required String name,
    required String email,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não  está autenticado');

    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Erro ao criar documento de usuário: $e');
    }
  }

  Future<void> updateUserData({String? name}) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    try {
      final updateData = <String, dynamic>{'updatedAt': DateTime.now()};

      if (name != null) updateData['name'] = name;

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Erro ao atualizar dados do usuário: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<String?> getUserName() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['name'] as String?;
    } catch (e) {
      return null;
    }
  }
}
