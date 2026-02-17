# SwallowSafe

A high-compliance, minimalist rehabilitation app for Dysphagia patients.

## Overview

SwallowSafe provides native video exercise guidance, simplified progress tracking, and an AI-driven "Recovery Assistant" for stroke survivors and Head/Neck Cancer (HNC) patients.

## Features

- **Native Video Exercises**: Auto-looping, native video player with no seek bars
- **Progress Tracking**: Streak-based motivation system
- **Daily Symptom Check-in**: Visual 1-5 scale for pain, swallowing ease, and dry mouth
- **AI Recovery Assistant**: GPT-4o/Claude 3.5 Sonnet powered chat (Pro subscription)
- **Push Notifications**: Actionable reminders with "Done" and "Remind in 15m"
- **Offline Support**: Videos cached locally for hospital use

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: BLoC pattern
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **Video CDN**: AWS S3 + CloudFront
- **Subscriptions**: RevenueCat
- **AI**: OpenAI GPT-4o + Anthropic Claude 3.5 Sonnet

## Getting Started

### Prerequisites

- Flutter SDK 3.24+
- Android Studio with Android SDK 34
- Firebase CLI
- Node.js 18+

### Installation

1. Clone and navigate to the project:
   ```bash
   cd swallow_safe
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   ```bash
   cd firebase
   firebase login
   firebase init
   ```

4. Install Cloud Functions dependencies:
   ```bash
   cd firebase/functions
   npm install
   ```

5. Configure environment variables for Cloud Functions:
   ```bash
   firebase functions:config:set openai.key="YOUR_OPENAI_KEY" anthropic.key="YOUR_ANTHROPIC_KEY"
   ```

### Running the App

```bash
# Run on Android emulator
flutter run

# Run on iOS simulator (macOS only)
flutter run -d ios

# Run with verbose logging
flutter run --verbose
```

### Running Tests

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# All tests
flutter test
```

## Project Structure

```
swallow_safe/
├── lib/
│   ├── main.dart              # Entry point
│   ├── app.dart               # App configuration
│   ├── core/                  # Core utilities
│   │   ├── constants/         # Colors, dimensions, strings
│   │   ├── theme/             # Accessible theme (WCAG AAA)
│   │   ├── router/            # Navigation
│   │   └── services/          # AI, notifications, haptics
│   ├── features/              # Feature modules
│   │   ├── home/              # Home screen
│   │   ├── exercise/          # Video player & session flow
│   │   ├── tracking/          # Symptom check-in
│   │   ├── progress/          # Streaks & history
│   │   ├── ai_assistant/      # Chat UI & paywall
│   │   └── settings/          # App settings
│   ├── data/                  # Data layer
│   │   ├── models/            # Data models
│   │   ├── repositories/      # Data access
│   │   └── providers/         # API clients
│   └── shared/                # Shared widgets
├── firebase/                  # Firebase configuration
│   ├── functions/             # Cloud Functions
│   ├── firestore.rules        # Security rules
│   └── firestore.indexes.json # Database indexes
└── test/                      # Tests
```

## Accessibility

SwallowSafe follows WCAG AAA guidelines:

- **Touch Targets**: Minimum 60×60 dp buttons
- **Typography**: Atkinson Hyperlegible font, min 18pt
- **Contrast**: 7:1+ contrast ratios
- **Haptics**: Physical vibration feedback for completion
- **Navigation**: Linear flow, no nested menus

## License

Proprietary - All rights reserved
