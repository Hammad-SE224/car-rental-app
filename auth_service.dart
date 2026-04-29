import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- Ye lazmi add karen

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore Instance

  // 1. Sign Up Logic (With Firestore Data Save)
  Future<String?> signUpUser({
    required String email,
    required String password,
    required String name, // <--- Name parameter add kiya hai
  }) async {
    try {
      print("--- STARTING SIGNUP ---");

      // A. Authentication mein user create karna
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print("--- AUTH SUCCESS: $uid ---");

      // B. Firestore mein User ki details save karna
      // 'users' naam ki collection banegi aur har user ka document uski UID hogi
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'user', // Default role
        'createdAt': FieldValue.serverTimestamp(), // Firebase server ka time
      });

      print("--- FIRESTORE DATA SAVED SUCCESS ---");
      return "success";
    } on FirebaseAuthException catch (e) {
      print("!!! FIREBASE AUTH ERROR: ${e.code} !!!");

      if (e.code == 'weak-password') return "Password bohat kamzor hai (min 6 chars).";
      if (e.code == 'email-already-in-use') return "Is email par pehle hi account bana hai.";
      if (e.code == 'invalid-email') return "Email ka format sahi nahi hai.";
      if (e.code == 'operation-not-allowed') return "Firebase Console mein Email/Password enable nahi hai.";

      return e.message;
    } catch (e) {
      print("!!! SYSTEM ERROR: $e");
      return e.toString();
    }
  }

  // 2. Login Logic
  Future<String?> loginUser({required String email, required String password}) async {
    try {
      print("--- ATTEMPTING LOGIN ---");
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("--- LOGIN SUCCESS ---");
      return "success";
    } on FirebaseAuthException catch (e) {
      print("!!! LOGIN ERROR: ${e.code} !!!");
      // Firebase modern versions mein 'user-not-found' aur 'wrong-password'
      // aksar 'invalid-credential' ban kar aate hain security ke liye
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Email ya Password ghalat hai.";
      }
      return e.message;
    } catch (e) {
      print("!!! SYSTEM ERROR: $e");
      return e.toString();
    }
  }

  // 3. Logout
  Future<void> signOut() async {
    await _auth.signOut();
    print("--- USER LOGGED OUT ---");
  }
}