import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789:android:abcdefxxxxxxxx',
    messagingSenderId: '123456789',
    projectId: 'pro-grocery-dev',
    databaseURL: 'https://pro-grocery-dev.firebaseio.com',
    storageBucket: 'pro-grocery-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789:ios:abcdefxxxxxxxx',
    messagingSenderId: '123456789',
    projectId: 'pro-grocery-dev',
    databaseURL: 'https://pro-grocery-dev.firebaseio.com',
    storageBucket: 'pro-grocery-dev.appspot.com',
    iosBundleId: 'com.africangrocery.pro',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789:web:abcdefxxxxxxxx',
    messagingSenderId: '123456789',
    projectId: 'pro-grocery-dev',
    authDomain: 'pro-grocery-dev.firebaseapp.com',
    databaseURL: 'https://pro-grocery-dev.firebaseio.com',
    storageBucket: 'pro-grocery-dev.appspot.com',
  );
}
