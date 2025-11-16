import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class FirebaseService {
  static Future<void> uploadResultToFirebase(
    String prediction,
    Position? position, {
    double? gkg,
    double? luas,
    String? rekomendasi,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      GeoPoint? geoPoint;
      if (position != null) {
        geoPoint = GeoPoint(position.latitude, position.longitude);
      }

      
      await firestore.collection('users').doc(user.uid).collection('predictions').add({
        'prediction': prediction,
        'timestamp': FieldValue.serverTimestamp(),
        'location': geoPoint,
        'gkg': gkg,
        'luas': luas,
        'rekomendasi': rekomendasi,
      });

      
      if (geoPoint != null) {
        await firestore.collection('location').add({
          'location': geoPoint,
          'timestamp': FieldValue.serverTimestamp(),
          'prediction': prediction,
          'gkg': gkg,
          'luas': luas,
          'rekomendasi': rekomendasi,
        });
      }
    } catch (e) {
      throw Exception('Failed to upload to Firebase: $e');
    }
  }
}
