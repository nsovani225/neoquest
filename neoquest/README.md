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

`FirestoreActivityApi` reads activity documents, stores published community quests, and keeps saved quests under each signed-in user's document. After the first successful sign-in, it adds missing sample quests and backfills only absent map/filter metadata on existing sample documents. It does not replace existing titles, descriptions, or edits. Activity documents include latitude/longitude, distance, budget, group-size, duration, transport, and availability fields for matching.

All activity reads require a signed-in Firebase user. Saved quests remain scoped to the signed-in user's own document. The rule file also permits one-time additive metadata backfills for the known demo activity IDs.

The map uses `flutter_map` with OpenStreetMap tiles; map panning, zooming, activity markers, and OpenStreetMap attribution are provided in-app. No Google Places key is required.

The home page also requests current Berkeley weather from the public Open-Meteo API. If that service is unavailable, the rest of the app still loads normally.

Firebase Authentication uses email/password and Google sign-in. Firebase Console project settings use the public-facing name “NeoQuest” and the support address selected during setup.

## Routes and access

- `/` — Public landing page
- `/signin`, `/signup` — Email/password and Google sign-in, account creation, and password reset
- `/home` — Signed-in dashboard
- `/filters` — Activity, distance, budget, group size, duration, rating, transport, and availability filters
- `/list` (`/explore` redirects here) — Searchable Firestore-backed results and saved ideas
- `/map` — OpenStreetMap with data-backed pins and matching result cards
- `/activity/<id>` — Protected activity details and save action

Protected routes redirect signed-out visitors to sign-in and preserve the requested destination through authentication. New accounts require a password with at least eight characters and one number.

## Deploy Firestore rules

From this app directory, deploy the checked-in access rules with `firebase deploy --only firestore:rules`. The Firebase CLI project alias is set to `neoquest-74e8c` in `.firebaserc`.

The website is responsive and targets web only. No `freezed` or other generated model packages are used.
