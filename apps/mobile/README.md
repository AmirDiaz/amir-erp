# Amir ERP — Universal Flutter Client

**Author:** Amir Saoudi · amirsaoudi620@gmail.com

Runs on Android, iOS, Web, Linux, Windows, macOS.

## Setup

```bash
# from this folder:
flutter create . --platforms=android,ios,web,linux,windows,macos --org com.amirsaoudi --project-name amir_erp --description "Amir ERP" --overwrite=false
flutter pub get
flutter gen-l10n
```

## Run

```bash
# Web (Chrome)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000

# Linux desktop
flutter run -d linux --dart-define=API_BASE_URL=http://localhost:3000

# Android
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Default credentials

- **Tenant:** `demo`
- **Email:** `admin@demo.amir-erp.local`
- **Password:** `AmirAdmin#2026`

The signature **Amir Saoudi** is embedded in the splash screen, login footer, every page footer, the About page, and the web `index.html`.
