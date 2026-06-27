# 🌿 NeuroLeaf — AI Plant Disease Detection App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase" />
  <img src="https://img.shields.io/badge/TensorFlow-2.x-yellow?logo=tensorflow" />
  <img src="https://img.shields.io/badge/Flask-API-green?logo=flask" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey?logo=apple" />
</p>

> NeuroLeaf is an AI-powered plant disease detection mobile app built with Flutter and a TensorFlow deep learning model. Scan any leaf, get instant disease diagnosis, treatment recommendations, and earn stars to unlock premium research papers and books.

---

## 📱 Screenshots

| Login | Home | Results | Library |
|---|---|---|---|
| ![Login](screenshots/login.png) | ![Home](screenshots/home.png) | ![Results](screenshots/results.png) | ![Library](screenshots/library.png) |

| Tasks | Weather | Profile | Profile Setup |
|---|---|---|---|
| ![Tasks](screenshots/tasks.png) | ![Weather](screenshots/weather.png) | ![Profile](screenshots/profile.png) | ![Setup](screenshots/setup.png) |

---

## ✨ Features

### 🔍 AI Leaf Scanning
- Upload from gallery or capture with camera
- Detects **16 plant diseases** across Tomato, Potato, and Pepper
- Shows disease name, confidence score, description, and treatment

### 🔐 Authentication
- Email & Password login/signup
- Google Sign-In
- Facebook Login
- GitHub OAuth
- Profile setup screen on first login (with % completion bar)

### ⭐ Star Credit System
- Scan 10 leaves daily → earn 1 ⭐ star
- Complete daily tasks and milestones → earn bonus stars
- Spend stars to unlock premium research papers and books

### 📚 Library
- Free articles on plant health and disease prevention
- Premium research papers (Deep Learning, Transfer Learning, ResNet)
- Premium books on Plant Pathology and Agricultural AI
- Unlock with stars

### 🌤 Weather & Crop Advisory
- Current weather display
- 7-day forecast
- Crop-specific disease risk advisory based on weather
- Daily farming tips

### 📋 Tasks & Rewards
- Daily tasks with progress tracking
- Milestones (First Scan, Scan Explorer, Leaf Master)
- Star earning history

### 👤 Profile
- Avatar picker (emoji-based)
- Bio, name, location
- Scan history from Firestore
- Stars and total scan stats
- Logout

---

## 🏗 Architecture

```
NeuroLeaf/
├── lib/
│   ├── main.dart                      # App entry + auth gate
│   ├── firebase_options.dart          # Firebase config
│   ├── screens/
│   │   ├── main_screen.dart           # Bottom navigation
│   │   ├── home_screen.dart           # Leaf scan screen
│   │   ├── library_screen.dart        # Articles + premium content
│   │   ├── weather_screen.dart        # Weather + crop advisory
│   │   ├── tasks_screen.dart          # Tasks + milestones
│   │   ├── profile_screen.dart        # User profile
│   │   ├── profile_setup_screen.dart  # First-time profile setup
│   │   ├── login_screen.dart          # Login screen
│   │   ├── signup_screen.dart         # Signup screen
│   │   └── otp_screen.dart            # OTP verification
│   └── services/
│       ├── auth_service.dart          # Firebase Auth methods
│       ├── storage_service.dart       # Firestore scan storage
│       └── credit_service.dart        # Star credit system
├── ios/
│   └── Runner/
│       ├── Info.plist                 # iOS config + permissions
│       ├── AppDelegate.swift          # Firebase + Facebook init
│       └── GoogleService-Info.plist   # Firebase iOS config
└── backend/
    └── app.py                         # Flask API + TensorFlow model
```

---

## 🤖 AI Model

- **Architecture:** TensorFlow SavedModel (custom CNN)
- **Dataset:** PlantVillage Dataset (54,000+ images)
- **Input:** 128×128 RGB leaf image
- **Output:** 16 disease classes with confidence scores

### Supported Classes
| Plant | Diseases |
|---|---|
| 🍅 Tomato | Bacterial Spot, Early Blight, Late Blight, Leaf Mold, Septoria Leaf Spot, Spider Mites, Target Spot, Yellow Leaf Curl Virus, Mosaic Virus, Healthy |
| 🥔 Potato | Early Blight, Late Blight, Healthy |
| 🫑 Pepper (Bell) | Bacterial Spot, Healthy |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart 3.x
- Python 3.8+
- Firebase account
- Xcode (for iOS)

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/NeuroLeaf.git
cd NeuroLeaf
```

### 2. Install Flutter dependencies
```bash
flutter pub get
cd ios && pod install && cd ..
```

### 3. Firebase setup
- Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- Enable Authentication (Email, Google, Facebook, GitHub)
- Enable Firestore Database
- Enable Firebase Storage
- Download `GoogleService-Info.plist` (iOS) and add to `ios/Runner/`
- Run `flutterfire configure` to generate `firebase_options.dart`

### 4. iOS Info.plist
Add to `ios/Runner/Info.plist`:
```xml
<key>GIDClientID</key>
<string>YOUR_GOOGLE_CLIENT_ID</string>
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
```

### 5. Run the Flutter app
```bash
flutter run
```

---

## 🐍 Backend Setup (Flask API)

### 1. Install dependencies
```bash
cd backend
pip install flask tensorflow pillow numpy
```

### 2. Add your model
Place your TensorFlow SavedModel in:
```
backend/leaf_model_tf/
```

### 3. Run the API
```bash
python app.py
```
API runs at `http://localhost:5001`

### 4. Expose with ngrok (for mobile testing)
```bash
ngrok http 5001
```
Copy the ngrok URL and update in `home_screen.dart`:
```dart
Uri.parse("https://YOUR_NGROK_URL/predict")
```

---

## 🔥 Firebase Firestore Structure

```
users/
└── {userId}/
    ├── name: string
    ├── email: string
    ├── avatar: string (emoji)
    ├── bio: string
    ├── location: string
    ├── stars: number
    ├── totalScans: number
    ├── dailyScans: map
    ├── profileComplete: boolean
    └── scans/
        └── {scanId}/
            ├── disease: string
            ├── confidence: number
            ├── description: string
            ├── solution: string
            └── timestamp: timestamp
```

---

## 🔒 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
      match /scans/{scanId} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

---

## 📦 Dependencies

### Flutter
```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
firebase_storage: ^12.0.0
google_sign_in: ^6.2.0
flutter_facebook_auth: ^7.0.0
image_picker: ^1.0.0
http: ^1.0.0
```

### Python (Backend)
```
flask
tensorflow
pillow
numpy
```

---

## 🛣 Roadmap

- [ ] Real-time weather API integration (OpenWeatherMap)
- [ ] Offline model support (TFLite)
- [ ] Android support
- [ ] Apple Sign-In
- [ ] Push notifications for daily scan reminders
- [ ] Community feed for farmers
- [ ] Multi-language support (Hindi, Bengali)
- [ ] Crop calendar with regional advisory

---

## 👨‍💻 Developer

**Rijit Ghosh**
- GitHub: [@rijitghosh](https://github.com/rijitghosh)

---

## 📄 License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2026 Rijit Ghosh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
provided, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 🙏 Acknowledgements

- [PlantVillage Dataset](https://plantvillage.psu.edu/) — plant disease image dataset
- [TensorFlow](https://tensorflow.org) — deep learning framework
- [Firebase](https://firebase.google.com) — backend and auth
- [Flutter](https://flutter.dev) — cross-platform mobile framework

---

<p align="center">Made with ❤️ and 🌿 by Rijit Ghosh</p>
