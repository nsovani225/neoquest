# 🗺️ NeoQuest

**Stop scrolling. Start exploring.**

NeoQuest is a hangout discovery platform that helps friends find things to do nearby based on their interests, budget, and availability.

Whether it's grabbing boba, finding a basketball court, exploring a new neighborhood, or discovering a hidden spot around town, NeoQuest makes it easier to turn an ordinary day into a side quest.

Instead of focusing only on popular attractions, we're building a way to discover everyday experiences that are affordable, accessible, and actually interesting to your group.

> 🚧 **Project Status:** NeoQuest is currently under active development. Features and technologies described below may change as the project progresses.

---

## ✨ What is NeoQuest?

We've all had the same conversation:

> "What do you want to do?"
>
> "I don't know. What do you want to do?"
>
> "I don't know either."

NeoQuest is our attempt to make that conversation a little shorter.

Users can discover activities based on a few simple preferences:

- **Budget** — How much are you willing to spend?
- **Group Size** — Going solo or with friends?
- **Activity** — Food, sports, outdoors, exploring, or something else?
- **Transportation** — Walking, biking, public transit, or driving?
- **Time** — How long do you have?
- **Location** — How far are you willing to go?

NeoQuest uses these preferences to help users find nearby places and activities that fit their plans.

Our goal isn't necessarily to recommend the most popular place in town. It's to help people find something worth doing, even in places they think they already know.

---

## 🌟 Features

### 🧭 Side Quest Discovery

Find activities beyond the usual tourist attractions and popular destinations.

A side quest could be anything from trying a new café to taking a random bus route and exploring an unfamiliar neighborhood.

NeoQuest aims to combine location-based recommendations with creative activities suggested by the community.

### 🔥 Activity Heatmap (Planned)

One of our main ideas is an interactive heatmap that highlights areas based on the activity users want to do.

For example, selecting **"Get Drinks"** could highlight areas with concentrations of boba shops, cafés, smoothie shops, and dessert spots.

Switching to **"Something Active"** could instead highlight parks, basketball courts, hiking trails, and recreation centers.

Rather than displaying dozens of unrelated map pins, the heatmap would help users see which areas are most promising for their plans.

### 🎛️ Preference-Based Filtering

Recommendations can be narrowed using different constraints.

| Preference | Example |
|---|---|
| Budget | Free, $, $$ |
| Group Size | Solo, 2–4, 5+ |
| Transportation | Walking, biking, transit, driving |
| Activity | Food, outdoors, sports, drinks, exploring |
| Time | 30 minutes, 1 hour, 2+ hours |
| Distance | Nearby or willing to travel |

These filters will help users find activities that work for their group rather than sorting through unrelated recommendations.

### 🗺️ Interactive Map

NeoQuest is designed around a map-based interface where users can explore nearby places, compare locations, and discover potential side quests.

Planned functionality includes:

- Viewing nearby activities and destinations
- Filtering locations by activity type
- Exploring individual place details
- Visualizing activity density
- Selecting and bookmarking places

### 👥 Group Preferences

Planning a hangout means considering what everyone wants to do.

NeoQuest aims to support shared preferences so that suggestions work for the group as a whole.

Future versions may allow friends to submit preferences individually or save recurring group preferences.

### ➕ Community Side Quests

Not every fun activity needs to come from a business listing.

We want users to eventually submit their own side quests for others to discover.

For example:

> "Take the 51B five random stops and explore wherever you end up."

Or:

> "Grab drinks at a new café and find somewhere nearby to watch the sunset."

Community-created activities would help NeoQuest recommend experiences, not just places.

---

## 🧠 How NeoQuest Works

The planned user flow is straightforward:

```text
Open NeoQuest
      |
      v
Create a Hangout
      |
      v
Enter Group Preferences
      |
      v
Find Nearby Places & Activities
      |
      v
Filter and Rank Recommendations
      |
      v
Explore Results on the Map
      |
      v
Choose a Side Quest!
```

For example, suppose four friends want to get drinks, have a budget of $15 each, and don't want to drive.

NeoQuest could search for nearby cafés, boba shops, and dessert spots, filter the options according to their constraints, and display suitable locations on the map.

As the recommendation system develops, we also hope to incorporate community suggestions and activity-based heatmaps.

---

## 🛠️ Tech Stack

NeoQuest's technology stack is evolving as the team builds and tests different components.

| Technology | Purpose |
|---|---|
| **Flutter / Dart** | Application development for the current Flutter branch |
| **Firebase Authentication** | User registration and login |
| **Cloud Firestore** | Storing user data, preferences, bookmarks, and side quests |
| **Figma** | Interface design and prototyping |
| **Google Maps Platform** | Planned map and location functionality |
| **Google Places API** | Potential source for nearby place information |
| **Python / scikit-learn** | Potential recommendation and data-processing tools |
| **Git / GitHub** | Version control and collaboration |

Flutter is used in the current application branch. Firebase and external API integrations should be configured and verified as development progresses.

### Database & Authentication

Firebase is our intended solution for managing user accounts and application data.

The planned database will support information such as:

- User profiles and preferences
- Saved locations and bookmarks
- Community-created side quests
- Hangout history
- Group preferences

Firebase Authentication will handle user sign-in, while Cloud Firestore will store application data.

### Maps & APIs

We're evaluating APIs that can provide:

- Nearby businesses and attractions
- Location coordinates
- Place categories and ratings
- Travel distance and estimated travel time
- Map visualization

Google Maps Platform and Google Places are leading candidates.

API selection will also depend on usage limits, cost, and restrictions on storing or displaying third-party data.

---

## 🗃️ Proposed Database Structure

A simplified Firestore structure might look like:

```text
users/
  {userId}/
    displayName
    preferences
    savedFriends

sideQuests/
  {questId}/
    creatorId
    title
    description
    category
    location
    budget
    duration
    groupSize

hangouts/
  {hangoutId}/
    participants
    preferences
    selectedQuest
    createdAt

bookmarks/
  {bookmarkId}/
    userId
    placeId
    createdAt
```

This is a proposed structure, not a finalized schema. Collections and fields may change as the database team implements the application.

---

## 🎨 Design

We're using Figma to plan NeoQuest's interface before implementing new features.

Our design priorities are:

- A map-first exploration experience
- Simple and intuitive filtering
- Clear activity categories
- Mobile-friendly layouts
- A playful interface that fits the side quest concept

Screenshots and Figma previews will be added as designs are finalized.

---

## 🚀 Getting Started

Follow these steps to set up and run the Flutter version of NeoQuest locally.

### Prerequisites

Before starting, make sure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- [Git](https://git-scm.com/) installed
- An editor such as VS Code or Android Studio
- Access to the NeoQuest GitHub repository

To verify your Flutter installation, open a terminal and run:

```bash
flutter doctor
```

This checks whether Flutter is installed correctly and identifies missing development tools.

Resolve any relevant setup issues before continuing.

### 1. Clone the Repository

Clone NeoQuest onto your computer:

```bash
git clone <repository-url>
```

Navigate into the project directory:

```bash
cd neoquest
```

If you're working on a specific branch, switch to that branch before proceeding.

Make sure you're inside the Flutter project folder containing `pubspec.yaml`.

### 2. Install Dependencies

Run:

```bash
flutter pub get
```

This downloads the packages listed in the project's `pubspec.yaml` file.

You should run this command when setting up the project for the first time or whenever dependencies are added or updated.

### 3. Run the Application

Once dependencies are installed, run:

```bash
flutter run
```

Flutter may display a list of available devices.

For example:

```text
Connected devices:

[1]: Chrome (chrome)
[2]: macOS (macos)

Please choose one:
```

**If Chrome is listed as option 1, type `1` and press Enter.**

This launches NeoQuest in Chrome.

The device numbers may differ depending on your computer, so choose the number corresponding to the device you want to use.

### Quick Start

After completing the initial setup, the typical commands are:

```bash
flutter pub get
flutter run
```

Then select the appropriate device when prompted.

**Note:** You generally don't need to run `flutter pub get` every time. Once dependencies are installed, you can usually start the application with `flutter run`.

### Troubleshooting

**Flutter command not found**

Check that the Flutter SDK is installed and added to your system's PATH.

**No devices available**

Run:

```bash
flutter devices
```

This lists the devices Flutter can currently detect.

**Dependencies aren't installing**

Make sure you're in the folder containing `pubspec.yaml`, then try:

```bash
flutter pub get
```

**Chrome doesn't appear**

Check your Flutter web configuration and verify that Chrome is installed. If web support is available, you can also try:

```bash
flutter run -d chrome
```

**Firebase or API configuration errors**

Some functionality may require Firebase configuration files or API credentials. Contact the relevant team member for the current development setup.

Do not commit private credentials, service account keys, or other secrets to the repository.

---

## 📁 Project Structure

Flutter projects generally follow a structure similar to:

```text
neoquest/
├── android/             # Android configuration
├── ios/                 # iOS configuration
├── lib/                 # Main Dart application code
│   └── main.dart        # Application entry point
├── web/                 # Web configuration
├── test/                # Application tests
├── pubspec.yaml         # Dependencies and project settings
└── README.md
```

The actual NeoQuest directory structure may differ. Additional folders for authentication, database services, maps, and UI components will be documented as they are implemented.

---

## 🛣️ Development Roadmap

### Phase 1 — Foundation

- [ ] Finalize initial Figma designs
- [ ] Set up and verify the Flutter application
- [ ] Configure Firebase Authentication
- [ ] Design the initial Firestore schema
- [ ] Evaluate Maps and Places APIs

### Phase 2 — Core MVP

- [ ] User registration and login
- [ ] Basic dashboard and navigation
- [ ] Interactive map
- [ ] Nearby place retrieval
- [ ] Preference filtering
- [ ] Basic recommendation logic
- [ ] Side quest selection

### Phase 3 — Additional Features

- [ ] Activity heatmap
- [ ] Community-created side quests
- [ ] Bookmarks and saved locations
- [ ] Saved group preferences
- [ ] Improved recommendation ranking

### Phase 4 — Stretch Goals

- [ ] Shared preference invitations
- [ ] User reviews and ratings
- [ ] Weather-aware recommendations
- [ ] User-uploaded photos
- [ ] More advanced recommendation models
- [ ] Expansion beyond Berkeley and the Bay Area

Checkboxes will be updated as features are completed and integrated.

---

## 👨‍💻 Team Structure

NeoQuest development is organized into three main subteams.

### Frontend

Responsible for designing and implementing the user-facing application.

This includes Figma designs, Flutter screens, navigation, filters, map interfaces, and reusable components.

### Database & Authentication

Responsible for Firebase integration, authentication, user profiles, preferences, bookmarks, and stored side quests.

### Data & APIs

Responsible for evaluating external APIs, retrieving place data, developing filtering and recommendation logic, and exploring heatmap visualization.

The subteams collaborate on integration, debugging, and testing.

---

## 🤝 Contributing

We're building NeoQuest collaboratively, so please work on separate branches rather than pushing unfinished changes directly to `main`.

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

Examples:

```text
feature/firebase-auth
feature/flutter-dashboard
feature/google-maps
feature/activity-heatmap
feature/quest-filtering
```

### 2. Make Your Changes

Implement and test your feature locally.

For Flutter code, you can run:

```bash
flutter analyze
```

This checks your Dart code for common issues.

### 3. Commit Your Changes

```bash
git add .
git commit -m "Add feature description"
```

Use descriptive commit messages so other members can understand what changed.

### 4. Push Your Branch

```bash
git push origin feature/your-feature-name
```

### 5. Open a Pull Request

Create a pull request on GitHub and describe:

- What you changed
- Why the change was needed
- How you tested it
- Any remaining issues

Have another team member review your changes before merging.

---

## 📌 Project Status

NeoQuest is currently being developed and tested by our team.

Our immediate goal is a working application where users can enter hangout preferences, discover nearby activities, and explore recommendations through a map.

The recommendation system, database schema, API integrations, and additional social features will continue to evolve.

---

## 🌎 Why NeoQuest?

We don't think every hangout needs to involve a famous destination, an expensive activity, or hours of planning.

Sometimes it's enough to find a new café, explore a neighborhood, or try something you wouldn't have considered otherwise.

NeoQuest is about making those small adventures easier to discover.

**Find your next side quest.**
