# 🤳 MGA Face Login (mga-face-app)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com/)
[![Architecture](https://img.shields.io/badge/Architecture-Layered%20Clean-blue)](https://flutter.dev)

An admin-facing biometric utility for the MGA platform: face-based member login verification and video-based new-member face registration, on Android.

## Features

- Admin authentication gate in front of both biometric flows
- **Face Login** — front-camera auto-capture after a short delay, sent to the verification service, with a pass/fail result screen (auto-dismissing countdown, member ID and match confidence on success)
- **New Member Registration** — records a short enrollment video against a username, with front/back camera toggle
- Session auto-expiry (3-hour token TTL), sized for how this app is actually used — an admin runs a batch of registrations or logins in one sitting, not scattered check-ins across a day, so a longer window avoids interrupting that in the middle without weakening the security model

## Tech Stack

- Flutter (Android)
- `http` for networking, including multipart uploads (face image, member registration video) — deliberately consolidated onto one HTTP client rather than splitting multipart handling across `http` and `dio`
- `shared_preferences` for session storage
- `camera` for live capture (front/back toggle, photo and video)

## Project Structure

lib/
├── core/
│   ├── config/       # constants, routes
│   └── network/      # ApiClient — JSON + multipart in one place
├── models/           # FaceScanResult
├── services/         # auth cache, admin API, face API, camera registry
└── screens/
    ├── common/        # splash
    ├── auth/          # admin login
    ├── dashboard/     # post-login landing (choose Face Login / New Member)
    └── face/          # face login, new-member registration, scan result

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- A physical Android device is strongly recommended — camera behavior on emulators is unreliable for this app's core flows

### Install & Run
flutter pub get
flutter run

### Configuration
The backend base URL lives in `lib/core/config/app_constants.dart`.

## Testing

flutter test

Unit tests cover the `FaceScanResult` model (including the exact success/failure sentinel logic — `identifiedUser` values of `'UNKNOWN'` and `'Unknown'` both count as a failed match), the `ApiClient` network layer for both plain JSON and multipart requests, and the 3-hour token-TTL logic. A widget test covers the admin-username restriction on the login screen.

## Architecture Notes

Two things worth knowing if you're reading this before extending the app, not just running it:

- **A hardcoded authentication bypass was removed** during the restructuring — the original login code granted a valid admin session on `admin`/`admin` credentials whenever the real login request threw an exception (including simple network failures). That is not present in this version. If you're diffing against an older copy of this code and wondering where it went, that's why.
- **`dio` was removed as a dependency.** The original code used `http` for one multipart endpoint and `dio` for another, for no structural reason — both are now handled by the same `ApiClient.postMultipart`.

```