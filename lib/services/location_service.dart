import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {

  Future<void> updateUserLocation() async {

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      return;
    }

    Position position =
        await Geolocator.getCurrentPosition();

    final places = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String city =
        places.isNotEmpty
            ? places.first.locality ?? ''
            : '';

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'location': city,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'locationUpdatedAt':
          FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}