# NeoQuest

NeoQuest is a Flutter web app for finding small adventures around Berkeley. It uses a photo-led, map-first layout with Firebase Authentication and Cloud Firestore.

## Run locally

```sh
flutter pub get
flutter run -d chrome
```

To make a static web build:

```sh
flutter build web
```

## App structure

```text
lib/
├── data/       # Firestore repository and public weather API
├── models/     # Plain Dart data models (no code generation / freezed)
├── screens/    # Home, Explore, activity detail, sign-in and sign-up
├── widgets/    # Shared navigation and activity cards
├── app.dart    # Named route setup
├── main.dart   # Flutter entry point
└── theme.dart  # Shared colors and Material theme
```

## Demo data and API

`FirestoreActivityApi` reads activity documents, stores published community quests, and keeps saved quests under each signed-in user's document. The first successful sign-in adds any missing sample activities to the `activities` collection; three Berkeley examples are already seeded. `firestore.rules` contains the matching access rules.

The home page also requests current Berkeley weather from the public Open-Meteo API. If that service is unavailable, the rest of the app still loads normally.

Firebase Authentication uses email/password and Google sign-in. Firebase Console project settings use the public-facing name “NeoQuest” and the support address selected during setup.

## Routes

- `/` — Home
- `/explore` — Search, categories, saved ideas, and add-a-quest form
- `/map` — Responsive illustrative Berkeley map with data-driven activity pins
- `/activity/<id>` — Activity details and save action
- `/signin` — Sign in
- `/signup` — Create account

The website is responsive and targets web only. No `freezed` or other generated model packages are used.
