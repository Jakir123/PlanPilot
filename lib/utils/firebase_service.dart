import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  // Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Save todos and return document reference
  Future<DocumentReference> saveTodo(String userId, Map<String, dynamic> todo, {bool isAnonymous = false}) async {
    final col = isAnonymous
        ? _firestore.collection('anonymous').doc(userId).collection('todos')
        : _firestore.collection('users').doc(userId).collection('todos');
    return await col.add(todo);
  }

  // Update todos
  Future<void> updateTodo({
      required String userId,
      required String docId,
      required Map<String, dynamic> todo,
      bool isAnonymous = false
  }) async {
    final col = isAnonymous
        ? _firestore.collection('anonymous').doc(userId).collection('todos')
        : _firestore.collection('users').doc(userId).collection('todos');
    await col.doc(docId).update(todo);
  }

  // Migrate todos from anonymous to user
  Future<void> migrateTodos(String anonId, String userId) async {
    final anonTodoSnap = await _firestore.collection('anonymous').doc(anonId).collection('todos').get();
    final userTodoRef = _firestore.collection('users').doc(userId).collection('todos');
    for (var doc in anonTodoSnap.docs) {
      await userTodoRef.add(doc.data());
      await doc.reference.delete();
    }
  }

  // Delete todos
  Future<void> deleteTodo({
    required String userId,
    required String docId,
    required bool isAnonymous,
  }) async {
    final ref = isAnonymous
        ? _firestore.collection('anonymous').doc(userId).collection('todos').doc(docId)
        : _firestore.collection('users').doc(userId).collection('todos').doc(docId);
    await ref.delete();
  }

  Future<void> updateTodoCompleteStatus({
    required String userId,
    required String docId,
    required bool isCompleted,
    required bool isAnonymous,
  }) async {
    final ref = isAnonymous
        ? _firestore.collection('anonymous').doc(userId).collection('todos').doc(docId)
        : _firestore.collection('users').doc(userId).collection('todos').doc(docId);
    await ref.update({'isCompleted': isCompleted});
  }

  Future<void> updateTodoReminderStatus({
    required String userId,
    required String docId,
    required bool reminder,
    required bool isAnonymous,
  }) async {
    final ref = isAnonymous
        ? _firestore.collection('anonymous').doc(userId).collection('todos').doc(docId)
        : _firestore.collection('users').doc(userId).collection('todos').doc(docId);
    await ref.update({'reminder': reminder});
  }


  // Update priority state
  Future<void> updatePriority({
    required String userId,
    required String docId,
    required String priority,
    required bool isAnonymous,
  }) async {
    final ref = isAnonymous
        ? _firestore.collection('anonymous').doc(userId).collection('todos').doc(docId)
        : _firestore.collection('users').doc(userId).collection('todos').doc(docId);
    await ref.update({'priority': priority});
  }


  // Get completed todos (isCompleted == true) for user or anonymous
  Stream<QuerySnapshot<Map<String, dynamic>>> completedTodosStream(String userId, {bool isAnonymous = false}) {
    final col = isAnonymous
        ? _firestore.collection('anonymous').doc(userId).collection('todos')
        : _firestore.collection('users').doc(userId).collection('todos');
    return col.where('isCompleted', isEqualTo: true).snapshots();
  }

  // Get pending todos (isCompleted == false) for user or anonymous
  Stream<QuerySnapshot<Map<String, dynamic>>> pendingTodosStream(String userId, {bool isAnonymous = false}) {
    print('User: ${userId}, isAnonymous: ${isAnonymous}');
    final col = isAnonymous
        ? _firestore.collection('anonymous').doc(userId).collection('todos')
        : _firestore.collection('users').doc(userId).collection('todos');
    return col.where('isCompleted', isEqualTo: false).snapshots();
  }
}
